unit FormOptions;

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TOptionsForm }

  TOptionsForm = class(TForm)
    ButtonAddFont: TButton;
    ButtonTheme: TButton;
    ComboBoxTheme: TComboBox;
    ComboBoxNotes: TComboBox;
    LabelNotes: TLabel;
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
  EditMax.Text := Tools.HistoryMax.ToString;
end;

procedure TOptionsForm.Localize;
begin
  Caption := ' ' + T('Options');
  LabelLang.Caption :=  T('Localization');
  LabelFont.Caption := T('Font');
  LabelTheme.Caption := T('Theme');
  LabelNotes.Caption := T('Grey notes');
  ButtonAddFont.Caption := T('Add font') + '...';
  ButtonTheme.Caption := T('Customize theme') + '...';
  LabelHistory.Caption := T('Maximum verses in history');
  ButtonClose.Caption := T('Close');
end;

procedure TOptionsForm.ComboBoxLangSelect(Sender: TObject);
begin
  Localization.SelectLanguage(ComboBoxLang.Items[ComboBoxLang.ItemIndex]);
  MainForm.LocalizeApplication;
end;

procedure TOptionsForm.ComboBoxFontSelect(Sender: TObject);
begin
  MainForm.Font.Name := ComboBoxFont.Items[ComboBoxFont.ItemIndex];
  MainForm.AssignFont;
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

