unit FormMain;

interface

uses
  Classes, Fgl, SysUtils, LazFileUtils, LazUTF8, Forms, Controls, Graphics,
  Dialogs, StdCtrls, Menus, ExtCtrls, ComCtrls, IniFiles, LCLIntf, LCLType,
  LCLProc, ActnList, ClipBrd, StdActns, Buttons, PrintersDlgs,
  RichMemo, UnboundMemo, UnitUtils, UnitLib;

const
  noteShow  = 0; // grey notes shown in the text
  noteHover = 1; // grey notes collapsed to [+n], hover over one to read it
  noteHide  = 2; // grey notes hidden

type
  TStatuses = TFPGMap<integer, string>;

  { TMainForm }

  TMainForm = class(TForm)
    ToolEdit: TEdit;
    IdleTimer: TIdleTimer;
    Panel1: TPanel;
    MainMenu: TMainMenu;
    PopupMenu: TPopupMenu;
    PopupTabs: TPopupMenu;
    PrintDialog: TPrintDialog;
    FontDialog: TFontDialog;
    FontDialogNotes: TFontDialog;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    ComboBox: TComboBox;
    FileOpen1: TFileOpen;
    EditCut1: TEditCut;

    MemoBible: TUnboundMemo;
    MemoCommentary: TUnboundMemo;
    MemoCompare: TUnboundMemo;
    MemoDictionary: TUnboundMemo;
    MemoHistory: TUnboundMemo;
    MemoNotes: TUnboundMemo;
    MemoReference: TUnboundMemo;
    MemoSearch: TUnboundMemo;

    ActionAbout: THelpAction;
    ActionBold: TAction;
    ActionBullets: TAction;
    ActionCenter: TAction;
    ActionCleanHistory: TAction;
    ActionCommentaries: TAction;
    ActionCompare: TAction;
    ActionCopyAs: TAction;
    ActionCopyVerses: TAction;
    ActionDecrease: TAction;
    ActionDictionaries: TAction;
    ActionEditCopy: TAction;
    ActionEditCut: TAction;
    ActionEditDel: TAction;
    ActionEditFont: TAction;
    ActionEditPaste: TAction;
    ActionEditSelAll: TEditSelectAll;
    ActionEditUndo: TAction;
    ActionExit: TAction;
    ActionFileNew: TAction;
    ActionFileOpen: TAction;
    ActionFilePrint: TAction;
    ActionFileSave: TAction;
    ActionFileSaveAs: TAction;
    ActionFont: TAction;
    ActionHistory: TAction;
    ActionHistoryLeft: TAction;
    ActionHistoryRight: TAction;
    ActionIncrease: TAction;
    ActionInterlinear: TAction;
    ActionItalic: TAction;
    ActionLeft: TAction;
    ActionLink: TAction;
    ActionList: TActionList;
    ActionLookup: TAction;
    ActionModules: TAction;
    ActionOptions: TAction;
    ActionReference: TAction;
    ActionRight: TAction;
    ActionSearch: TAction;
    ActionSearchfor: TAction;
    ActionUnderline: TAction;

    ChapterBox: TListBox;
    BookBox: TListBox;
    Ruler: TPanel;
    PanelLeft: TPanel;
    Splitter1: TSplitter;
    StatusBar: TStatusBar;
    Images: TImageList;

    PageControl: TPageControl;
    TabSheetReference: TTabSheet;
    TabSheetBible: TTabSheet;
    TabSheetSearch: TTabSheet;
    TabSheetCompare: TTabSheet;
    TabSheetCommentary: TTabSheet;
    TabSheetDictionary: TTabSheet;
    TabSheetHistory: TTabSheet;
    TabSheetNotes: TTabSheet;

    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;

    miBibleFolder: TMenuItem;
    miClear: TMenuItem;
    miCommentaries: TMenuItem;
    miCompare: TMenuItem;
    miCopy: TMenuItem;
    miCopyAs: TMenuItem;
    miCut: TMenuItem;
    miDictionaries: TMenuItem;
    miDonate: TMenuItem;
    miDownload: TMenuItem;
    miEdit: TMenuItem;
    miExit: TMenuItem;
    miHelp: TMenuItem;
    miHelpAbout: TMenuItem;
    miHistory: TMenuItem;
    miHome: TMenuItem;
    miInterlinear: TMenuItem;
    miIssue: TMenuItem;
    miModules: TMenuItem;
    miNoteNew: TMenuItem;
    miNoteOpen: TMenuItem;
    miNoteSave: TMenuItem;
    miNoteSaveAs: TMenuItem;
    miNotes: TMenuItem;
    miOptions: TMenuItem;
    miPaste: TMenuItem;
    miPrint: TMenuItem;
    miRecent: TMenuItem;
    miRrefx: TMenuItem;
    miSearch: TMenuItem;
    miSelectAll: TMenuItem;
    miTools: TMenuItem;
    miUndo: TMenuItem;
    miVerses: TMenuItem;

    MenuItem2: TMenuItem;
    pmClose: TMenuItem;
    pmCopy: TMenuItem;
    pmCopyAs: TMenuItem;
    pmCut: TMenuItem;
    pmCleanHistory: TMenuItem;
    pmLookup: TMenuItem;
    pmPaste: TMenuItem;
    pmSearchfor: TMenuItem;
    pmSeparator2: TMenuItem;
    pmSeparatorH: TMenuItem;
    pmSeparator: TMenuItem;
    pmVerses: TMenuItem;

    StandardToolBar: TToolBar;
    ToolButtonBold: TToolButton;
    ToolButtonBullets: TToolButton;
    ToolButtonCenter: TToolButton;
    ToolButtonCommentary: TToolButton;
    ToolButtonCopy: TToolButton;
    ToolButtonCut: TToolButton;
    ToolButtonDictionary: TToolButton;
    ToolButtonFont: TToolButton;
    ToolButtonHistory: TToolButton;
    ToolButtonItalic: TToolButton;
    ToolButtonLeft: TToolButton;
    ToolButtonLink: TToolButton;
    ToolButtonNew: TToolButton;
    ToolButtonOpen: TToolButton;
    ToolButtonPaste: TToolButton;
    ToolButtonPrint: TToolButton;
    ToolButtonReference: TToolButton;
    ToolButtonRight: TToolButton;
    ToolButtonSave: TToolButton;
    ToolButtonSearch: TToolButton;
    ToolButtonShelf: TToolButton;
    ToolButtonUnderline: TToolButton;
    ToolButtonUndo: TToolButton;
    ToolButtonVerses: TToolButton;
    ToolPanel: TPanel;
    ToolSeparator1: TToolButton;
    ToolSeparator2: TToolButton;
    ToolSeparator3: TToolButton;
    ToolSeparator4: TToolButton;
    ToolSeparator5: TToolButton;
    ToolSeparator6: TToolButton;

    procedure CmdCleanHistory(Sender: TObject);
    procedure CmdHistory(Sender: TObject);
    procedure CmdReference(Sender: TObject);
    procedure CmdCommentaries(Sender: TObject);
    procedure CmdDictionaries(Sender: TObject);
    procedure CmdAbout(Sender: TObject);
    procedure CmdCompare(Sender: TObject);
    procedure CmdCopyAs(Sender: TObject);
    procedure CmdCopyVerses(Sender: TObject);
    procedure CmdEdit(Sender: TObject);
    procedure CmdExit(Sender: TObject);
    procedure CmdFileNew(Sender: TObject);
    procedure CmdFileOpen(Sender: TObject);
    procedure CmdFilePrint(Sender: TObject);
    procedure CmdFileSave(Sender: TObject);
    procedure CmdFileSaveAs(Sender: TObject);
    procedure CmdInterline(Sender: TObject);
    procedure CmdOptions(Sender: TObject);
    procedure CmdSearch(Sender: TObject);
    procedure CmdSearchFor(Sender: TObject);
    procedure CmdLookup(Sender: TObject);
    procedure CmdStyle(Sender: TObject);
    procedure CmdStyle2(Sender: TObject);
    procedure CmdModules(Sender: TObject);

    procedure ComboBoxChange(Sender: TObject);
    procedure ComboBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
    procedure MemoBibleParagraphChange(Sender: TObject);
    procedure MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ToolEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure StandardToolBarPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure IdleTimerTimer(Sender: TObject);
    procedure BookBoxClick(Sender: TObject);
    procedure ChapterBoxClick(Sender: TObject);
    procedure MemoMouseLeave(Sender: TObject);
    procedure MemoContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure MemoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
    procedure MemoSelectionChange(Sender: TObject);
    procedure miBibleFolderClick(Sender: TObject);
    procedure miDownloadClick(Sender: TObject);
    procedure miHomeClick(Sender: TObject);
    procedure miIssueClick(Sender: TObject);
    procedure miDonateClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure PageControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pmCloseClick(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure ToolButtonDonateClick(Sender: TObject);
    procedure ToolButtonSearchClick(Sender: TObject);
  private
    NoteFileName: string;
    RecentList: TStringArray;
    Statuses: TStatuses;
    IdleMessage : string;
    showed : boolean;
    function UnboundMemo: TUnboundMemo;
    function CheckFileSave: boolean;
    procedure LoadComboBox;
    procedure EnableActions;
    procedure FirstAppearance;
    procedure UpDownButtons;
    procedure SelectBook(title: string; scroll: boolean);
    procedure ShowCurrVerse(select: boolean);
    procedure ShowCurrBible;
    procedure LoadChapter;
    procedure LoadSearch(s: string);
    procedure LoadCompare;
    procedure LoadReference;
    procedure LoadCommentary;
    procedure LoadDictionary(s: string);
    procedure LoadHistory;
    procedure LoadStrong(s: string);
    procedure LoadFootnote(s: string);
    procedure MakeBookList;
    procedure MakeChapterList;
    procedure OnRecentClick(Sender: TObject);
    procedure PerformFileOpen(const FileName: string);
    procedure ReadConfig;
    procedure RebuildRecentList;
    procedure MakeRecentMenu;
    procedure HideCursor;
    procedure SaveConfig;
    procedure SelectPage(page: integer);
    procedure UpdateCaption(s: string);
    procedure RefreshStatus;
    procedure UpdateStatus(s: string);
    procedure UpdateActionImage;
    procedure VersesToClipboard;
    procedure ShowPopup;
    procedure Localize;
  private
    HoverTimer : TTimer;
    HoverIndex : integer;
    GreyNotes : TStringList; // text of the collapsed notes of the chapter on screen
    procedure MemoBibleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
    procedure HoverTimerTick(Sender: TObject);
    procedure ActiveFormChanged(Sender: TObject);
  private
    // bookmarks, shortcuts, zoom, full screen
    miBookmarks : TMenuItem;
    BookmarkList : TStringList; // "book|chapter|number"
    HighlightList : TStringList; // "book|chapter|number=color" (color 1..5)
    NoteList : TStringList;      // "book|chapter|number=text", the notes written by the user
    Voice : Variant;             // Windows speech (SAPI), created when it is first needed
    FullScreenPrevious : TWindowState;
    procedure SaveNotes;
    procedure ReloadUserData;
    function  InsertVerseNotes(const s: string): string;
    procedure VerseNoteEdit(Sender: TObject);
    procedure ShowMyNotes(Sender: TObject);
    procedure ReadAloud(Sender: TObject);
    function  ChapterPlainText: string;
    procedure CopyChapter(Sender: TObject);
    procedure SaveChapterText(Sender: TObject);
    procedure BackupData(Sender: TObject);
    procedure RestoreData(Sender: TObject);
    procedure SaveHighlights;
    procedure ApplyHighlight(number: integer);
    procedure ApplyHighlights;
    procedure ApplySpacing(Memo: TUnboundMemo);
    procedure HighlightSet(Sender: TObject);
    procedure GoDailyVerse(Sender: TObject);
    procedure ReadingPlanClick(Sender: TObject);
    procedure ShowMyVerses(highlights: boolean);
    procedure ShowMyHighlights(Sender: TObject);
    procedure ShowMyBookmarks(Sender: TObject);
    procedure BuildBookmarkMenu;
    procedure SaveBookmarks;
    procedure BookmarkAdd(Sender: TObject);
    procedure BookmarkGo(Sender: TObject);
    procedure BookmarkRemove(Sender: TObject);
    procedure GoChapter(delta: integer);
    procedure ToggleFullScreen;
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure MemoWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint; var Handled: Boolean);
    function ProcessNotes(const s: string; bible: boolean): string;
  public
    ThemeName : string;
    NoteMode : integer; // noteShow, noteHover or noteHide
    SpacingIndex : integer;  // line spacing: 0 normal, 1 relaxed, 2 wide, 3 double
    DailyVerse : boolean;    // go to the verse of the day when the program starts
    procedure GoToChapter(book, chapter: integer);
    procedure SaveSettings; // writes config.ini now (the font, theme... must survive a crash)
    procedure Redraw;
    procedure ThemeWindow;
    procedure ThemeForm(Form: TCustomForm);
    procedure AssignFont;
    procedure ApplyTheme(reload: boolean = True);
    procedure LocalizeApplication;
  end;

