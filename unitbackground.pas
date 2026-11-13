{$mode delphi}{$H+}
unit UnitBackground;

// Background pictures for the text areas (Windows).
//
// A rich edit control cannot show a picture behind its text, so the window procedure of the
// control is subclassed. When the control has to be painted, the control draws itself (text and
// colors) into an off-screen bitmap with WM_PRINTCLIENT, and every pixel that still has the plain
// background color of the control is replaced by the picture. The picture is dimmed towards the
// background color, so that the text stays easy to read, and the selection and the highlighted
// verses (which have other colors) are untouched.
//
// On other systems the procedures do nothing.

interface

uses
  Classes, SysUtils, Graphics, Controls;

const
  bgCover = 0;    // the picture covers the area, the edges are cut
  bgStretch = 1;  // the picture is stretched to the area
  bgTile = 2;     // the picture is repeated

// FileName = '' removes the picture. visibility: 5..100 (how much of the picture is seen).
procedure BackgroundSet(const FileName: string; visibility, mode: integer; background: TColor);
function  BackgroundLoaded: boolean;

// attaches the picture to a control; to be called again when its window has been recreated
procedure BackgroundAttach(Control: TWinControl);
procedure BackgroundRefresh(Control: TWinControl);

implementation

{$ifdef windows}

uses
  Windows, Messages;

const
  MaxControls = 16;

type
  TAttached = record
    Wnd : HWND;
    OldProc : Pointer;
    Bitmap : HBITMAP;      // the dimmed picture, as big as the client area of the control
    Bits : PDWORD;
    Width, Height : integer;
    Generation : integer;
  end;

function PrintWindow(hwnd: HWND; hdcBlt: HDC; flags: UINT): BOOL;
  stdcall; external 'user32.dll';
function SetWindowLongPtrW(hwnd: HWND; index: integer; value: PtrInt): PtrInt;
  stdcall; external 'user32.dll';
function CallWindowProcW(prev: Pointer; hwnd: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): LRESULT;
  stdcall; external 'user32.dll';

var
  Source : TPicture = nil;
  Visibility : integer = 25;
  Mode : integer = bgCover;
  BackgroundColorRef : COLORREF = $FFFFFF;
  Generation : integer = 0;
  Attached : array [0..MaxControls - 1] of TAttached;
  AttachedCount : integer = 0;

function BackgroundLoaded: boolean;
begin
  Result := Assigned(Source) and (Source.Width > 0) and (Source.Height > 0);
end;

procedure BackgroundSet(const FileName: string; visibility, mode: integer; background: TColor);
begin
  if Visibility < 0 then Visibility := 0;
  UnitBackground.Visibility := visibility;
  UnitBackground.Mode := mode;
  BackgroundColorRef := ColorToRGB(background);

  FreeAndNil(Source);
  if (FileName <> '') and FileExists(FileName) then
    begin
      Source := TPicture.Create;
      try
        Source.LoadFromFile(FileName);
      except
        FreeAndNil(Source);
      end;
    end;

  Inc(Generation); // every control builds its picture again
end;

// builds the picture for a control of this size: scaled, then dimmed towards the background color
procedure BuildPicture(var A: TAttached; w, h: integer);
var
  info : TBitmapInfo;
  dc, sdc, ddc : HDC;
  oldS, oldD : HGDIOBJ;
  iw, ih, dw, dh, x, y, i : integer;
  scale : double;
  p : PDWORD;
  br, bg_, bb, r, g, b, v : integer;
  c : DWORD;
