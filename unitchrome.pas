{$mode delphi}{$H+}
unit UnitChrome;

// Themes the parts of the main window that Windows draws itself: the title bar, the menu bar,
// the tab headers and the scroll bars.
//
//  - title bar:     DWM window attributes (Windows 10 2004+ for dark mode, Windows 11 for colors)
//  - menu bar:      the items of the bar are owner-drawn by the LCL, so the window procedure of the
//                   form is subclassed to draw them with the theme colors (WM_DRAWITEM); the rest of
//                   the bar is painted after the non-client area has been drawn (WM_NCPAINT)
//  - scroll bars:   the "dark mode" explorer theme of uxtheme
//  - tab headers:   the tab control window is subclassed and its headers are painted here
//
// All of it is Windows only and is skipped silently when a call is not available.
// On other systems the procedures do nothing.

interface

uses
  Classes, SysUtils, Graphics, Controls, Forms, ComCtrls;

// enabled = False restores the system look.
procedure ChromeUpdate(Form: TForm; Tabs: TPageControl; enabled: boolean;
  bar, barText, selected, accent: TColor);

// dark scroll bars for lists and memos
procedure ChromeDarkScrollbars(Control: TWinControl; dark: boolean);

implementation

{$ifdef windows}

uses
  Windows, Messages, Menus;

const
  DWMWA_USE_IMMERSIVE_DARK_MODE = 20;
  DWMWA_CAPTION_COLOR = 35;
  DWMWA_TEXT_COLOR    = 36;
  DWMWA_COLOR_DEFAULT = $FFFFFFFF;
  TCM_GETITEMCOUNT = $1304;
  TCM_GETITEMRECT  = $130A;
  TCM_GETCURSEL    = $130B;
  TCM_GETITEMW     = $133C;
  TCIF_TEXT        = 1;
  OBJID_MENU = LONG($FFFFFFFD);

type
  TMenuBarInfo = record
    cbSize : DWORD;
    rcBar : TRect;
    hMenu : HMENU;
    hwndMenu : HWND;
    flags : DWORD;
  end;

  TNonClientMetrics = record
    cbSize : UINT;
    iBorderWidth, iScrollWidth, iScrollHeight, iCaptionWidth, iCaptionHeight : integer;
    lfCaptionFont : TLogFontW;
    iSmCaptionWidth, iSmCaptionHeight : integer;
    lfSmCaptionFont : TLogFontW;
    iMenuWidth, iMenuHeight : integer;
    lfMenuFont : TLogFontW;
    lfStatusFont : TLogFontW;
    lfMessageFont : TLogFontW;
    iPaddedBorderWidth : integer;
  end;

  TTabItemW = record
    mask : UINT;
    dwState : DWORD;
    dwStateMask : DWORD;
    pszText : PWideChar;
    cchTextMax : integer;
    iImage : integer;
    lParam : LPARAM;
  end;

function GetMenuBarInfo(hwnd: HWND; idObject, idItem: LONG; var pmbi: TMenuBarInfo): BOOL;
  stdcall; external 'user32.dll';
function DwmSetWindowAttribute(hwnd: HWND; attr: DWORD; value: Pointer; size: DWORD): HRESULT;
  stdcall; external 'dwmapi.dll';
function SetWindowTheme(hwnd: HWND; pszSubAppName, pszSubIdList: PWideChar): HRESULT;
  stdcall; external 'uxtheme.dll';
function SetWindowLongPtrW(hwnd: HWND; index: integer; value: PtrInt): PtrInt;
  stdcall; external 'user32.dll';
function CallWindowProcW(prev: Pointer; hwnd: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): LRESULT;
  stdcall; external 'user32.dll';

var
  Themed : boolean = False;
  BarColor, BarText, SelectedColor, AccentColor : COLORREF;
  BarBrush, SelectedBrush, HotBrush : HBRUSH;

  FormWnd : HWND = 0;
  FormOldProc : Pointer = nil;
  FormMenu : TMainMenu = nil;
  TabsWnd : HWND = 0;
  TabsOldProc : Pointer = nil;

function Mix(a, b: COLORREF; percent: integer): COLORREF;
begin
  Result := RGB(
    GetRValue(a) + (GetRValue(b) - GetRValue(a)) * percent div 100,
    GetGValue(a) + (GetGValue(b) - GetGValue(a)) * percent div 100,
    GetBValue(a) + (GetBValue(b) - GetBValue(a)) * percent div 100);
end;

function IsDark(c: COLORREF): boolean;
begin
  Result := GetRValue(c) * 3 + GetGValue(c) * 6 + GetBValue(c) < 1280;
end;

procedure MakeBrushes;
begin
  if BarBrush <> 0 then DeleteObject(BarBrush);
  if SelectedBrush <> 0 then DeleteObject(SelectedBrush);
  if HotBrush <> 0 then DeleteObject(HotBrush);
  BarBrush := CreateSolidBrush(BarColor);
  SelectedBrush := CreateSolidBrush(SelectedColor);
  HotBrush := CreateSolidBrush(Mix(BarColor, BarText, 18));