var
  MainForm: TMainForm;

implementation

uses
  {$ifdef windows} UmParseWin, ComObj, {$endif} Variants,
  FormAbout, FormNotify, FormSearch, FormOptions, FormCopy, FormShelf,
  UnitTools, UnitLocal, UnitModule, UnitBible, UnitCommentary, UnitDictionary,
  UnitTheme, UnitFonts, UnitChrome, UnitChromeIcons, UnitPlan, FormPlan;

var
  TextColor : TColor = clWindowText;
  TextBackground : TColor = clWindow;
  Chrome : TColor = clForm;        // window, panels and toolbar
  ChromeText : TColor = clDefault;


const
  SpacingValues : array [0..3] of double = (1.2, 1.4, 1.6, 2.0);

  // highlight colors (BGR): yellow, green, blue, pink, orange
  HighlightColors : array [1..5] of TColor = ($5CE4FF, $94D68F, $F0C87E, $C8A6F4, $6BB8FF);

  // verses of the day, as book * 1000000 + chapter * 1000 + verse
  DailyVerses : array [0..75] of integer = (
    1001001, 1028015, 2014014, 5031006, 6001009, 9016007, 19023001, 19027001, 19034008, 19037004,
    19046001, 19046010, 19091001, 19118024, 19119105, 19121002, 19139014, 20003005, 20016003, 20018010,
    20022006, 21003001, 23026003, 23040031, 23041010, 23043002, 23053005, 24017007, 24029011, 25003022,
    33006008, 34001007, 35003019, 36003017, 40005016, 40006033, 40007007, 40011028, 40028020, 41010027,
    42001037, 43001001, 43003016, 43008012, 43010010, 43014006, 43014027, 43015005, 43016033, 44001008,
    45005008, 45008028, 45008037, 45012002, 45015013, 46010013, 46013013, 47005017, 47012009, 48002020,
    48005022, 49002008, 49006010, 50004006, 50004013, 51003023, 52005016, 55001007, 58011001, 58012001,
    59001005, 60005007, 62004019, 66021004, 19100004, 20003006);

function MixColors(a, b: TColor; percent: integer): TColor;
begin
  a := ColorToRGB(a);
  b := ColorToRGB(b);
  Result := RGBToColor(Red(a) + (Red(b) - Red(a)) * percent div 100,
                       Green(a) + (Green(b) - Green(a)) * percent div 100,
                       Blue(a) + (Blue(b) - Blue(a)) * percent div 100);
end;

function IsDarkBackground(c: TColor): boolean;
begin
  c := ColorToRGB(c);
  Result := Red(c) * 3 + Green(c) * 6 + Blue(c) < 1280;
end;

// a verse as plain text: no tags, no footnote markers
function PlainVerse(s: string): string;
var
  a, b : integer;
begin
  repeat
    a := Pos('<f>', s);
    if a = 0 then Break;
    b := Pos('</f>', s);
    if b < a then Break;
    Delete(s, a, b + 4 - a);
  until False;
  Result := Trim(RemoveTags(s));
end;

// copies (or replaces) one section of an ini file into another
procedure CopySection(Source, Target: TIniFile; const Section: string);
var
  Keys : TStringList;
  key : string;
begin
  Keys := TStringList.Create;
  try
    Source.ReadSection(Section, Keys);
    Target.EraseSection(Section);
    for key in Keys do
      Target.WriteString(Section, key, Source.ReadString(Section, key, ''));
  finally
    Keys.Free;
  end;
end;

type
  TControlHack = class(TControl); // gives access to the protected Color / ParentColor

  TChromeOriginal = class
    Color, FontColor : TColor;
    ParentColor, ParentFont : boolean;
  end;

var
  ChromeOriginals : TStringList = nil;

// Paints a control with the theme colors; restores its own colors for "System default".
procedure ApplyChrome(Control: TControl; themed: boolean);
var
  i : integer;
  Orig : TChromeOriginal;
begin
  if ChromeOriginals = nil then
    begin
      ChromeOriginals := TStringList.Create;
      ChromeOriginals.OwnsObjects := True;
    end;

  i := ChromeOriginals.IndexOf(Control.Name);
  if i < 0 then
    begin
      Orig := TChromeOriginal.Create;
      Orig.Color       := TControlHack(Control).Color;
      Orig.ParentColor := TControlHack(Control).ParentColor;
      Orig.FontColor   := Control.Font.Color;
      Orig.ParentFont  := TControlHack(Control).ParentFont;
      ChromeOriginals.AddObject(Control.Name, Orig);
    end
  else
    Orig := TChromeOriginal(ChromeOriginals.Objects[i]);

  if themed then
    begin
      TControlHack(Control).Color := Chrome;
      Control.Font.Color := ChromeText;
    end
  else
    begin
      TControlHack(Control).Color := Orig.Color;
      TControlHack(Control).ParentColor := Orig.ParentColor;
      Control.Font.Color := Orig.FontColor;
      if not (Control is TCustomForm) then // the main form carries the font chosen in Options
        TControlHack(Control).ParentFont := Orig.ParentFont;
    end;
end;

var
  ImagesOriginal : TImageList = nil; // the toolbar icons as they come, before they are lightened
  PopupColor, PopupMemoColor, PopupTitleColor : TColor;
  PopupSaved : boolean = False;

procedure ThemePopup; // colors of the footnote / Strong's popup
begin
  if not Assigned(NotifyForm) then Exit;

  if not PopupSaved then // remember the original look to restore it for "System default"
    begin
      PopupColor := NotifyForm.Color;
      PopupMemoColor := NotifyForm.Memo.Color;
      PopupTitleColor := NotifyForm.Title.Font.Color;
      PopupSaved := True;
    end;

  if Assigned(NotifyForm.PopupMenu) then ChromeMenu(NotifyForm.PopupMenu, ThemeEnabled);

  if ThemeEnabled then
    begin
      NotifyForm.Color := Chrome;
      NotifyForm.Title.Font.Color := ChromeText;
      NotifyForm.Memo.Color := TextBackground;
      NotifyForm.Memo.Font.Color := TextColor;
    end
  else
    begin
      NotifyForm.Color := PopupColor;
      NotifyForm.Title.Font.Color := PopupTitleColor;
      NotifyForm.Memo.Color := PopupMemoColor;
      NotifyForm.Memo.Font.Color := clWindowText;
    end;
end;

const
  apBible       = 0; // active page
  apSearch       = 1;
  apCompare      = 2;
  apReferences   = 3;
  apCommentaries = 4;
  apDictionaries = 5;
  apHistory      = 6;
  apNotes        = 7;

{$R *.lfm}

//=================================================================================================
//                                     Create Main Form
//=================================================================================================

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Localization := TLocalization.Create;
  Statuses := TStatuses.Create;

  Caption := ApplicationName + ' ' + ApplicationVersion;
  RecentList := [];
  showed := False;

  SaveDialog.InitialDir := DocumentsPath;
  NoteFileName := Untitled;

  GreyNotes := TStringList.Create;
  HoverTimer := TTimer.Create(Self);
  HoverTimer.Enabled := False;
  HoverTimer.Interval := 300;
  HoverTimer.OnTimer := HoverTimerTick;
  MemoBible.OnMouseMove := MemoBibleMouseMove;
  Screen.OnActiveFormChange := ActiveFormChanged;

  KeyPreview := True;
  OnKeyDown := FormKeyDown;
  MemoBible.OnMouseWheel := MemoWheel;
  MemoCompare.OnMouseWheel := MemoWheel;
  MemoCommentary.OnMouseWheel := MemoWheel;
  MemoDictionary.OnMouseWheel := MemoWheel;
  MemoReference.OnMouseWheel := MemoWheel;
  MemoSearch.OnMouseWheel := MemoWheel;
  MemoHistory.OnMouseWheel := MemoWheel;

  BookmarkList := TStringList.Create;
  HighlightList := TStringList.Create;
  NoteList := TStringList.Create;
  Voice := Unassigned;
  miBookmarks := TMenuItem.Create(Self);
  miBookmarks.Caption := 'Bookmarks'; // translated later by Localize (T() is not ready yet)
  MainMenu.Items.Insert(MainMenu.Items.IndexOf(miHelp), miBookmarks);

  LoadFonts; // bundled and user fonts, before the saved font is selected
  ReadConfig;
  ApplyTheme(False);
  MakeRecentMenu;

  NoteFileName := Untitled;
  MemoNotes.Lines.Clear;
  MemoNotes.Font.Size := Font.Size;
  IdleMessage := '';

  ShowCurrBible;

  {$ifdef windows}
    TabSheetSearch    .TabVisible := False;
    TabSheetReference .TabVisible := False;
    TabSheetCommentary.TabVisible := False;
    TabSheetDictionary.TabVisible := False;
    TabSheetHistory   .TabVisible := False;
    IdleTimer.Interval := 50;
  {$endif}

  {$ifdef linux}
    StandardToolBar.ParentColor := True;
    ToolPanel.Color := clForm;
    ActionFilePrint.Visible := False;
    ActionEditUndo.Visible := False;
    ActionBullets.Visible := False;
    ToolSeparator6.Visible := False;
  {$endif}

  {$ifndef darwin} UpdateActionImage; {$endif}
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  SaveConfig;
  GreyNotes.Free;
  BookmarkList.Free;
  HighlightList.Free;
  NoteList.Free;
  Statuses.Free;
  Localization.Free;
end;

procedure TMainForm.FirstAppearance;
begin
  LocalizeApplication;
  {$ifdef linux}
    TabSheetSearch    .TabVisible := False;
    TabSheetReference .TabVisible := False;
    TabSheetCommentary.TabVisible := False;
    TabSheetDictionary.TabVisible := False;
    TabSheetHistory   .TabVisible := False;
    ShowCurrVerse(CurrVerse.number > 1);
  {$endif}
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  if not showed then FirstAppearance;
  if not showed then ThemeWindow; // the window handle exists now
  if not showed and DailyVerse then GoDailyVerse(nil);
  showed := True;
  {$ifdef windows} IdleMessage := 'HideCursor'; {$endif}
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  {$ifdef linux}
    MemoBible     .Clear;
    MemoCommentary.Clear;
    MemoCompare   .Clear;
    MemoDictionary.Clear;
    MemoHistory   .Clear;
    MemoNotes     .Clear;
    MemoReference .Clear;
    MemoSearch    .Clear;
  {$endif}
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  try
    CanClose := CheckFileSave;
  except
    CanClose := False;
  end;
end;

procedure TMainForm.StandardToolBarPaint(Sender: TObject);
begin
  ToolPanel.Width := StandardToolBar.Width - ToolButtonRight.Width - ToolButtonSearch.Width
                   - {$ifdef linux} ToolButtonRight.Left {$else} ToolButtonBullets.Left {$endif};
  ToolEdit.Left := StandardToolBar.Width - ToolButtonSearch.Width - ToolEdit.Width - 4;
  ToolEdit.Visible := ToolPanel.Width > ToolEdit.Width;
end;

procedure TMainForm.MemoMouseLeave(Sender: TObject);
var
  Point : TPoint;
begin
  if NotifyForm.Visible then
    begin
      Point := UnboundMemo.ScreenToClient(Mouse.CursorPos);
      if (Point.x <= 0) or (Point.x >= UnboundMemo.Width  - 30) or
         (Point.y <= 0) or (Point.y >= UnboundMemo.Height - 30) then NotifyForm.Close;
    end;
end;