begin
  if A.Bitmap <> 0 then DeleteObject(A.Bitmap);
  A.Bitmap := 0;
  A.Bits := nil;
  A.Width := w;
  A.Height := h;
  A.Generation := Generation;
  if (w < 1) or (h < 1) or not BackgroundLoaded then Exit;

  FillChar(info, SizeOf(info), 0);
  info.bmiHeader.biSize := SizeOf(info.bmiHeader);
  info.bmiHeader.biWidth := w;
  info.bmiHeader.biHeight := -h;           // top-down
  info.bmiHeader.biPlanes := 1;
  info.bmiHeader.biBitCount := 32;
  info.bmiHeader.biCompression := BI_RGB;

  dc := GetDC(0);
  A.Bitmap := CreateDIBSection(dc, info, DIB_RGB_COLORS, Pointer(A.Bits), 0, 0);
  ReleaseDC(0, dc);
  if (A.Bitmap = 0) or (A.Bits = nil) then Exit;

  // fill with the background color, then draw the picture
  p := A.Bits;
  c := (GetRValue(BackgroundColorRef) shl 16) or (GetGValue(BackgroundColorRef) shl 8) or GetBValue(BackgroundColorRef);
  for i := 0 to w * h - 1 do
    begin
      p^ := c;
      Inc(p);
    end;

  dc := GetDC(0);
  ddc := CreateCompatibleDC(dc);
  sdc := CreateCompatibleDC(dc);
  ReleaseDC(0, dc);
  oldD := SelectObject(ddc, A.Bitmap);
  oldS := SelectObject(sdc, Source.Bitmap.Handle);
  try
    iw := Source.Bitmap.Width;
    ih := Source.Bitmap.Height;
    SetStretchBltMode(ddc, HALFTONE);
    SetBrushOrgEx(ddc, 0, 0, nil);

    case Mode of
      bgStretch :
        StretchBlt(ddc, 0, 0, w, h, sdc, 0, 0, iw, ih, SRCCOPY);
      bgTile :
        begin
          y := 0;
          while y < h do
            begin
              x := 0;
              while x < w do
                begin
                  BitBlt(ddc, x, y, iw, ih, sdc, 0, 0, SRCCOPY);
                  x += iw;
                end;
              y += ih;
            end;
        end;
    else
      begin // cover
        scale := w / iw;
        if h / ih > scale then scale := h / ih;
        dw := Round(iw * scale);
        dh := Round(ih * scale);
        StretchBlt(ddc, (w - dw) div 2, (h - dh) div 2, dw, dh, sdc, 0, 0, iw, ih, SRCCOPY);
      end;
    end;
    GdiFlush;
  finally
    SelectObject(sdc, oldS);
    SelectObject(ddc, oldD);
    DeleteDC(sdc);
    DeleteDC(ddc);
  end;

  // dim: background + (picture - background) * visibility / 100
  br := GetRValue(BackgroundColorRef);
  bg_ := GetGValue(BackgroundColorRef);
  bb := GetBValue(BackgroundColorRef);
  v := Visibility;
  p := A.Bits;
  for i := 0 to w * h - 1 do
    begin
      c := p^;
      r := (c shr 16) and $FF;
      g := (c shr 8) and $FF;
      b := c and $FF;
      r := br + (r - br) * v div 100;
      g := bg_ + (g - bg_) * v div 100;
      b := bb + (b - bb) * v div 100;
      p^ := (DWORD(r) shl 16) or (DWORD(g) shl 8) or DWORD(b);
      Inc(p);
    end;
end;

function FindAttached(h: HWND): integer;
var
  i : integer;
begin
  for i := 0 to AttachedCount - 1 do
    if Attached[i].Wnd = h then Exit(i);
  Result := -1;
end;

procedure PaintControl(h: HWND; index: integer);
var
  dc, mdc : HDC;
  rc : TRect;
  w, hh, i, n : integer;
  info : TBitmapInfo;
  tbmp : HBITMAP;
  tbits : PDWORD;
  old : HGDIOBJ;
  key : DWORD;
  p, q : PDWORD;
