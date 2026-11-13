unit FormOptions;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls;

type

  { TOptionsForm }

  TOptionsForm = class(TForm)
    ButtonAddFont: TButton;
    ButtonTheme: TButton;
    ComboBoxTheme: TComboBox;
    ComboBoxNotes: TComboBox;
    LabelNotes: TLabel;
    ComboBoxSpacing: TComboBox;
    LabelSpacing: TLabel;
    CheckDaily: TCheckBox;
    CheckJustify: TCheckBox;
    ComboBoxNight: TComboBox;
    LabelNight: TLabel;
    ComboBoxMargins: TComboBox;
    LabelMargins: TLabel;
    LabelBackground: TLabel;
    ButtonBackground: TButton;
    ButtonBackgroundClear: TButton;
    LabelBgMode: TLabel;
    ComboBoxBgMode: TComboBox;
    LabelBgVisible: TLabel;
    TrackBarBg: TTrackBar;
    EditMax: TEdit;
    LabelHistory: TLabel;
    LabelTheme: TLabel;
    LabelFont: TLabel;
    LabelLang: TLabel;
    ComboBoxLang: TComboBox;
    ComboBoxFont: TComboBox;
    ComboBoxSize: TComboBox;
    ButtonClose: TButton;
    procedure ComboBoxNotesSelect(Sender: TObject);
    procedure ComboBoxNightSelect(Sender: TObject);
    procedure ComboBoxMarginsSelect(Sender: TObject);
    procedure CheckJustifyChange(Sender: TObject);
    procedure ButtonBackgroundClick(Sender: TObject);
    procedure ButtonBackgroundClearClick(Sender: TObject);
    procedure ComboBoxBgModeSelect(Sender: TObject);
    procedure TrackBarBgChange(Sender: TObject);
    procedure ComboBoxSpacingSelect(Sender: TObject);
    procedure CheckDailyChange(Sender: TObject);
    procedure ButtonAddFontClick(Sender: TObject);
    procedure ButtonThemeClick(Sender: TObject);
    procedure ComboBoxThemeSelect(Sender: TObject);
    procedure ComboBoxFontSelect(Sender: TObject);
    procedure ComboBoxLangSelect(Sender: TObject);
    procedure ComboBoxSizeSelect(Sender: TObject);
    procedure EditMaxChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
  private
    procedure MakeLangList;
    procedure MakeFontList;
    procedure MakeSizeList;
    procedure MakeThemeList;
    procedure MakeNoteList;
    procedure MakeSpacingList;
    procedure MakeMarginList;
    procedure MakeNightList;
    procedure MakeBackgroundControls;
  public
    procedure Localize;
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.lfm}

uses FormMain, FormTheme, UnitTools, UnitUtils, UnitLocal, UnitLib, UnitTheme, UnitFonts;

procedure TOptionsForm.FormShow(Sender: TObject);
begin
  MakeLangList;
  MakeFontList;
  MakeSizeList;
  MakeThemeList;
  MakeNoteList;
  MakeSpacingList;
  MakeMarginList;
  MakeNightList;
  MakeBackgroundControls;
  CheckJustify.Checked := MainForm.Justify;
  CheckDaily.Checked := MainForm.DailyVerse;
  EditMax.Text := Tools.HistoryMax.ToString;
end;

procedure TOptionsForm.Localize;
begin
  Caption := ' ' + T('Options');
  LabelLang.Caption :=  T('Localization');
  LabelFont.Caption := T('Font');
  LabelTheme.Caption := T('Theme');
  LabelNotes.Caption := T('Grey notes');
  LabelSpacing.Caption := T('Line spacing');
  LabelNight.Caption := T('Night theme');
  LabelMargins.Caption := T('Text margins');
  CheckJustify.Caption := T('Justify the text');
  LabelBackground.Caption := T('Background');
  ButtonBackground.Caption := T('Choose a picture') + '...';
  ButtonBackgroundClear.Caption := T('Remove');
  LabelBgMode.Caption := T('Picture');
  LabelBgVisible.Caption := T('Visibility');
  CheckDaily.Caption := T('Show the verse of the day on startup');
  ButtonAddFont.Caption := T('Add font') + '...';
  ButtonTheme.Caption := T('Customize theme') + '...';
  LabelHistory.Caption := T('Maximum verses in history');
  ButtonClose.Caption := T('Close');
end;