procedure TMainForm.AssignFont;
begin
  MemoBible.Font.Assign(Font);
  MemoCommentary.Font.Assign(Font);
  MemoCompare.Font.Assign(Font);
  MemoDictionary.Font.Assign(Font);
  MemoHistory.Font.Assign(Font);
  MemoReference.Font.Assign(Font);
  MemoSearch.Font.Assign(Font);
  MemoNotes.Font.Color := TextColor; // Font.Assign above resets the color, so set it again
  MemoBible.Font.Color := TextColor;
  MemoCommentary.Font.Color := TextColor;
  MemoCompare.Font.Color := TextColor;
  MemoDictionary.Font.Color := TextColor;
  MemoHistory.Font.Color := TextColor;
  MemoReference.Font.Color := TextColor;
  MemoSearch.Font.Color := TextColor;
end;

procedure TMainForm.ApplyTheme(reload: boolean);
var
  Theme : TTheme;

  procedure PaintMemo(Memo: TUnboundMemo);
  begin
    Memo.Color := TextBackground;
  end;

  procedure PaintBox(Box: TWinControl);
  begin
    Box.Color := TextBackground;
    Box.Font.Color := TextColor;
  end;

  procedure PaintChrome(Control: TControl);
  begin
    ApplyChrome(Control, ThemeEnabled);
  end;

  function Blend(a, b: TColor; percent: integer): TColor;
  begin
    a := ColorToRGB(a);
    b := ColorToRGB(b);
    Result := RGBToColor(Red(a) + (Red(b) - Red(a)) * percent div 100,
                         Green(a) + (Green(b) - Green(a)) * percent div 100,
                         Blue(a) + (Blue(b) - Blue(a)) * percent div 100);
  end;

begin
  if (ThemeName <> SystemThemeName) and LoadTheme(ThemeName, Theme) then
    begin
      ActivateTheme(Theme);
      TextColor := Theme.text;
      TextBackground := Theme.background;
    end
  else
    begin
      ThemeName := SystemThemeName;
      DeactivateTheme;
      TextColor := clWindowText;
      TextBackground := clWindow;
    end;

  PaintMemo(MemoBible);     PaintMemo(MemoCommentary); PaintMemo(MemoCompare);
  PaintMemo(MemoDictionary); PaintMemo(MemoHistory);   PaintMemo(MemoReference);
  PaintMemo(MemoSearch);    PaintMemo(MemoNotes);

  PaintBox(ComboBox); PaintBox(BookBox); PaintBox(ChapterBox);

  // the rest of the window: panels, toolbar, status bar, search box
  if ThemeEnabled then
    begin
      Chrome := Blend(TextBackground, TextColor, 10);
      ChromeText := TextColor;
    end
  else
    begin
      Chrome := clForm;
      ChromeText := clDefault;
    end;

  PaintChrome(Self);
  PaintChrome(PanelLeft); PaintChrome(Panel1); PaintChrome(Ruler); PaintChrome(ToolPanel);
  PaintChrome(StandardToolBar); PaintChrome(StatusBar); PaintChrome(PageControl);
  PaintChrome(TabSheetBible); PaintChrome(TabSheetSearch); PaintChrome(TabSheetCompare);
  PaintChrome(TabSheetReference); PaintChrome(TabSheetCommentary);
  PaintChrome(TabSheetDictionary); PaintChrome(TabSheetHistory); PaintChrome(TabSheetNotes);
  PaintChrome(Splitter1);
  ToolEdit.Color := TextBackground;
  ToolEdit.Font.Color := TextColor;

  ThemePopup;
  ThemeWindow;

  AssignFont;
  if not reload then Exit;

  Redraw;
end;

// Title bar, menu bar, tab headers and scroll bars (Windows only; see UnitChrome).
procedure TMainForm.ThemeWindow;
var
  c : TColor;
  dark : boolean;
  i : integer;
begin
  c := ColorToRGB(TextBackground);
  dark := ThemeEnabled and (Red(c) * 3 + Green(c) * 6 + Blue(c) < 1280);

  ChromeUpdate(Self, PageControl, ThemeEnabled, Chrome, ChromeText, TextBackground, ThemeLink);

  ChromeStatusBar(StatusBar);
  ChromeDarkScrollbars(BookBox, dark);
  ChromeDarkScrollbars(ChapterBox, dark);
  ChromeDarkScrollbars(ComboBox, dark);
  ChromeDarkScrollbars(MemoBible, dark);
  ChromeDarkScrollbars(MemoCompare, dark);
  ChromeDarkScrollbars(MemoNotes, dark);
  ChromeDarkScrollbars(MemoSearch, dark);
  ChromeDarkScrollbars(MemoReference, dark);
  ChromeDarkScrollbars(MemoCommentary, dark);
  ChromeDarkScrollbars(MemoDictionary, dark);
  ChromeDarkScrollbars(MemoHistory, dark);

  // drop-down menus and icons
  ChromeMenu(MainMenu, ThemeEnabled);
  ChromeMenu(PopupMenu, ThemeEnabled);
  ChromeMenu(PopupTabs, ThemeEnabled);
  TintImages(Images, ImagesOriginal, dark, TextColor);
  StandardToolBar.Invalidate;

  // dialogs that already exist (the others are themed when they are shown)
  for i := 0 to Screen.FormCount - 1 do ThemeForm(Screen.Forms[i]);
end;

procedure TMainForm.ThemeForm(Form: TCustomForm);
begin
  if (Form = nil) or (Form = Self) or (Form = NotifyForm) then Exit;
  ChromeTitleBar(Form, ThemeEnabled, Chrome, ChromeText);
  ChromeContainer(Form, ThemeEnabled, Chrome, ChromeText, TextBackground, TextColor);
end;

procedure TMainForm.ActiveFormChanged(Sender: TObject);
begin
  ThemeForm(Screen.ActiveForm);
end;

//-------------------------------------------------------------------------------------------------
//                          Bookmarks, shortcuts, zoom and full screen
//-------------------------------------------------------------------------------------------------

function ParseBookmark(const s: string): TVerse;
var
  parts : TStringArray;
begin
  Result.Init;
  parts := s.Split('|');
  if parts.Count < 3 then Exit;
  Result.book := ToInt(parts[0]);
  Result.chapter := ToInt(parts[1]);
  Result.number := ToInt(parts[2]);
  Result.count := 1;
end;

procedure TMainForm.SaveBookmarks;
var
  IniFile : TIniFile;
  i : integer;
begin
  IniFile := TIniFile.Create(ConfigFile);
  try
    IniFile.EraseSection('Bookmarks');
    IniFile.WriteInteger('Bookmarks', 'Count', BookmarkList.Count);
    for i := 0 to BookmarkList.Count - 1 do
      IniFile.WriteString('Bookmarks', 'Item_' + ToStr(i), BookmarkList[i]);
  finally
    IniFile.Free;
  end;
end;

procedure TMainForm.BuildBookmarkMenu;
var
  i : integer;
  Item, Remove, Highlight, Chapter, Backup : TMenuItem;
  colors : array [1..5] of string;
begin
  if miBookmarks = nil then Exit;
  miBookmarks.Clear;

  miBookmarks.Add(NewItem(T('Add bookmark'), ShortCut(VK_D, [ssCtrl]), False, True, BookmarkAdd, 0, ''));

  Highlight := TMenuItem.Create(miBookmarks);
  Highlight.Caption := T('Highlight verse');
  miBookmarks.Add(Highlight);
  colors[1] := T('Yellow'); colors[2] := T('Green'); colors[3] := T('Blue');
  colors[4] := T('Pink');   colors[5] := T('Orange');
  for i := 1 to 5 do
    begin
      Item := NewItem(colors[i] + '  (Ctrl+' + ToStr(i) + ')', ShortCut(Ord('0') + i, [ssCtrl]), False, True, HighlightSet, 0, '');
      Item.Tag := i;
      Highlight.Add(Item);
    end;
  Item := NewItem(T('Remove highlight') + '  (Ctrl+0)', ShortCut(Ord('0'), [ssCtrl]), False, True, HighlightSet, 0, '');
  Item.Tag := 0;
  Highlight.Add(Item);

  miBookmarks.Add(NewItem(T('Verse of the day'), 0, False, True, GoDailyVerse, 0, ''));
  miBookmarks.Add(NewItem(T('Note for this verse') + '...', 0, False, True, VerseNoteEdit, 0, ''));
  miBookmarks.Add(NewItem(T('Reading plan') + '...', 0, False, True, ReadingPlanClick, 0, ''));
  {$ifdef windows}
    miBookmarks.Add(NewItem(T('Read aloud') + '  (F5)', ShortCut(VK_F5, []), False, True, ReadAloud, 0, ''));
  {$endif}
  miBookmarks.Add(NewLine);
  miBookmarks.Add(NewItem(T('My highlights'), 0, False, True, ShowMyHighlights, 0, ''));
  miBookmarks.Add(NewItem(T('My bookmarks'), 0, False, True, ShowMyBookmarks, 0, ''));
  miBookmarks.Add(NewItem(T('My notes'), 0, False, True, ShowMyNotes, 0, ''));

  Chapter := TMenuItem.Create(miBookmarks);
  Chapter.Caption := T('Chapter');
  miBookmarks.Add(Chapter);
  Chapter.Add(NewItem(T('Copy chapter'), ShortCut(VK_C, [ssCtrl, ssShift]), False, True, CopyChapter, 0, ''));
  Chapter.Add(NewItem(T('Save chapter as text file') + '...', 0, False, True, SaveChapterText, 0, ''));

  Backup := TMenuItem.Create(miBookmarks);
  Backup.Caption := T('My data');
  miBookmarks.Add(Backup);
  Backup.Add(NewItem(T('Back up bookmarks, highlights and notes') + '...', 0, False, True, BackupData, 0, ''));
  Backup.Add(NewItem(T('Restore from a backup') + '...', 0, False, True, RestoreData, 0, ''));

  if BookmarkList.Count > 0 then
    begin
      miBookmarks.Add(NewLine);

      for i := 0 to BookmarkList.Count - 1 do
        begin
          Item := NewItem(CurrBible.VerseToStr(ParseBookmark(BookmarkList[i])), 0, False, True, BookmarkGo, 0, '');
          Item.Tag := i;
          miBookmarks.Add(Item);
        end;

      miBookmarks.Add(NewLine);

      Remove := TMenuItem.Create(miBookmarks);
      Remove.Caption := T('Remove');
      miBookmarks.Add(Remove);
      for i := 0 to BookmarkList.Count - 1 do
        begin
          Item := NewItem(CurrBible.VerseToStr(ParseBookmark(BookmarkList[i])), 0, False, True, BookmarkRemove, 0, '');
          Item.Tag := i;
          Remove.Add(Item);
        end;
    end;

  ChromeMenu(MainMenu, ThemeEnabled); // the new items need the themed drawing as well
end;

procedure TMainForm.BookmarkAdd(Sender: TObject);
var
  key : string;
begin
  key := ToStr(CurrVerse.book) + '|' + ToStr(CurrVerse.chapter) + '|' + ToStr(CurrVerse.number);
  if BookmarkList.IndexOf(key) >= 0 then Exit;
  BookmarkList.Add(key);
  SaveBookmarks;
  BuildBookmarkMenu;
  UpdateStatus(T('Bookmark added') + ': ' + CurrBible.VerseToStr(CurrVerse));
end;

procedure TMainForm.BookmarkGo(Sender: TObject);
var
  Verse : TVerse;
begin
  Verse := ParseBookmark(BookmarkList[(Sender as TMenuItem).Tag]);
  if not CurrBible.GoodLink(Verse) then Exit;
  CurrVerse := Verse;
  ShowCurrVerse(True);
  Tools.AddHistory;
end;

procedure TMainForm.BookmarkRemove(Sender: TObject);
begin
  BookmarkList.Delete((Sender as TMenuItem).Tag);
  SaveBookmarks;
  BuildBookmarkMenu;
end;

// next (delta = 1) or previous (delta = -1) chapter, across the books
procedure TMainForm.GoChapter(delta: integer);
var
  Verse, Target : TVerse;
begin
  Verse := CurrVerse;
  Verse.count := 1;

  if delta > 0 then
    begin
      Verse.number := CurrBible.VersesCount(Verse);
      if not CurrBible.NextVerse(Verse, Target) then Exit;
    end
  else
    begin
      Verse.number := 1;
      if not CurrBible.PrevVerse(Verse, Target) then Exit;
    end;

  CurrVerse := Target;
  CurrVerse.number := 1;
  CurrVerse.count := 1;
  ShowCurrVerse(False);
  Tools.AddHistory;
end;

procedure TMainForm.GoToChapter(book, chapter: integer);
var
  Verse : TVerse;