begin
  GetClientRect(h, rc);
  w := rc.Right - rc.Left;
  hh := rc.Bottom - rc.Top;

  if (w < 1) or (hh < 1) then
    begin
      CallWindowProcW(Attached[index].OldProc, h, WM_PAINT, 0, 0);
      Exit;
    end;

  if (Attached[index].Width <> w) or (Attached[index].Height <> hh) or
     (Attached[index].Generation <> Generation) then
    BuildPicture(Attached[index], w, hh);

  // the picture does not scroll with the text, so the whole area is always painted again
  InvalidateRect(h, nil, False);

  // the control paints itself on the screen: text, colors, selection
  CallWindowProcW(Attached[index].OldProc, h, WM_PAINT, 0, 0);

  if Attached[index].Bits = nil then Exit;

  // read the pixels back, put the picture where the plain background color is, write them again
  FillChar(info, SizeOf(info), 0);
  info.bmiHeader.biSize := SizeOf(info.bmiHeader);
  info.bmiHeader.biWidth := w;
  info.bmiHeader.biHeight := -hh;
  info.bmiHeader.biPlanes := 1;
  info.bmiHeader.biBitCount := 32;
  info.bmiHeader.biCompression := BI_RGB;

  dc := GetDC(h);
  try
    mdc := CreateCompatibleDC(dc);
    tbits := nil;
    tbmp := CreateDIBSection(dc, info, DIB_RGB_COLORS, Pointer(tbits), 0, 0);
    if (tbmp = 0) or (tbits = nil) then
      begin
        DeleteDC(mdc);
        Exit;
      end;
    old := SelectObject(mdc, tbmp);
    try
      BitBlt(mdc, 0, 0, w, hh, dc, 0, 0, SRCCOPY);

      key := (GetRValue(BackgroundColorRef) shl 16) or (GetGValue(BackgroundColorRef) shl 8) or
             GetBValue(BackgroundColorRef);
      p := tbits;
      q := Attached[index].Bits;
      n := w * hh;
      for i := 1 to n do
        begin
          if (p^ and $00FFFFFF) = key then p^ := q^;
          Inc(p);
          Inc(q);
        end;

      BitBlt(dc, 0, 0, w, hh, mdc, 0, 0, SRCCOPY);
    finally
      SelectObject(mdc, old);
      DeleteObject(tbmp);
      DeleteDC(mdc);
    end;
  finally
    ReleaseDC(h, dc);
  end;
end;

function BackgroundProc(h: HWND; msg: UINT; wp: WPARAM; lp: LPARAM): LRESULT; stdcall;
var
  index : integer;
begin
  index := FindAttached(h);
  if index < 0 then Exit(DefWindowProc(h, msg, wp, lp));

  if BackgroundLoaded then
    case msg of
      WM_ERASEBKGND : Exit(1);
      WM_PAINT      : begin PaintControl(h, index); Exit(0); end;
    end;

  Result := CallWindowProcW(Attached[index].OldProc, h, msg, wp, lp);
end;

procedure BackgroundAttach(Control: TWinControl);
begin
  if (Control = nil) or not Control.HandleAllocated then Exit;
  if FindAttached(Control.Handle) >= 0 then Exit;
  if AttachedCount >= MaxControls then Exit;

  FillChar(Attached[AttachedCount], SizeOf(TAttached), 0);
  Attached[AttachedCount].Wnd := Control.Handle;
  Attached[AttachedCount].OldProc := Pointer(SetWindowLongPtrW(Control.Handle, GWL_WNDPROC, PtrInt(@BackgroundProc)));
  Inc(AttachedCount);
end;

procedure BackgroundRefresh(Control: TWinControl);
begin
  if (Control = nil) or not Control.HandleAllocated then Exit;
  InvalidateRect(Control.Handle, nil, True);
end;

{$else}

function BackgroundLoaded: boolean;
begin
  Result := False;
end;

procedure BackgroundSet(const FileName: string; visibility, mode: integer; background: TColor);
begin
end;

procedure BackgroundAttach(Control: TWinControl);
begin
end;

procedure BackgroundRefresh(Control: TWinControl);
begin
end;

{$endif}

end.