procedure TOptionsForm.ComboBoxLangSelect(Sender: TObject);
begin
  Localization.SelectLanguage(ComboBoxLang.Items[ComboBoxLang.ItemIndex]);
  MainForm.LocalizeApplication;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.ComboBoxFontSelect(Sender: TObject);
begin
  MainForm.Font.Name := ComboBoxFont.Items[ComboBoxFont.ItemIndex];
  MainForm.AssignFont;
  MainForm.Redraw;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.ButtonAddFontClick(Sender: TObject);
var
  Dlg : TOpenDialog;
  item : string;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := T('Add font');
    Dlg.Filter := 'TrueType / OpenType (*.ttf;*.otf)|*.ttf;*.otf;*.TTF;*.OTF';
    Dlg.Options := Dlg.Options + [ofFileMustExist, ofAllowMultiSelect];
    if not Dlg.Execute then Exit;

    for item in Dlg.Files do
      if not InstallFont(item) then
        begin
          ShowMessage(T('The font could not be added.'));
          Exit;
        end;
  finally
    Dlg.Free;
  end;
  MakeFontList;
  {$ifdef linux}
    ShowMessage(T('The font was added. Restart the application to use it.'));
  {$endif}
end;

procedure TOptionsForm.ComboBoxThemeSelect(Sender: TObject);
begin
  MainForm.ThemeName := ComboBoxTheme.Items[ComboBoxTheme.ItemIndex];
  MainForm.ApplyTheme;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.ButtonThemeClick(Sender: TObject);
var
  Theme : TTheme;
begin
  // start from the selected theme (or Light when the system theme is selected)
  if (MainForm.ThemeName = SystemThemeName) or not LoadTheme(MainForm.ThemeName, Theme) then
    LoadTheme('Light', Theme);

  if EditTheme(Theme) then
    begin
      MainForm.ThemeName := Theme.name;
      MakeThemeList;
      MainForm.ApplyTheme;
      MainForm.SaveSettings;
    end;
end;

procedure TOptionsForm.MakeNoteList;
begin
  ComboBoxNotes.Items.Clear;
  ComboBoxNotes.Items.Add(T('Show'));
  ComboBoxNotes.Items.Add(T('Show on hover'));
  ComboBoxNotes.Items.Add(T('Hide'));
  ComboBoxNotes.ItemIndex := MainForm.NoteMode;
end;

procedure TOptionsForm.ComboBoxNotesSelect(Sender: TObject);
begin
  MainForm.NoteMode := ComboBoxNotes.ItemIndex;
  MainForm.Redraw;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.MakeMarginList;
begin
  ComboBoxMargins.Items.Clear;
  ComboBoxMargins.Items.Add(T('None'));
  ComboBoxMargins.Items.Add(T('Small'));
  ComboBoxMargins.Items.Add(T('Medium'));
  ComboBoxMargins.Items.Add(T('Large'));
  ComboBoxMargins.ItemIndex := MainForm.MarginIndex;
end;

procedure TOptionsForm.ComboBoxMarginsSelect(Sender: TObject);
begin
  MainForm.MarginIndex := ComboBoxMargins.ItemIndex;
  MainForm.Redraw;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.CheckJustifyChange(Sender: TObject);
begin
  MainForm.Justify := CheckJustify.Checked;
  MainForm.Redraw;
  MainForm.SaveSettings;
end;

// the night theme is used from 19:00 to 07:00; the first entry means none
procedure TOptionsForm.MakeNightList;
var
  i : integer;
begin
  GetThemeNames(ComboBoxNight.Items);
  ComboBoxNight.Items[0] := T('None'); // replaces "System default" at the top
  i := ComboBoxNight.Items.IndexOf(MainForm.NightTheme);
  if (MainForm.NightTheme = '') or (i < 0) then i := 0;
  ComboBoxNight.ItemIndex := i;
end;

procedure TOptionsForm.ComboBoxNightSelect(Sender: TObject);
begin
  if ComboBoxNight.ItemIndex <= 0 then MainForm.NightTheme := ''
  else MainForm.NightTheme := ComboBoxNight.Items[ComboBoxNight.ItemIndex];
  MainForm.ApplyTheme;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.MakeBackgroundControls;
begin
  ComboBoxBgMode.Items.Clear;
  ComboBoxBgMode.Items.Add(T('Cover the area'));
  ComboBoxBgMode.Items.Add(T('Stretch'));
  ComboBoxBgMode.Items.Add(T('Tile'));
  ComboBoxBgMode.ItemIndex := MainForm.BackgroundMode;
  TrackBarBg.Position := MainForm.BackgroundVisibility;
end;