begin
  Verse.Init;
  Verse.book := book;
  Verse.chapter := chapter;
  Verse.number := 1;
  Verse.count := 1;
  if not CurrBible.GoodLink(Verse) then Exit;
  CurrVerse := Verse;
  ShowCurrVerse(False);
  Tools.AddHistory;
end;

// verse of the day: one of a list of well-known verses, the same all day
procedure TMainForm.GoDailyVerse(Sender: TObject);
var
  code : integer;
  Verse : TVerse;
begin
  code := DailyVerses[Trunc(Date) mod Length(DailyVerses)];
  Verse.Init;
  Verse.book := code div 1000000;
  Verse.chapter := (code div 1000) mod 1000;
  Verse.number := code mod 1000;
  Verse.count := 1;
  if not CurrBible.GoodLink(Verse) then Exit;
  CurrVerse := Verse;
  ShowCurrVerse(True);
  Tools.AddHistory;
end;

procedure TMainForm.ReadingPlanClick(Sender: TObject);
begin
  ShowReadingPlan;
end;

//---------------------------------------- line spacing ------------------------------------------

procedure TMainForm.ApplySpacing(Memo: TUnboundMemo);
var
  m : TParaMetric;
begin
  if (SpacingIndex < 1) or (SpacingIndex > High(SpacingValues)) then Exit;
  InitParaMetric(m);
  m.LineSpacing := SpacingValues[SpacingIndex];
  Memo.SetRangeParaParams(0, Length(Memo.Text), [pmm_LineSpacing], m);
end;

//----------------------------------------- highlights -------------------------------------------

procedure TMainForm.SaveHighlights;
var
  IniFile : TIniFile;
  i : integer;
begin
  IniFile := TIniFile.Create(ConfigFile);
  try
    IniFile.EraseSection('Highlights');
    IniFile.WriteInteger('Highlights', 'Count', HighlightList.Count);
    for i := 0 to HighlightList.Count - 1 do
      IniFile.WriteString('Highlights', 'Item_' + ToStr(i), HighlightList.Names[i] + '|' + HighlightList.ValueFromIndex[i]);
  finally
    IniFile.Free;
  end;
end;

// Paints (or clears) the background of one verse of the chapter on screen.
procedure TMainForm.ApplyHighlight(number: integer);
var
  key : string;
  i, x, level : integer;
  p : TParaRange;
  fp : TFontParams;
begin
  key := ToStr(CurrVerse.book) + '|' + ToStr(CurrVerse.chapter) + '|' + ToStr(number);
  i := HighlightList.IndexOfName(key);

  x := UTF8Pos(LineBreak + ' ' + ToStr(number) + ' ', MemoBible.Text);
  if (x = 0) and (number <> 1) then Exit;
  if not MemoBible.GetParaRange(x, p) then Exit;
  if not MemoBible.GetTextAttributes(p.start, fp) then Exit;

  if i >= 0 then
    begin
      level := ToInt(HighlightList.ValueFromIndex[i]);
      if (level < 1) or (level > 5) then Exit;
      fp.HasBkClr := True;
      // a tint of the color, so that the text keeps its contrast on dark and light themes
      if IsDarkBackground(TextBackground)
        then fp.BkColor := MixColors(TextBackground, HighlightColors[level], 30)
        else fp.BkColor := MixColors(TextBackground, HighlightColors[level], 65);
    end
  else
    fp.HasBkClr := False;

  MemoBible.SetRangeParams(p.start, p.length, [tmm_BackColor], fp, [], []);
end;

// all highlights of the chapter that has just been loaded
procedure TMainForm.ApplyHighlights;
var
  i : integer;
  parts : TStringArray;
begin
  for i := 0 to HighlightList.Count - 1 do
    begin
      parts := HighlightList.Names[i].Split('|');
      if parts.Count < 3 then Continue;
      if (ToInt(parts[0]) = CurrVerse.book) and (ToInt(parts[1]) = CurrVerse.chapter) then
        ApplyHighlight(ToInt(parts[2]));
    end;
end;

// Tag 1..5 highlights the selected verses in that color, tag 0 removes the highlight.
procedure TMainForm.HighlightSet(Sender: TObject);
var
  n, count, tag : integer;
  key : string;
  i : integer;
begin
  tag := (Sender as TMenuItem).Tag;
  count := CurrVerse.count;
  if count < 1 then count := 1;

  for n := CurrVerse.number to CurrVerse.number + count - 1 do
    begin
      key := ToStr(CurrVerse.book) + '|' + ToStr(CurrVerse.chapter) + '|' + ToStr(n);
      i := HighlightList.IndexOfName(key);
      if i >= 0 then HighlightList.Delete(i);
      if tag > 0 then HighlightList.Values[key] := ToStr(tag);
      ApplyHighlight(n);
    end;

  SaveHighlights;
end;

//----------------------------- lists of the highlights and bookmarks ----------------------------

// Shows all highlighted verses (or all bookmarked verses) with their text, in the order of the Bible.
// The references are links: a click opens the verse.
procedure TMainForm.ShowMyVerses(highlights: boolean);
var
  Sorted : TStringList;
  i, level : integer;
  parts : TStringArray;
  Verse : TVerse;
  text, line : string;
  colors : array [1..5] of string;
begin
  colors[1] := T('Yellow'); colors[2] := T('Green'); colors[3] := T('Blue');
  colors[4] := T('Pink');   colors[5] := T('Orange');

  Sorted := TStringList.Create;
  try
    if highlights then
      begin
        for i := 0 to HighlightList.Count - 1 do
          begin
            parts := HighlightList.Names[i].Split('|');
            if parts.Count < 3 then Continue;
            Sorted.Add(Format('%.3d%.3d%.3d', [ToInt(parts[0]), ToInt(parts[1]), ToInt(parts[2])]) +
              '|' + HighlightList.Names[i] + '|' + HighlightList.ValueFromIndex[i]);
          end;
      end
    else
      begin
        for i := 0 to BookmarkList.Count - 1 do
          begin
            parts := BookmarkList[i].Split('|');
            if parts.Count < 3 then Continue;
            Sorted.Add(Format('%.3d%.3d%.3d', [ToInt(parts[0]), ToInt(parts[1]), ToInt(parts[2])]) +
              '|' + BookmarkList[i] + '|0');
          end;
      end;
    Sorted.Sort;

    text := '';
    for line in Sorted do
      begin
        parts := line.Split('|'); // sort key, book, chapter, verse, color
        if parts.Count < 5 then Continue;
        Verse := ParseBookmark(parts[1] + '|' + parts[2] + '|' + parts[3]);
        text += '<l>' + CurrBible.VerseToStr(Verse) + '</l> ';
        if highlights then
          begin
            level := ToInt(parts[4]);
            if (level >= 1) and (level <= 5) then text += '[' + colors[level] + '] ';
          end;
        text += ''.Join(' ', CurrBible.GetRange(Verse)) + '<br><br>';
      end;

    if text.IsEmpty then
      begin
        if highlights then text := T('There are no highlighted verses yet.')
                      else text := T('There are no bookmarks yet.');
      end;

    MemoSearch.LoadText(text);
    SelectPage(apSearch);
    UpdateStatus(ToStr(Sorted.Count) + ' ' + T('verses'));
  finally
    Sorted.Free;
  end;
end;

procedure TMainForm.ShowMyHighlights(Sender: TObject);
begin
  ShowMyVerses(True);
end;

procedure TMainForm.ShowMyBookmarks(Sender: TObject);
begin
  ShowMyVerses(False);
end;

//--------------------------------- notes, speech, export, backup --------------------------------

procedure TMainForm.SaveNotes;
var
  IniFile : TIniFile;
  i : integer;
begin
  IniFile := TIniFile.Create(ConfigFile);
  try
    IniFile.EraseSection('VerseNotes');
    IniFile.WriteInteger('VerseNotes', 'Count', NoteList.Count);
    for i := 0 to NoteList.Count - 1 do
      IniFile.WriteString('VerseNotes', 'Item_' + ToStr(i), NoteList.Names[i] + '|' + NoteList.ValueFromIndex[i]);
  finally
    IniFile.Free;
  end;
end;

// puts the notes written by the user after their verses in the text of the chapter
function TMainForm.InsertVerseNotes(const s: string): string;
var
  i, p, q : integer;
  parts : TStringArray;
  note : string;
begin
  Result := s;
  for i := 0 to NoteList.Count - 1 do
    begin
      parts := NoteList.Names[i].Split('|');
      if parts.Count < 3 then Continue;
      if (ToInt(parts[0]) <> CurrVerse.book) or (ToInt(parts[1]) <> CurrVerse.chapter) then Continue;

      p := Pos('<l> ' + parts[2] + '</l> ', Result);
      if p = 0 then Continue;
      q := Pos('<br>', Copy(Result, p, MaxInt));
      if q = 0 then Continue;

      note := NoteList.ValueFromIndex[i].Replace('<', '(').Replace('>', ')');
      Insert(' <i>[' + T('My note') + ': ' + note + ']</i>', Result, p + q - 1);
    end;
end;

procedure TMainForm.VerseNoteEdit(Sender: TObject);
var
  key, value : string;
  i : integer;