end;

//------------------------------------------------------------------------------------------------
//  menu bar
//------------------------------------------------------------------------------------------------

function IsBarItem(h: HWND; const dis: TDrawItemStruct): boolean;
begin
  Result := (dis.CtlType = ODT_MENU) and (HMENU(dis.hwndItem) = GetMenu(h));
end;

// The LCL stores the TMenuItem of an owner-drawn item in its itemData.
function BarCaption(const dis: TDrawItemStruct): WideString;
var
  obj : TObject;
begin
  Result := '';
  if dis.itemData = 0 then Exit;
  obj := TObject(dis.itemData);
  if obj is TMenuItem then Result := UTF8Decode(TMenuItem(obj).Caption);
end;

procedure DrawBarItem(h: HWND; const dis: TDrawItemStruct);
var
  text : WideString;
  flags : UINT;
  brush : HBRUSH;
  ncm : TNonClientMetrics;
  font, oldFont : HFONT;
  r : TRect;
begin
  r := dis.rcItem;

  brush := BarBrush;
  if (dis.itemState and ODS_HOTLIGHT) <> 0 then brush := HotBrush;
  if (dis.itemState and ODS_SELECTED) <> 0 then brush := SelectedBrush;
  FillRect(dis.hDC, r, brush);

  text := BarCaption(dis);

  flags := DT_CENTER or DT_SINGLELINE or DT_VCENTER;
  if (dis.itemState and ODS_NOACCEL) <> 0 then flags := flags or DT_HIDEPREFIX;

  FillChar(ncm, SizeOf(ncm), 0);
  ncm.cbSize := SizeOf(ncm);
  oldFont := 0;
  font := 0;
  if SystemParametersInfoW(SPI_GETNONCLIENTMETRICS, SizeOf(ncm), @ncm, 0) then
    begin
      font := CreateFontIndirectW(ncm.lfMenuFont);
      oldFont := SelectObject(dis.hDC, font);
    end;

  SetBkMode(dis.hDC, TRANSPARENT);
  SetTextColor(dis.hDC, BarText);
  DrawTextW(dis.hDC, PWideChar(text), -1, r, flags);

  if font <> 0 then
    begin
      SelectObject(dis.hDC, oldFont);
      DeleteObject(font);
    end;
end;

// Paints what Windows leaves of the bar after the items: the empty part on the right,
// and the light line under the bar.
procedure PaintMenuBarRest(h: HWND);
var
  mbi, last : TMenuBarInfo;
  rcClient, rcWindow, rcFill, rcLine : TRect;
  dc : HDC;
  count : integer;
begin
  FillChar(mbi, SizeOf(mbi), 0);
  mbi.cbSize := SizeOf(mbi);
  if not GetMenuBarInfo(h, OBJID_MENU, 0, mbi) then Exit;
  GetWindowRect(h, rcWindow);

  rcFill := mbi.rcBar;
  count := GetMenuItemCount(GetMenu(h));
  if count > 0 then
    begin
      FillChar(last, SizeOf(last), 0);
      last.cbSize := SizeOf(last);
      if GetMenuBarInfo(h, OBJID_MENU, count, last) then rcFill.Left := last.rcBar.Right;
    end;
  OffsetRect(rcFill, -rcWindow.Left, -rcWindow.Top);

  GetClientRect(h, rcClient);
  MapWindowPoints(h, 0, rcClient, 2);
  OffsetRect(rcClient, -rcWindow.Left, -rcWindow.Top);
  rcLine := rcClient;
  rcLine.Bottom := rcLine.Top;
  rcLine.Top := rcLine.Top - 1;

  dc := GetWindowDC(h);
  FillRect(dc, rcFill, BarBrush);
  FillRect(dc, rcLine, BarBrush);
  ReleaseDC(h, dc);
end;