procedure TOptionsForm.ButtonBackgroundClick(Sender: TObject);
var
  Dlg : TOpenDialog;
begin
  Dlg := TOpenDialog.Create(Self);
  try
    Dlg.Title := T('Choose a picture');
    Dlg.Filter := 'Pictures (*.jpg;*.jpeg;*.png;*.bmp)|*.jpg;*.jpeg;*.png;*.bmp;*.JPG;*.JPEG;*.PNG;*.BMP';
    Dlg.Options := Dlg.Options + [ofFileMustExist];
    if not Dlg.Execute then Exit;
    MainForm.BackgroundFile := Dlg.FileName;
  finally
    Dlg.Free;
  end;
  MainForm.UpdateBackground;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.ButtonBackgroundClearClick(Sender: TObject);
begin
  MainForm.BackgroundFile := '';
  MainForm.UpdateBackground;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.ComboBoxBgModeSelect(Sender: TObject);
begin
  MainForm.BackgroundMode := ComboBoxBgMode.ItemIndex;
  MainForm.UpdateBackground;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.TrackBarBgChange(Sender: TObject);
begin
  if MainForm.BackgroundVisibility = TrackBarBg.Position then Exit;
  MainForm.BackgroundVisibility := TrackBarBg.Position;
  MainForm.UpdateBackground;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.MakeSpacingList;
begin
  ComboBoxSpacing.Items.Clear;
  ComboBoxSpacing.Items.Add(T('Normal'));
  ComboBoxSpacing.Items.Add(T('Relaxed'));
  ComboBoxSpacing.Items.Add(T('Wide'));
  ComboBoxSpacing.Items.Add(T('Double'));
  ComboBoxSpacing.ItemIndex := MainForm.SpacingIndex;
end;

procedure TOptionsForm.ComboBoxSpacingSelect(Sender: TObject);
begin
  MainForm.SpacingIndex := ComboBoxSpacing.ItemIndex;
  MainForm.Redraw;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.CheckDailyChange(Sender: TObject);
begin
  MainForm.DailyVerse := CheckDaily.Checked;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.MakeThemeList;
begin
  GetThemeNames(ComboBoxTheme.Items);
  ComboBoxTheme.ItemIndex := ComboBoxTheme.Items.IndexOf(MainForm.ThemeName);
  if ComboBoxTheme.ItemIndex < 0 then ComboBoxTheme.ItemIndex := 0;
end;

procedure TOptionsForm.ComboBoxSizeSelect(Sender: TObject);
begin
  MainForm.Font.Size := ComboBoxSize.Items[ComboBoxSize.ItemIndex].ToInteger;
  MainForm.AssignFont;
  MainForm.Redraw;
  MainForm.SaveSettings;
end;

procedure TOptionsForm.EditMaxChange(Sender: TObject);
const
  maximum = 1000;
begin
  Tools.HistoryMax := ToInt(EditMax.Text);
  if Tools.HistoryMax > maximum then Tools.HistoryMax := maximum;
end;

procedure TOptionsForm.MakeLangList;
var
  Local : TLocal;
begin
  ComboBoxLang.Items.Clear;

  for Local in Localization do
    begin
      ComboBoxLang.Items.Add(Local.language);
      if Local.id = Localization.id then ComboBoxLang.ItemIndex := ComboBoxLang.Items.Count - 1;
    end;
end;

procedure TOptionsForm.MakeFontList;
var
  FontName: string;
begin
  ComboBoxFont.Items.Clear;
  {$ifdef linux}
    ComboBoxFont.Items.Add('default');
    ComboBoxFont.ItemIndex := 0;
  {$endif}
  for FontName in Screen.Fonts do
    begin
      ComboBoxFont.Items.Add(FontName);
      if FontName = MainForm.Font.Name then ComboBoxFont.ItemIndex := ComboBoxFont.Items.Count - 1;
    end;
end;

procedure TOptionsForm.MakeSizeList;
var
  i : integer;
const
  arr : array [1..14] of integer = (8,9,10,11,12,13,14,16,18,20,22,24,28,32);
begin
  ComboBoxSize.Items.Clear;
  for i in arr do
    begin
      ComboBoxSize.Items.Add(ToStr(i));
      if i = MainForm.Font.Size then ComboBoxSize.ItemIndex := ComboBoxSize.Items.Count - 1;;
    end;
end;

procedure TOptionsForm.ButtonOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TOptionsForm.ButtonCloseClick(Sender: TObject);
begin
  Close;
end;

end.