begin
  key := ToStr(CurrVerse.book) + '|' + ToStr(CurrVerse.chapter) + '|' + ToStr(CurrVerse.number);
  i := NoteList.IndexOfName(key);
  if i >= 0 then value := NoteList.ValueFromIndex[i] else value := '';

  if not InputQuery(T('Note for this verse'), CurrBible.VerseToStr(CurrVerse), value) then Exit;

  value := Trim(value.Replace(#13, ' ').Replace(#10, ' '));
  if i >= 0 then NoteList.Delete(i);
  if not value.IsEmpty then NoteList.Values[key] := value;
  SaveNotes;
  ShowCurrVerse(True);
end;

procedure TMainForm.ShowMyNotes(Sender: TObject);
var
  Sorted : TStringList;
  i : integer;
  parts : TStringArray;
  Verse : TVerse;
  text, line, key : string;
begin
  Sorted := TStringList.Create;
  try
    for i := 0 to NoteList.Count - 1 do
      begin
        parts := NoteList.Names[i].Split('|');
        if parts.Count < 3 then Continue;
        Sorted.Add(Format('%.3d%.3d%.3d', [ToInt(parts[0]), ToInt(parts[1]), ToInt(parts[2])]) +
          '|' + NoteList.Names[i]);
      end;
    Sorted.Sort;

    text := '';
    for line in Sorted do
      begin
        parts := line.Split('|'); // sort key, book, chapter, verse
        if parts.Count < 4 then Continue;
        key := parts[1] + '|' + parts[2] + '|' + parts[3];
        Verse := ParseBookmark(key);
        text += '<l>' + CurrBible.VerseToStr(Verse) + '</l> ' + ''.Join(' ', CurrBible.GetRange(Verse)) +
                '<br><i>' + T('My note') + ': ' + NoteList.Values[key].Replace('<', '(').Replace('>', ')') +
                '</i><br><br>';
      end;

    if text.IsEmpty then text := T('There are no notes yet.');

    MemoSearch.LoadText(text);
    SelectPage(apSearch);
    UpdateStatus(ToStr(Sorted.Count) + ' ' + T('verses'));
  finally
    Sorted.Free;
  end;
end;

// Windows: reads the chapter aloud with the voice of the system, from the selected verse.
// Choosing it again while it is reading stops it.
procedure TMainForm.ReadAloud(Sender: TObject);
{$ifdef windows}
var
  Strings : TStringArray;
  i : integer;
  text : string;
begin
  try
    if VarIsEmpty(Voice) then Voice := CreateOleObject('SAPI.SpVoice');

    if Voice.Status.RunningState = 2 then // it is speaking
      begin
        Voice.Speak(WideString(''), 3);   // 3 = asynchronous + purge what is queued
        Exit;
      end;

    Strings := CurrBible.GetChapter(CurrVerse.book, CurrVerse.chapter);
    text := '';
    for i := CurrVerse.number - 1 to High(Strings) do
      if i >= 0 then text += PlainVerse(Strings[i]) + ' ';

    Voice.Speak(UTF8Decode(text), 1);     // 1 = asynchronous
  except
    on E: Exception do ShowMessage(T('Speech is not available.') + ' ' + E.Message);
  end;
end;
{$else}
begin
end;
{$endif}

function TMainForm.ChapterPlainText: string;
var
  Strings : TStringArray;
  Book : TBook;
  i : integer;
begin
  Result := '';
  Book := CurrBible.BookByNum(CurrVerse.book);
  if Assigned(Book) then Result := Book.title + ' ' + ToStr(CurrVerse.chapter) + LineEnding + LineEnding;

  Strings := CurrBible.GetChapter(CurrVerse.book, CurrVerse.chapter);
  for i := Low(Strings) to High(Strings) do
    Result += ToStr(i + 1) + ' ' + PlainVerse(Strings[i]) + LineEnding;

  Result += LineEnding + CurrBible.Name + LineEnding;
end;

procedure TMainForm.CopyChapter(Sender: TObject);
begin
  Clipboard.AsText := ChapterPlainText;
  UpdateStatus(T('Chapter copied'));
end;

procedure TMainForm.SaveChapterText(Sender: TObject);
var
  Dlg : TSaveDialog;
  List : TStringList;
  Book : TBook;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter := 'Text (*.txt)|*.txt';
    Dlg.DefaultExt := 'txt';
    Dlg.InitialDir := DocumentsPath;
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    Book := CurrBible.BookByNum(CurrVerse.book);
    if Assigned(Book) then Dlg.FileName := Book.title + ' ' + ToStr(CurrVerse.chapter) + '.txt';

    if not Dlg.Execute then Exit;

    List := TStringList.Create;
    try
      List.Text := ChapterPlainText;
      List.SaveToFile(Dlg.FileName);
    finally
      List.Free;
    end;
    UpdateStatus(T('Saved') + ': ' + Dlg.FileName);
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.BackupData(Sender: TObject);
var
  Dlg : TSaveDialog;
  Source, Target : TIniFile;
  section : string;
begin
  Dlg := TSaveDialog.Create(Self);
  try
    Dlg.Filter := 'Backup (*.ini)|*.ini';
    Dlg.DefaultExt := 'ini';
    Dlg.FileName := 'unbound-bible-backup.ini';
    Dlg.InitialDir := DocumentsPath;
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if not Dlg.Execute then Exit;

    SaveSettings;
    Source := TIniFile.Create(ConfigFile);
    Target := TIniFile.Create(Dlg.FileName);
    try
      for section in ['Bookmarks', 'Highlights', 'VerseNotes', 'Plan'] do
        CopySection(Source, Target, section);
    finally
      Target.Free;
      Source.Free;
    end;
    UpdateStatus(T('Saved') + ': ' + Dlg.FileName);
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.RestoreData(Sender: TObject);
var
  Dlg : TOpenDialog;
  Source, Target : TIniFile;
  section : string;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Filter := 'Backup (*.ini)|*.ini';
    Dlg.InitialDir := DocumentsPath;
    Dlg.Options := Dlg.Options + [ofFileMustExist];
    if not Dlg.Execute then Exit;

    if MessageDlg(T('Restore from a backup'),
         T('Replace your bookmarks, highlights, notes and reading plan with the ones in this file?'),
         mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;

    Source := TIniFile.Create(Dlg.FileName);
    Target := TIniFile.Create(ConfigFile);
    try
      for section in ['Bookmarks', 'Highlights', 'VerseNotes', 'Plan'] do
        if Source.SectionExists(section) then CopySection(Source, Target, section);
    finally
      Target.Free;
      Source.Free;
    end;

    ReloadUserData;
    BuildBookmarkMenu;
    ShowCurrVerse(False);
    UpdateStatus(T('Restored'));
  finally
    Dlg.Free;
  end;
end;

procedure TMainForm.ToggleFullScreen;
begin
  if WindowState = wsFullScreen then
    WindowState := FullScreenPrevious
  else
    begin
      FullScreenPrevious := WindowState;
      WindowState := wsFullScreen;
    end;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Shift = [ssCtrl] then
    if (Key = VK_LEFT) or (Key = VK_RIGHT) then
      if (PageControl.ActivePageIndex <> apNotes) and not ToolEdit.Focused then
        begin
          if Key = VK_RIGHT then GoChapter(1) else GoChapter(-1);
          Key := 0;
          Exit;
        end;

  if (Shift = [ssCtrl]) and (Key = VK_G) then // go to a verse: type the reference and press Enter
    begin
      if ToolEdit.Visible then
        begin
          ToolEdit.SetFocus;
          ToolEdit.SelectAll;
        end;
      Key := 0;
      Exit;
    end;

  if Shift = [] then
    begin
      if Key = VK_F11 then
        begin
          ToggleFullScreen;
          Key := 0;
        end;
      if Key = VK_F9 then // hide / show the books and chapters
        begin
          PanelLeft.Visible := not PanelLeft.Visible;
          Splitter1.Visible := PanelLeft.Visible;
          Key := 0;
        end;
    end;
end;

// Ctrl + mouse wheel changes the size of the text
procedure TMainForm.MemoWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint; var Handled: Boolean);
var
  size : integer;
begin
  if not (ssCtrl in Shift) then Exit;
  Handled := True;

  size := Font.Size;
  if WheelDelta > 0 then size += 1 else size -= 1;
  if size < 8 then size := 8;
  if size > 48 then size := 48;
  if size = Font.Size then Exit;

  Font.Size := size;
  AssignFont;
  Redraw;
end;

procedure TMainForm.SaveSettings;
begin
  try SaveConfig; except end;
end;

// Reloads what is on screen: colors and hidden footnotes are applied while the text is parsed.
procedure TMainForm.Redraw;
begin
  ShowCurrVerse(False);
  if PageControl.ActivePageIndex = apCompare then LoadCompare;
  Repaint;
end;

procedure TMainForm.Localize;
begin
  if Assigned(miBookmarks) then
    begin
      miBookmarks.Caption := T('Bookmarks');
      BuildBookmarkMenu;
    end;

  miBibleFolder.Caption := T('Bible Folder');
  miClear.Caption := T('Delete');
  miCommentaries.Caption := T('Commentaries');
  miCompare.Caption := T('Compare');
  miCopy.Caption := T('Copy');
  miCopyAs.Caption := T('Copy As…');
  miCut.Caption := T('Cut');
  miDictionaries.Caption := T('Dictionaries');
  miDonate.Caption := T('Donate');
  miDownload.Caption := T('Modules Downloads');
  miEdit.Caption := T('Edit');
  miExit.Caption := T('Exit');
  miHelp.Caption := T('Help');
  miHelpAbout.Caption := T('About');
  miHistory.Caption := T('History');
  miHome.Caption := T('Home Page');
  miInterlinear.Caption := T('Interlinear') + ' (biblehub.com)';
  miIssue.Caption := T('Report an Issue');
  miModules.Caption := T('Modules');
  miNoteNew.Caption := T('New');
  miNoteOpen.Caption := T('Open…');
  miNoteSave.Caption := T('Save');
  miNoteSaveAs.Caption := T('Save As…');
  miNotes.Caption := T('Notes');
  miOptions.Caption := T('Options');
  miPaste.Caption := T('Paste');
  miPrint.Caption := T('Print');
  miRecent.Caption := T('Open Recent');
  miRrefx.Caption := T('Cross-References');
  miSearch.Caption := T('Search');
  miSelectAll.Caption := T('Select All');
  miTools.Caption := T('Tools');
  miUndo.Caption := T('Undo');
  miVerses.Caption := T('Copy Verses');

  pmCleanHistory.Caption := T('Clean History');
  pmClose.Caption := T('Close');
  pmCopy.Caption := T('Copy');
  pmCopyAs.Caption := T('Copy As…');
  pmCut.Caption := T('Cut');
  pmPaste.Caption := T('Paste');
  pmVerses.Caption := T('Copy Verses');

  TabSheetBible.Caption := T('Bible');
  TabSheetCommentary.Caption := T('Commentaries');
  TabSheetCompare.Caption := T('Compare');
  TabSheetDictionary.Caption := T('Dictionaries');
  TabSheetHistory.Caption := T('History');
  TabSheetNotes.Caption := T('Notes');
  TabSheetReference.Caption := T('Cross-References');
  TabSheetSearch.Caption := T('Search');

  ToolButtonBold.Hint := T('Bold');
  ToolButtonBullets.Hint := T('Bullets');
  ToolButtonCenter.Hint := T('Center');
  ToolButtonCommentary.Hint := T('Commentaries');
  ToolButtonCopy.Hint := T('Copy');
  ToolButtonCut.Hint := T('Cut');
  ToolButtonDictionary.Hint := T('Dictionaries');
  ToolButtonFont.Hint := T('Font');
  ToolButtonHistory.Hint := T('History');
  ToolButtonItalic.Hint := T('Italic');
  ToolButtonLeft.Hint := T('Align Left');
  ToolButtonLink.Hint := T('Hyperlink');
  ToolButtonNew.Hint := T('New');
  ToolButtonOpen.Hint := T('Open');
  ToolButtonPaste.Hint := T('Paste');
  ToolButtonPrint.Hint := T('Print');
  ToolButtonReference.Hint := T('Cross-References');
  ToolButtonRight.Hint := T('Align Right');
  ToolButtonSave.Hint := T('Save');
  ToolButtonSearch.Hint := T('Search Options');
  ToolButtonShelf.Hint := T('Modules');
  ToolButtonUnderline.Hint := T('Underline');
  ToolButtonUndo.Hint := T('Undo');
  ToolButtonVerses.Hint := T('Copy Verses');
end;

procedure TMainForm.LocalizeApplication;
begin
  MainForm    .Localize;
  AboutBox    .Localize;
  CopyForm    .Localize;
  OptionsForm .Localize;
  SearchForm  .Localize;
  ShelfForm   .Localize;
  ShelfForm   .Localize;
end;

//-------------------------------------------------------------------------------------------------
//                                       Actions
//-------------------------------------------------------------------------------------------------

procedure TMainForm.CmdAbout(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

procedure TMainForm.CmdStyle(Sender: TObject);
var
  fp: TFontParams;
begin
  fp := MemoNotes.SelAttributes;
  MemoNotes.SaveSelection;
  if MemoNotes.SelLength = 0 then MemoNotes.SelectWord;

  if Sender = ActionBold then
    if fsBold in fp.Style then fp.Style := fp.Style - [fsBold]
                          else fp.Style := fp.Style + [fsBold];

  if Sender = ActionItalic then
    if fsItalic in fp.Style then fp.Style := fp.Style - [fsItalic]
                            else fp.Style := fp.Style + [fsItalic];

  if Sender = ActionUnderline then
    if fsUnderline in fp.Style then fp.Style := fp.Style - [fsUnderline]
                               else fp.Style := fp.Style + [fsUnderline];

  if Sender = ActionLink then
    if fp.Color = clNavy then fp.Color := clBlack
                         else fp.Color := clNavy;

//if Sender = ActionSuper then
//  if fp.vScriptPos = vpSuperscript then fp.vScriptPos := vpNormal
//                                   else fp.vScriptPos := vpSuperscript;

  if Sender = ActionIncrease then fp.Size += 1;
  if Sender = ActionDecrease then fp.Size -= 1;

  if Sender = ActionFont then
    begin
      FontDialogNotes.Font.Name  := fp.Name;
      FontDialogNotes.Font.Size  := fp.Size;
      FontDialogNotes.Font.Style := fp.Style;
      FontDialogNotes.Font.Color := fp.Color;

      if FontDialogNotes.Execute then
        begin
          fp.Name  := FontDialogNotes.Font.Name;
          fp.Size  := FontDialogNotes.Font.Size;
          fp.Style := FontDialogNotes.Font.Style;
          fp.Color := FontDialogNotes.Font.Color;
        end;
    end;

  MemoNotes.SetTextAttributes(MemoNotes.SelStart, MemoNotes.SelLength, fp);
  MemoNotes.RestoreSelection; // unselect word
  MemoNotes.Repaint;
end;

procedure TMainForm.CmdStyle2(Sender: TObject);
{$ifdef windows} var pn : TParaNumbering; {$endif}
begin
  with MemoNotes do
    begin
      if Sender = ActionLeft    then SetParaAlignment(SelStart, SelLength, paLeft   );
      if Sender = ActionCenter  then SetParaAlignment(SelStart, SelLength, paCenter );
      if Sender = ActionRight   then SetParaAlignment(SelStart, SelLength, paRight  );

      {$ifdef windows}
      if Sender = ActionBullets then
        begin
          pn := SelParaNumbering;
          if pn.Style = pnNone then pn.Style := pnBullet else pn.Style := pnNone;
          SetParaNumbering(SelStart, SelLength, pn);
        end;
      {$endif}
    end;

  MemoNotes.Repaint;
end;

procedure TMainForm.ComboBoxChange(Sender: TObject);
begin
  if Tools.SetCurrBible(ComboBox.Items[ComboBox.ItemIndex]) then ShowCurrBible;
end;

procedure TMainForm.ComboBoxDrawItem(Control: TWinControl; Index: integer; ARect: TRect; State: TOwnerDrawState);
begin
  ComboBox.canvas.fillrect(ARect);
  Canvas.TextOut(ARect.Left + 5, ARect.Top, ComboBox.Items[Index]);
  Canvas.TextOut(ARect.Left + 220, ARect.Top, '[ru]');
end;

procedure TMainForm.CmdCompare(Sender: TObject);
begin
  LoadCompare;
end;

procedure TMainForm.CmdInterline(Sender: TObject);
var path : string;
begin
  path := BibleHubURL(CurrVerse.book, CurrVerse.chapter, CurrVerse.number);
  if path <> '' then OpenURL(path);
end;

procedure TMainForm.CmdEdit(Sender: TObject);
begin
  if Sender = ActionEditCopy   then UnboundMemo.CopyToClipboard;
  if Sender = ActionEditPaste  then UnboundMemo.PasteFromClipboard;
  if Sender = ActionEditDel    then UnboundMemo.ClearSelection;
  if Sender = ActionEditUndo   then UnboundMemo.Undo;
  if Sender = ActionEditSelAll then UnboundMemo.SelectAll;

  if Sender = ActionEditCut then
    begin
      UnboundMemo.CopyToClipboard;
      UnboundMemo.ClearSelection;
    end;

  EnableActions;
end;

procedure TMainForm.CmdCopyAs(Sender: TObject);
begin
  // saving selection because of strange bug in the gtk2's richmemo
  {$ifdef linux} MemoBible.SaveSelection; {$endif}
  CopyForm.Memo.Font.Assign(Font);
  CopyForm.ShowModal;
  {$ifdef linux} MemoBible.RestoreSelection; {$endif}
end;

procedure TMainForm.CmdCopyVerses(Sender: TObject);
begin
  {$ifdef unix} MemoBible.SaveSelection; {$endif}
  VersesToClipboard;
  {$ifdef unix} MemoBible.RestoreSelection; {$endif}
end;

procedure TMainForm.CmdSearch(Sender: TObject);
begin
  ToolEdit.SetFocus;
end;

procedure TMainForm.CmdSearchFor(Sender: TObject);
begin
  ToolEdit.Text := Trim(UnboundMemo.SelText);
  LoadSearch(ToolEdit.Text);
end;

procedure TMainForm.CmdReference(Sender: TObject);
begin
  LoadReference;
end;

procedure TMainForm.CmdHistory(Sender: TObject);
begin
  LoadHistory;
end;

procedure TMainForm.CmdCleanHistory(Sender: TObject);
begin
  Tools.CleanHistory;
  MemoHistory.Clear;
end;

procedure TMainForm.CmdCommentaries(Sender: TObject);
var
  Response : integer;
begin
  if Tools.Commentaries.FootnotesOnly then
    begin
      Response := QuestionDlg(T('Commentaries'),
        T('You don''t have any commentary modules.'), mtCustom,
          [mrYes, T('Download'), mrNo, T('Cancel')], '');
      if Response = idYes then OpenURL(DownloadsURL);
      Exit;
    end;

  LoadCommentary;
end;

procedure TMainForm.CmdLookup(Sender: TObject);
begin
  ToolEdit.Text := Trim(UnboundMemo.SelText);
  CmdDictionaries(Sender);
end;

procedure TMainForm.CmdDictionaries(Sender: TObject);
begin
  if Tools.Dictionaries.EmbeddedOnly then
    begin
      if QuestionDlg(T('Dictionaries'),
        T('You don''t have any dictionary modules.'), mtCustom,
          [mrYes, T('Download'), mrNo, T('Cancel')], '') = idYes then
            OpenURL(DownloadsURL);
      Exit;
    end;

  LoadDictionary(ToolEdit.Text);
end;

procedure TMainForm.CmdFileNew(Sender: TObject);
begin
  SelectPage(apNotes);
  if not CheckFileSave then Exit;
  NoteFileName := Untitled;
  MemoNotes.Lines.Clear;
  MemoNotes.Modified := False;
  UpdateCaption(NoteFileName);
end;

procedure TMainForm.CmdFileOpen(Sender: TObject);
begin
  if not CheckFileSave then Exit;
  if OpenDialog.Execute then
    begin
      PerformFileOpen(OpenDialog.FileName);
      MemoNotes.ReadOnly := ofReadOnly in OpenDialog.Options;
    end;
end;

procedure TMainForm.CmdFileSave(Sender: TObject);
begin
  SelectPage(apNotes);
  if not MemoNotes.Modified then Exit;
  if NoteFileName = Untitled then
    CmdFileSaveAs(Sender)
  else
    begin
      MemoNotes.SaveToFile(NoteFileName);
      MemoNotes.Modified := False;
    end;
end;

procedure TMainForm.CmdFileSaveAs(Sender: TObject);
begin
  SelectPage(apNotes);
  if NoteFileName = Untitled then SaveDialog.InitialDir := DocumentsPath
                             else SaveDialog.InitialDir := ExtractFilePath(NoteFileName);

  if not SaveDialog.Execute then Exit;

  if not SaveDialog.FileName.Contains('.rtf') then
    SaveDialog.FileName := SaveDialog.FileName + '.rtf';

  if FileExists(SaveDialog.FileName) then
    if QuestionDlg(' ' + T('Confirmation'),
      Format(T('OK to overwrite %s?'), [SaveDialog.FileName]), mtWarning,
        [mrYes, T('Yes'), mrNo, T('No'), 'IsDefault'], 0) <> idYes then Exit;

  MemoNotes.SaveToFile(SaveDialog.FileName);
  NoteFileName := SaveDialog.FileName;

  RebuildRecentList;

  MemoNotes.Modified := False;
  UpdateCaption(ExtractOnlyName(NoteFileName));
end;

procedure TMainForm.CmdFilePrint(Sender: TObject);
var
  Params : TPrintParams;
begin
  InitPrintParams(Params{%H-});
  if PrintDialog.Execute then UnboundMemo.Print(Params);
end;

procedure TMainForm.CmdModules(Sender: TObject);
begin
  if ShelfForm.ShowModal = mrOk then ShowCurrBible else LoadComboBox;
  if PageControl.ActivePageIndex = apCompare then LoadCompare;
end;

procedure TMainForm.CmdExit(Sender: TObject);
begin
  Close;
end;

//-------------------------------------------------------------------------------------------------
//                                         Events
//-------------------------------------------------------------------------------------------------

procedure TMainForm.BookBoxClick(Sender: TObject);
var
  Book : TBook;
  name : string;
begin
  if BookBox.Count = 0 then Exit;
  name := BookBox.Items[BookBox.ItemIndex];

  Book := CurrBible.BookByName(name);
  if not Assigned(Book) then Exit;

  CurrVerse.Init;
  CurrVerse.Book := Book.Number;

  MakeChapterList;
  LoadChapter;
end;

procedure TMainForm.ChapterBoxClick(Sender: TObject);
begin
  CurrVerse.Chapter := ChapterBox.ItemIndex + 1;
  CurrVerse.Number := 1;
  CurrVerse.Count := 1;
  LoadChapter;
end;

procedure TMainForm.MemoMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: integer);
var
  Memo : TUnboundMemo;
  Verse : TVerse;
  s : string;
begin
  Memo := Sender as TUnboundMemo;

  if Button = mbRight then ShowPopup;
  if Button <> mbLeft then Exit;

  if Memo = MemoBible then Tools.AddHistory;

  if Memo.hyperlink.isEmpty then Exit;

  if Memo.Foreground = fgLink then
    begin
      if Memo = MemoHistory then
        begin
          s := Tools.FilenameFromHistory(Round((Memo.Breaks/2)));
          if Tools.SetCurrBible(s) then ShowCurrBible;
        end;

      Verse := CurrBible.SrtToVerse(Memo.hyperlink);

      if CurrBible.GoodLink(Verse) then
        begin
          CurrVerse := Verse;
          ShowCurrVerse(True);
          if Memo = MemoCompare then LoadCompare; // stay on Compare tab
          Tools.AddHistory;
        end
      else
        if Tools.SetCurrBible(Memo.hyperlink)then ShowCurrBible;
    end;

  if Memo = MemoBible then
    if Memo.Foreground = fgFootnote then LoadFootnote(Memo.hyperlink);

  if Memo <> MemoNotes then
    if Memo.Foreground = fgStrong then LoadStrong(Memo.hyperlink);
end;

procedure TMainForm.MemoKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_APPS) or ((Key = VK_F10) and (Shift = [ssShift])) then ShowPopup;
end;

procedure TMainForm.MemoSelectionChange(Sender: TObject);
begin
  EnableActions;
  if Sender = MemoNotes then UpDownButtons;
end;

procedure TMainForm.MemoBibleParagraphChange(Sender: TObject);
begin
  CurrVerse.Number := MemoBible.ParagraphStart;
  CurrVerse.Count  := MemoBible.ParagraphCount;
end;

procedure TMainForm.MemoContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True; // disable system popup menu
end;

procedure TMainForm.ToolEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Verse: TVerse;
begin
  if Key = VK_RETURN then
    begin
      Verse := CurrBible.SrtToVerse(trim(ToolEdit.Text));
      if CurrBible.GoodLink(Verse) then
        begin
          CurrVerse := Verse;
          ShowCurrVerse(True)
        end
    else if PageControl.ActivePageIndex = apDictionaries then LoadDictionary(ToolEdit.Text)
      else LoadSearch(ToolEdit.Text);
    end;

end;

//-------------------------------------------------------------------------------------------------

procedure TMainForm.LoadComboBox;
var
  Item : string;
begin
  ComboBox.Items.Clear;
  for Item in Tools.Get_FavoriteBiles do
    begin
      ComboBox.Items.Add(Item);
      if Item = CurrBible.name then ComboBox.ItemIndex := ComboBox.Items.Count - 1;
    end;
end;

procedure TMainForm.UpdateCaption(s: string);
begin
  Caption := ApplicationName + ' ' + ApplicationVersion + ' - ' + s;
end;

procedure TMainForm.RefreshStatus;
begin
  try
    StatusBar.SimpleText := ' ' + Statuses.KeyData[PageControl.ActivePageIndex];
  except
    StatusBar.SimpleText := '';
  end;
end;

procedure TMainForm.UpdateStatus(s: string);
begin
  Statuses.AddOrSetData(PageControl.ActivePageIndex, s);
  RefreshStatus;
end;

procedure TMainForm.ShowPopup;
var
  CursorPos: TPoint;
begin
  GetCursorPos(CursorPos);
  PopupMenu.Popup(CursorPos.X, CursorPos.Y);
end;

procedure TMainForm.SelectBook(title: string; scroll: boolean);
var
  item : string;
begin
  for item in BookBox.Items do
    if item = title then
      begin
        BookBox.ItemIndex := BookBox.Items.IndexOf(item);
        if scroll then BookBox.TopIndex := BookBox.ItemIndex;
      end;
end;

procedure TMainForm.ShowCurrVerse(select: boolean);
var
  Book : TBook;
begin
  Book := CurrBible.BookByNum(CurrVerse.Book);
  if not Assigned(Book) then Exit;

  MakeChapterList;
  LoadChapter;

  SelectBook(Book.title, TModule.IsNewTestament(CurrVerse.book));
  ChapterBox.ItemIndex := CurrVerse.Chapter - 1;

  if select then MemoBible.SelectParagraph(CurrVerse.Number);
  Repaint;
end;

procedure TMainForm.ShowCurrBible;
var
  select : boolean;
begin
  LoadComboBox;
  MakeBookList;
  select := CurrVerse.number > 1;
  {$ifdef linux}
    IdleMessage := 'ShowCurrVerse(' + ToStr(select) + ')';
  {$else}
    ShowCurrVerse(select);
  {$endif}
  UpdateStatus(CurrBible.Info);
  BuildBookmarkMenu; // the names of the books depend on the translation
end;

function TMainForm.CheckFileSave: boolean;
var
  Response : integer;
begin
  Result := True;
  if not MemoNotes.Modified then Exit;
  SelectPage(apNotes);

  Response := QuestionDlg(' ' + T('Confirmation'), T('Save changes?'),
      mtConfirmation, [mrYes, T('Yes'), mrNo, T('No'), mrCancel, T('Cancel'), 'IsDefault'], 0);

  // remake!!
  case Response of
    idYes:
      begin
        CmdFileSave(self);
        Result := not MemoNotes.Modified;
      end;
    idNo: {nothing};
    idCancel: Result := False;
  end;
end;

procedure TMainForm.OnRecentClick(Sender: TObject);
begin
  if CheckFileSave then PerformFileOpen(RecentList[(Sender as TMenuItem).tag]);
end;

procedure TMainForm.MakeRecentMenu;
var
  MenuItem : TMenuItem;
  item : string;
begin
  miRecent.Enabled := not RecentList.IsEmpty;
  miRecent.Clear;

  for item in RecentList.Reverse do
    begin
      MenuItem := NewItem(ExtractOnlyName(item), 0, False, True, OnRecentClick, 0, '');
      MenuItem.Tag := RecentList.IndexOf(item);
      miRecent.Add(MenuItem);
    end;
end;

function TMainForm.UnboundMemo: TUnboundMemo;
begin
  case PageControl.ActivePageIndex of
    apBible        : Result := MemoBible;
    apCommentaries : Result := MemoCommentary;
    apCompare      : Result := MemoCompare;
    apDictionaries : Result := MemoDictionary;
    apHistory      : Result := MemoHistory;
    apNotes        : Result := MemoNotes;
    apReferences   : Result := MemoReference;
    apSearch       : Result := MemoSearch;
  else
    Result := nil;
  end;
end;

procedure TMainForm.EnableActions;
var
  B, L, H, M, S : boolean;
begin
  B := PageControl.ActivePageIndex = apBible;
  L := PageControl.ActivePageIndex = apNotes;
  H := PageControl.ActivePageIndex = apHistory;
  S := UnboundMemo.SelLength > iif(B,1,0);
  M := UnboundMemo.SelText.Contains(LineBreak); // multiline

  ActionSearchfor.Visible  := S and not M;
  ActionLookup.Visible     := S and not M;
  ActionCopyAs.Enabled     := B;
  ActionCopyVerses.Enabled := B;

  ActionEditCopy.Enabled   := S;
  ActionEditCut.Enabled    := L and S;
  ActionEditDel.Enabled    := L and S;
  ActionEditPaste.Enabled  := L and UnboundMemo.CanPaste;
  ActionEditUndo.Enabled   := L and UnboundMemo.CanUndo;

  ToolButtonNew.Enabled    := L;
  ToolButtonOpen.Enabled   := L;
  ToolButtonPrint.Enabled  := L;
  ToolButtonSave.Enabled   := L;

  ActionFont.Enabled       := L;
  ActionBold.Enabled       := L;
  ActionItalic.Enabled     := L;
  ActionUnderline.Enabled  := L;
  ActionLink.Enabled       := L;
  ActionLeft.Enabled       := L;
  ActionCenter.Enabled     := L;
  ActionRight.Enabled      := L;
  ActionBullets.Enabled    := L;

  ActionInterlinear.Enabled := B and not S and not M;
  ToolButtonSearch.Enabled  := PageControl.ActivePageIndex <> apDictionaries;

  ActionCleanHistory.Enabled := H and not Tools.EmptyHistory;
  pmSeparatorH.Visible       := H;
  pmCleanHistory.Visible     := H;

  UpdateActionImage;
end;

procedure TMainForm.UpDownButtons;
var
  fp : TFontParams;
begin
  if PageControl.ActivePageIndex <> apNotes then Exit;

  with MemoNotes do
    begin
      fp := SelAttributes;

      ToolButtonBold.Down := fsBold in fp.Style;
      ToolButtonItalic.Down := fsItalic in fp.Style;
      ToolButtonUnderline.Down := fsUnderline in fp.Style;
      ToolButtonLink.Down := clNavy = fp.Color;

      case SelParaAlignment of
        paLeft: ToolButtonLeft.Down := True;
        paRight: ToolButtonRight.Down := True;
        paCenter: ToolButtonCenter.Down := True;
      end;

      {$ifdef windows} ToolButtonBullets.Down := SelParaNumbering.Style = pnBullet; {$endif}
    end;
end;

procedure TMainForm.UpdateActionImage;
var
  Action : TContainedAction;
begin
  for Action in ActionList do
    if Action.Tag > 0 then
      if TAction(Action).Enabled
        then TAction(Action).ImageIndex := Action.Tag
        else TAction(Action).ImageIndex := Action.Tag + 1;
end;

procedure TMainForm.RebuildRecentList;
var
  item : string;
begin
  for item in RecentList do
    if item = NoteFileName then
      RecentList.Delete(RecentList.IndexOf(item));

  RecentList.Add(NoteFileName);
  if RecentList.Count > RecentMax then RecentList.Delete(0);
  MakeRecentMenu;
end;

procedure TMainForm.PerformFileOpen(const FileName: string);
begin
  if not FileExists(FileName) then Exit;
  MemoNotes.LoadFromFile(FileName);
  NoteFileName := FileName;
  RebuildRecentList;
  SelectPage(apNotes);
  MemoNotes.SetFocus;
  MemoNotes.Modified := False;
  UpdateCaption(ExtractOnlyName(NoteFileName));
end;

procedure TMainForm.SelectPage(page: integer);
begin
  if page = PageControl.ActivePageIndex then Exit;
  {$ifdef linux} PageControl.ActivePageIndex := 0; {$endif}
  PageControl.ActivePageIndex := page;
  PageControl.ActivePage.TabVisible := true;
  EnableActions;
  RefreshStatus;
  Refresh;
end;

procedure TMainForm.miBibleFolderClick(Sender: TObject);
begin
  if not IsPortable then CreateDataDirectory;
  OpenFolder(DataPath);
end;

procedure TMainForm.miHomeClick(Sender: TObject);
begin
  OpenURL(HomeURL);
end;

procedure TMainForm.miDonateClick(Sender: TObject);
begin
  OpenURL(DonateURL);
//DonateVisited := True;
end;

procedure TMainForm.miDownloadClick(Sender: TObject);
begin
  OpenURL(DownloadsURL);
end;

procedure TMainForm.miIssueClick(Sender: TObject);
begin
  OpenURL(IssueURL);
end;

procedure TMainForm.CmdOptions(Sender: TObject);
begin
  OptionsForm.Show;
end;

procedure TMainForm.IdleTimerTimer(Sender: TObject);
begin
  {$ifdef windows}
  if IdleMessage = 'HideCursor' then HideCursor;
  {$endif}
  {$ifdef linux}
  if IdleMessage = 'ShowCurrVerse(True)'  then ShowCurrVerse(True);
  if IdleMessage = 'ShowCurrVerse(False)' then ShowCurrVerse(False);
  {$endif}
  IdleMessage := '';
end;

procedure TMainForm.PageControlChange(Sender: TObject);
begin
  EnableActions;
  UpDownButtons;
  RefreshStatus;
  UnboundMemo.Repaint;

  case PageControl.ActivePageIndex of
    apCompare      : CmdCompare(Sender);
    apReferences   : CmdReference(Sender);
    apCommentaries : CmdCommentaries(Sender);
    apDictionaries : CmdDictionaries(Sender);
    apHistory      : CmdHistory(Sender);
    apNotes        : UnboundMemo.SetFocus;
  end;

  {$ifdef windows} IdleMessage := 'HideCursor'; {$endif}
end;

procedure TMainForm.PopupMenuPopup(Sender: TObject);
var
  s : string;
begin
  pmSeparator.Visible := ActionLookup.Visible;

  if not ActionLookup.Visible then Exit;
  s := DoubleQuoted( Trim(UnboundMemo.SelText) );

  pmSearchfor.Caption := StringReplace( T('Search for %'),'%',s,[]);
  pmLookup   .Caption := StringReplace( T('Look Up %')   ,'%',s,[]);
end;

procedure TMainForm.PageControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    if PageControl.ActivePageIndex = PageControl.IndexOfPageAt(X,Y) then
      if not (PageControl.ActivePageIndex in [apBible, apCompare, apNotes]) then
        PopupTabs.PopUp;
end;

procedure TMainForm.pmCloseClick(Sender: TObject);
begin
  PageControl.ActivePage.TabVisible := False;
end;

procedure TMainForm.ToolButtonDonateClick(Sender: TObject);
begin
  OpenURL(DonateURL);
end;

procedure TMainForm.ToolButtonSearchClick(Sender: TObject);
var
  Pos : TPoint;
begin
  Pos.x := Width - (SearchForm.Width div 2);
  Pos.y := PageControl.Top + 2;
  Pos := ClientToScreen(Pos);
  if SearchForm.ShowAtPos(Pos) = mrOk then LoadSearch(ToolEdit.Text);
end;

//-----------------------------------------------------------------------------------------

procedure TMainForm.MakeBookList;
var
  l : boolean;
begin
  l := BookBox.ItemIndex < 0;
  BookBox.BiDiMode := bdLeftToRight;
  if CurrBible.RightToLeft then BookBox.BiDiMode := bdRightToLeft;
  BookBox.Items.AddStrings(CurrBible.GetTitles, True);
  if l and (BookBox.Count > 0) then BookBox.ItemIndex := 0;
end;

procedure TMainForm.MakeChapterList;
var
  n, i: integer;
begin
  ChapterBox.Items.BeginUpdate;
  ChapterBox.Items.Clear;

  n := CurrBible.ChaptersCount(CurrVerse.book);
  for i := 1 to n do ChapterBox.Items.Add(ToStr(i));

  ChapterBox.ItemIndex := 0;
  ChapterBox.Items.EndUpdate;
end;

//----------------------------------------------------------------------------------------
//                                       Loads
//----------------------------------------------------------------------------------------

procedure TMainForm.LoadChapter;
begin
  MemoBible.LoadText(ProcessNotes(InsertVerseNotes(Tools.Get_Chapter), True), true);
  ApplySpacing(MemoBible);
  ApplyHighlights;
  SelectPage(apBible);
end;

procedure TMainForm.LoadSearch(s: string);
var
  text : string;
  count : integer;
const
  max = {$ifdef windows}5000{$else}2000{$endif};
begin
  s := Trim(s);
  if Utf8Length(s) < 2 then Exit;

  Cursor := crHourGlass;
  text := Tools.Get_Search(s, count);

  if count = 0 then
    text := T('You search for % produced no results.').Replace('%',DoubleQuoted(s));

  if count > max then text := T('This search returned too many results.') + ' ' +
                              T('Please narrow your search.');

  MemoSearch.LoadText(text);
  Cursor := crArrow;
  SelectPage(apSearch);
  UpdateStatus(ToStr(count) + ' ' + T('verses found'));
end;

procedure TMainForm.LoadCompare;
var
  text : string;
  Next, Prev : TVerse;
begin
  text := '';
  if CurrBible.PrevVerse(CurrVerse, Prev) then
    text += '« <l>' + CurrBible.VerseToStr(Prev) + '</l>  ';
  text += CurrBible.VerseToStr(CurrVerse);
  if CurrBible.NextVerse(CurrVerse, Next) then
    text += '  <l>' + CurrBible.VerseToStr(Next) + '</l> »';
  text += '<br> ';
  text += ProcessNotes(Tools.Get_Compare, False);
  MemoCompare.LoadText(text);
  ApplySpacing(MemoCompare);
  SelectPage(apCompare);
end;

procedure TMainForm.LoadReference;
var
  text, data: string;
  info : string = '';
begin
  text := CurrBible.VerseToStr(CurrVerse) + '<br><br>';
  data := Tools.Get_Reference(info);
  if data.isEmpty then text += T('Сross-references not found.') else text += data;
  MemoReference.LoadText(text);
  SelectPage(apReferences);
  UpdateStatus(info);
end;

procedure TMainForm.LoadCommentary;
var
  text, data : string;
begin
  text := CurrBible.VerseToStr(CurrVerse) + '<br><br>';
  data := Tools.Get_Commentary;
  text += data;

  if data.isEmpty then text += T('Commentaries not found.') + '<br><br>';

  MemoCommentary.LoadHtml(text);
  SelectPage(apCommentaries);
end;

procedure TMainForm.LoadDictionary(s: string);
var
  text : string = '';
  data : string;
begin
  s := Trim(s);
  data := Tools.Get_Dictionary(s);
  text += data;

  if data.IsEmpty and not s.IsEmpty then
    text += T('You search for % produced no results.').Replace('%',DoubleQuoted(s));

  if s.isEmpty then text := T('Please enter your query in the search bar.');
  text += '<br><br>';

  MemoDictionary.LoadHtml(text);
  SelectPage(apDictionaries);
end;

procedure TMainForm.LoadHistory;
var
  text : string;
begin
  text := Tools.Get_History;
  MemoHistory.LoadText(text);
  SelectPage(apHistory);
end;

procedure TMainForm.LoadStrong(s: string);
var text : string;
begin
  text := Tools.Get_Strong(s);
  if text.isEmpty then Exit;
  ThemePopup;
  NotifyForm.Title.Caption := T('Strong''s Dictionary');
  NotifyForm.Compact := True;
  NotifyForm.Memo.LoadHtml(text);
  NotifyForm.ShowAtPos(Mouse.CursorPos);
  Self.SetFocus;
end;

procedure TMainForm.LoadFootnote(s: string);
var text : string;
begin
  text := Tools.Get_Footnote(s);
  if text.isEmpty then Exit;
  ThemePopup;
  NotifyForm.Title.Caption := T('Footnote');
  NotifyForm.Compact := False;
  NotifyForm.Memo.LoadHtml(text);
  NotifyForm.ShowAtPos(Mouse.CursorPos);
  Self.SetFocus;
end;

// Grey notes are <n>...</n>. Hide removes them. Hover (Bible page only) replaces each one
// with a numbered marker [+n] and keeps its text in GreyNotes for the hover popup.
function TMainForm.ProcessNotes(const s: string; bible: boolean): string;
var
  a, b, start : integer;
  marker : string;
begin
  Result := s;
  GreyNotes.Clear;

  if (NoteMode = noteShow) or ((NoteMode = noteHover) and not bible) then Exit;

  start := 1;
  while start <= Length(Result) do
    begin
      a := Pos('<n>', Copy(Result, start, MaxInt));
      if a = 0 then Break;
      a += start - 1;
      b := Pos('</n>', Copy(Result, a, MaxInt));
      if b = 0 then Break;
      b += a - 1;

      if NoteMode = noteHover then
        begin
          GreyNotes.Add(Copy(Result, a + 3, b - a - 3));
          marker := '<n>[+' + ToStr(GreyNotes.Count) + ']</n>';
          Delete(Result, a, b + 4 - a);
          Insert(marker, Result, a);
          start := a + Length(marker);
        end
      else
        begin
          Delete(Result, a, b + 4 - a);
          // tidy the spacing left behind: "a  b" and "a ."
          if (a > 1) and (a <= Length(Result)) and (Result[a-1] = ' ') and
             (Result[a] in [' ', '.', ',', ';', ':', '!', '?', ')']) then
            begin
              Delete(Result, a-1, 1);
              a -= 1;
            end;
          start := a;
        end;
    end;
end;

procedure TMainForm.MemoBibleMouseMove(Sender: TObject; Shift: TShiftState; X, Y: integer);
var
  index : integer;
  Pos : TPoint;
begin
  if NoteMode <> noteHover then Exit;
  if ssLeft in Shift then Exit; // selecting text

  if not MemoBible.NoteAt(X, Y, index) or (index > GreyNotes.Count) then
    begin
      HoverIndex := 0; // the timer closes the popup shortly after the pointer has left
      Exit;
    end;

  if HoverIndex = index then Exit; // already shown
  HoverIndex := index;

  ThemePopup;
  NotifyForm.Title.Caption := T('Notes');
  NotifyForm.Compact := False;
  NotifyForm.Memo.LoadHtml(GreyNotes[index - 1]);

  // below and to the right of the pointer, so the popup does not cover the marker
  Pos := Mouse.CursorPos;
  Pos.x += 14;
  Pos.y += 18;
  NotifyForm.ShowAtPos(Pos);
  Self.SetFocus;
  HoverTimer.Enabled := NotifyForm.Visible;
end;

procedure TMainForm.HoverTimerTick(Sender: TObject);
var
  Pos : TPoint;
begin
  if (not NotifyForm.Visible) or (NoteMode <> noteHover) or
     (NotifyForm.Title.Caption <> T('Notes')) then
    begin
      HoverTimer.Enabled := False;
      Exit;
    end;

  Pos := Mouse.CursorPos;
  if (Pos.x >= NotifyForm.Left) and (Pos.x < NotifyForm.Left + NotifyForm.Width) and
     (Pos.y >= NotifyForm.Top)  and (Pos.y < NotifyForm.Top + NotifyForm.Height) then Exit; // on the popup
  if HoverIndex > 0 then Exit; // still on a marker

  NotifyForm.Close;
  HoverTimer.Enabled := False;
end;

{$ifdef windows}
procedure TMainForm.VersesToClipboard;
var
  s, t : string;
begin
  s := Tools.Get_Verses;
  if CopyOptions.cvPlain then CopyForm.RemoveFormat(s);
  t := s.Replace('<br>', LineBreak);
  RichTextToClipboard(ParseWin(s,Font), RemoveTags(t));
end;
{$endif}

{$ifdef unix}
procedure TMainForm.VersesToClipboard;
var
  MemoPreview : TUnboundMemo;
begin
  MemoPreview := TUnboundMemo.Create(self);
  MemoPreview.Parent := MainForm;
  MemoPreview.Font.Assign(Font);
  MemoPreview.LoadText(Tools.Get_Verses);
  MemoPreview.SelectAll;
  MemoPreview.CopyToClipboard;
  MemoPreview.Visible := false;
  MemoPreview.FreeOnRelease;
end;
{$endif}

procedure TMainForm.HideCursor;
begin
  if PageControl.ActivePageIndex <> apNotes then UnboundMemo.HideCursor;
end;

//-------------------------------------------------------------------------------------------------

procedure TMainForm.SaveConfig;
var
  IniFile : TIniFile;
  item : string;
begin
  IniFile := TIniFile.Create(ConfigFile);

  if WindowState = wsNormal then
  begin
    IniFile.WriteInteger('Window', 'Left',   Left);
    IniFile.WriteInteger('Window', 'Top',    Top);
    IniFile.WriteInteger('Window', 'Width',  Width);
    IniFile.WriteInteger('Window', 'Height', Height);
  end;

  if WindowState = wsMaximized then IniFile.WriteString('Window', 'State', 'Maximized')
                               else IniFile.WriteString('Window', 'State', 'Normal');

  IniFile.WriteInteger('Window', 'Splitter', PanelLeft.Width);
  IniFile.WriteString ('Application', 'Interface', Localization.id);
  IniFile.WriteString ('Application', 'FontName', Font.Name);
  IniFile.WriteInteger('Application', 'FontSize', Font.Size);
  IniFile.WriteString ('Application', 'Theme', ThemeName);
  IniFile.WriteInteger('Application', 'GreyNotes', NoteMode);
  IniFile.WriteInteger('Application', 'LineSpacing', SpacingIndex);
  IniFile.WriteBool   ('Application', 'DailyVerse', DailyVerse);
  PlanSave(IniFile);
  IniFile.WriteBool('Copy', 'Abbreviate', CopyOptions.cvAbbreviate);
  IniFile.WriteBool('Copy', 'Enumerated', CopyOptions.cvEnumerated);
  IniFile.WriteBool('Copy', 'Guillemets', CopyOptions.cvGuillemets);
  IniFile.WriteBool('Copy', 'Parentheses', CopyOptions.cvParentheses);
  IniFile.WriteBool('Copy', 'End', CopyOptions.cvEnd);
  IniFile.WriteBool('Copy', 'Break', CopyOptions.cvBreak);
  IniFile.WriteBool('Copy', 'Plain', CopyOptions.cvPlain);
  IniFile.WriteBool('Copy', 'Name', CopyOptions.cvName);
  IniFile.WriteBool('Copy', 'NameAbbr', CopyOptions.cvNameAbbr);
  IniFile.WriteInteger('Recent', 'Count', RecentList.Count);

  for item in RecentList do
    IniFile.WriteString('Recent', 'File_' + RecentList.IndexOf(item).ToString, item);

  IniFile.Free;
end;

procedure TMainForm.ReadConfig;
var
  IniFile : TIniFile;
  i, Count : integer;
begin
  IniFile := TIniFile.Create(ConfigFile);

  Height := IniFile.ReadInteger('Window', 'Height', Screen.Height - 220);
  Width := IniFile.ReadInteger('Window', 'Width', Screen.Width - 450);
  Left := IniFile.ReadInteger('Window', 'Left', 200);
  Top := IniFile.ReadInteger('Window', 'Top', 80);

  PanelLeft.Width := IniFile.ReadInteger('Window', 'Splitter', 270);
  Localization.id := IniFile.ReadString('Application', 'Interface', Localization.DefaultID);
  Font.Name := IniFile.ReadString ('Application', 'FontName', Font.Name);
  Font.Size := IniFile.ReadInteger('Application', 'FontSize', Font.Size);
  ThemeName := IniFile.ReadString ('Application', 'Theme', SystemThemeName);
  NoteMode := IniFile.ReadInteger('Application', 'GreyNotes', noteShow);
  SpacingIndex := IniFile.ReadInteger('Application', 'LineSpacing', 0);
  DailyVerse := IniFile.ReadBool('Application', 'DailyVerse', False);
  PlanLoad(IniFile);
  CopyOptions.cvAbbreviate := IniFile.ReadBool('Copy', 'Abbreviate', False);
  CopyOptions.cvEnumerated := IniFile.ReadBool('Copy', 'Enumerated', False);
  CopyOptions.cvGuillemets := IniFile.ReadBool('Copy', 'Guillemets', False);
  CopyOptions.cvParentheses := IniFile.ReadBool('Copy', 'Parentheses', False);
  CopyOptions.cvEnd := IniFile.ReadBool('Copy', 'End', False);
  CopyOptions.cvBreak := IniFile.ReadBool('Copy', 'Break', False);
  CopyOptions.cvPlain := IniFile.ReadBool('Copy', 'Plain', False);
  CopyOptions.cvName := IniFile.ReadBool('Copy', 'Name', False);
  CopyOptions.cvNameAbbr := IniFile.ReadBool('Copy', 'NameAbbr', False);

  Count := IniFile.ReadInteger('Recent', 'Count', RecentList.Count);
  for i := 0 to Count - 1 do
    RecentList.Add(IniFile.ReadString('Recent', 'File_' + ToStr(i), ''));

  IniFile.Free;
  ReloadUserData;
end;

// Reads the bookmarks, highlights, notes and the reading plan from config.ini (again).
procedure TMainForm.ReloadUserData;
var
  IniFile : TIniFile;
  i, Count : integer;
  parts : TStringArray;
  text : string;
begin
  BookmarkList.Clear;
  HighlightList.Clear;
  NoteList.Clear;

  IniFile := TIniFile.Create(ConfigFile);
  try
    Count := IniFile.ReadInteger('Highlights', 'Count', 0);
    for i := 0 to Count - 1 do
      begin
        parts := IniFile.ReadString('Highlights', 'Item_' + ToStr(i), '').Split('|');
        if parts.Count = 4 then
          HighlightList.Values[parts[0] + '|' + parts[1] + '|' + parts[2]] := parts[3];
      end;

    Count := IniFile.ReadInteger('Bookmarks', 'Count', 0);
    for i := 0 to Count - 1 do
      if not IniFile.ReadString('Bookmarks', 'Item_' + ToStr(i), '').IsEmpty then
        BookmarkList.Add(IniFile.ReadString('Bookmarks', 'Item_' + ToStr(i), ''));

    // a note is stored as "book|chapter|verse|text"; the text may contain "|" itself
    Count := IniFile.ReadInteger('VerseNotes', 'Count', 0);
    for i := 0 to Count - 1 do
      begin
        text := IniFile.ReadString('VerseNotes', 'Item_' + ToStr(i), '');
        parts := text.Split('|');
        if parts.Count < 4 then Continue;
        NoteList.Values[parts[0] + '|' + parts[1] + '|' + parts[2]] :=
          Copy(text, Length(parts[0]) + Length(parts[1]) + Length(parts[2]) + 4, MaxInt);
      end;

    PlanLoad(IniFile);
  finally
    IniFile.Free;
  end;
end;

end.