function FormProc(h: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
begin
  if Themed and (msg = WM_DRAWITEM) then
    if IsBarItem(h, PDrawItemStruct(lp)^) then
      begin
        DrawBarItem(h, PDrawItemStruct(lp)^);
        Exit(1);
      end;

  Result := CallWindowProcW(FormOldProc, h, msg, wp, lp);

  if Themed and ((msg = WM_NCPAINT) or (msg = WM_NCACTIVATE)) then PaintMenuBarRest(h);
end;

//------------------------------------------------------------------------------------------------
//  tab headers
//------------------------------------------------------------------------------------------------

procedure PaintTabs(h: HWND);
var
  ps : TPaintStruct;
  dc : HDC;
  rc, r : TRect;
  i, count, sel : integer;
  item : TTabItemW;
  buf : array [0..127] of WideChar;
  brush, border : HBRUSH;
  oldFont : HFONT;
  headerBottom : integer;
begin
  dc := BeginPaint(h, ps);
  try
    GetClientRect(h, rc);
    FillRect(dc, rc, BarBrush);

    count := SendMessage(h, TCM_GETITEMCOUNT, 0, 0);
    sel := SendMessage(h, TCM_GETCURSEL, 0, 0);
    oldFont := SelectObject(dc, SendMessage(h, WM_GETFONT, 0, 0));
    SetBkMode(dc, TRANSPARENT);

    headerBottom := 0;
    for i := 0 to count - 1 do
      begin
        FillChar(r, SizeOf(r), 0);
        SendMessage(h, TCM_GETITEMRECT, i, LPARAM(@r));
        if r.Bottom > headerBottom then headerBottom := r.Bottom;

        if i = sel then brush := SelectedBrush else brush := BarBrush;
        FillRect(dc, r, brush);

        FillChar(item, SizeOf(item), 0);
        item.mask := TCIF_TEXT;
        item.pszText := @buf[0];
        item.cchTextMax := 127;
        buf[0] := #0;
        SendMessage(h, TCM_GETITEMW, i, LPARAM(@item));

        SetTextColor(dc, BarText);
        DrawTextW(dc, buf, -1, r, DT_CENTER or DT_SINGLELINE or DT_VCENTER);

        if i = sel then // accent line on top of the selected tab
          begin
            border := CreateSolidBrush(AccentColor);
            FillRect(dc, Classes.Rect(r.Left, r.Top, r.Right, r.Top + 2), border);
            DeleteObject(border);
          end;
      end;

    // line between the headers and the page
    border := CreateSolidBrush(Mix(BarColor, BarText, 30));
    FillRect(dc, Classes.Rect(rc.Left, headerBottom, rc.Right, headerBottom + 1), border);
    DeleteObject(border);

    SelectObject(dc, oldFont);
  finally
    EndPaint(h, ps);
  end;
end;

function TabsProc(h: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
begin
  if Themed then
    case msg of
      WM_ERASEBKGND : Exit(1);
      WM_PAINT      : begin PaintTabs(h); Exit(0); end;
    end;
  Result := CallWindowProcW(TabsOldProc, h, msg, wp, lp);
end;

//------------------------------------------------------------------------------------------------

procedure Subclass(h: HWND; var oldHandle: HWND; var oldProc: Pointer; proc: Pointer);
begin
  if h = oldHandle then Exit;               // already done for this window
  oldHandle := h;
  oldProc := Pointer(SetWindowLongPtrW(h, GWL_WNDPROC, PtrInt(proc)));
end;

procedure ChromeUpdate(Form: TForm; Tabs: TPageControl; enabled: boolean;
  bar, barText, selected, accent: TColor);
var
  dark : integer;
  caption, text : COLORREF;
begin
  Themed := enabled;
  BarColor := ColorToRGB(bar);
  BarText := ColorToRGB(barText);
  SelectedColor := ColorToRGB(selected);
  AccentColor := ColorToRGB(accent);
  MakeBrushes;

  if not Form.HandleAllocated then Exit;
  FormMenu := Form.Menu;
  Subclass(Form.Handle, FormWnd, FormOldProc, @FormProc);
  if Assigned(Tabs) and Tabs.HandleAllocated then
    Subclass(Tabs.Handle, TabsWnd, TabsOldProc, @TabsProc);

  // title bar
  if enabled and IsDark(BarColor) then dark := 1 else dark := 0;
  DwmSetWindowAttribute(Form.Handle, DWMWA_USE_IMMERSIVE_DARK_MODE, @dark, SizeOf(dark));
  if enabled then
    begin
      caption := BarColor;
      text := BarText;
    end
  else
    begin
      caption := DWMWA_COLOR_DEFAULT;
      text := DWMWA_COLOR_DEFAULT;
    end;
  DwmSetWindowAttribute(Form.Handle, DWMWA_CAPTION_COLOR, @caption, SizeOf(caption));
  DwmSetWindowAttribute(Form.Handle, DWMWA_TEXT_COLOR, @text, SizeOf(text));

  // repaint the menu bar, the frame and the tabs
  DrawMenuBar(Form.Handle);
  SetWindowPos(Form.Handle, 0, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED);
  RedrawWindow(Form.Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME or RDW_ALLCHILDREN);
  if Assigned(Tabs) and Tabs.HandleAllocated then
    InvalidateRect(Tabs.Handle, nil, True);
end;

procedure ChromeDarkScrollbars(Control: TWinControl; dark: boolean);
begin
  if not Control.HandleAllocated then Exit;
  if dark then SetWindowTheme(Control.Handle, 'DarkMode_Explorer', nil)
          else SetWindowTheme(Control.Handle, nil, nil);
end;

{$else}

procedure ChromeUpdate(Form: TForm; Tabs: TPageControl; enabled: boolean;
  bar, barText, selected, accent: TColor);
begin
end;

procedure ChromeDarkScrollbars(Control: TWinControl; dark: boolean);
begin
end;

{$endif}

end.
