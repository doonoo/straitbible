unit FormTheme;

// Dialog for creating and editing a custom theme. Built in code, no .lfm.

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, UnitTheme;

// Edits a copy of Theme. Returns True when the user saved a theme (Theme.name is the saved name).
function EditTheme(var Theme: TTheme): boolean;

implementation

uses UnitLocal;

const
  Count = 8;

type
  TThemeEditor = class(TForm)
  private
    EditName : TEdit;
    Swatch : array [0..Count-1] of TPanel;
    Preview : TLabel;
    procedure SwatchClick(Sender: TObject);
    procedure UpdatePreview;
    procedure SaveClick(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

const
  Captions : array [0..Count-1] of string = (
    'Background', 'Text', 'Links', 'Strong''s numbers', 'Footnotes',
    'Words of Christ', 'Notes', 'Cross-references');

constructor TThemeEditor.Create(AOwner: TComponent);
var
  i : integer;
  L : TLabel;
  B : TButton;
begin
  inherited CreateNew(AOwner);
  Caption := ' ' + T('Customize theme');
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := 420;
  ClientHeight := 40 + Count * 32 + 110;

  L := TLabel.Create(Self);
  L.Parent := Self; L.Left := 12; L.Top := 16; L.Caption := T('Name');
  EditName := TEdit.Create(Self);
  EditName.Parent := Self; EditName.Left := 140; EditName.Top := 12; EditName.Width := 268;

  for i := 0 to Count-1 do
    begin
      L := TLabel.Create(Self);
      L.Parent := Self; L.Left := 12; L.Top := 56 + i*32; L.Caption := T(Captions[i]);

      Swatch[i] := TPanel.Create(Self);
      with Swatch[i] do
        begin
          Parent := Self;
          Left := 140; Top := 50 + i*32; Width := 120; Height := 26;
          BevelOuter := bvNone; BorderStyle := bsSingle;
          ParentBackground := False;
          Cursor := crHandPoint;
          Tag := i;
          OnClick := SwatchClick;
        end;
    end;

  Preview := TLabel.Create(Self);
  Preview.Parent := Self;
  Preview.AutoSize := False;
  Preview.Left := 12; Preview.Width := 396;
  Preview.Top := 50 + Count*32 + 6; Preview.Height := 48;
  Preview.Caption := 'In the beginning God created the heaven and the earth.';
  Preview.Layout := tlCenter;
  Preview.Alignment := taCenter;
  Preview.WordWrap := True;

  B := TButton.Create(Self);
  B.Parent := Self; B.Caption := T('Save');
  B.Left := 12; B.Width := 100; B.Top := ClientHeight - 36;
  B.Default := True;
  B.OnClick := SaveClick;

  B := TButton.Create(Self);
  B.Parent := Self; B.Caption := T('Cancel');
  B.Left := 120; B.Width := 100; B.Top := ClientHeight - 36;
  B.ModalResult := mrCancel;
  B.Cancel := True;
end;

procedure TThemeEditor.UpdatePreview;
begin
  Preview.Color := Swatch[0].Color;
  Preview.Font.Color := Swatch[1].Color;
end;

procedure TThemeEditor.SwatchClick(Sender: TObject);
var
  Dlg : TColorDialog;
  P : TPanel;
begin
  P := Sender as TPanel;
  Dlg := TColorDialog.Create(Self);
  try
    Dlg.Color := P.Color;
    if Dlg.Execute then
      begin
        P.Color := Dlg.Color;
        UpdatePreview;
      end;
  finally
    Dlg.Free;
  end;
end;

procedure TThemeEditor.SaveClick(Sender: TObject);
var
  T_ : TTheme;
begin
  T_.name := Trim(EditName.Text);
  T_.background := Swatch[0].Color; T_.text     := Swatch[1].Color;
  T_.link       := Swatch[2].Color; T_.strong   := Swatch[3].Color;
  T_.footnote   := Swatch[4].Color; T_.words    := Swatch[5].Color;
  T_.note       := Swatch[6].Color; T_.red      := Swatch[7].Color;

  if T_.name = '' then
    begin
      ShowMessage(T('Please enter a name for the theme.'));
      Exit;
    end;
  if IsBuiltInTheme(T_.name) or SameText(T_.name, SystemThemeName) then
    begin
      ShowMessage(T('This name is used by a built-in theme. Please choose another name.'));
      Exit;
    end;
  if not SaveTheme(T_) then
    begin
      ShowMessage(T('The theme could not be saved.'));
      Exit;
    end;
  ModalResult := mrOk;
end;

function EditTheme(var Theme: TTheme): boolean;
var
  Form : TThemeEditor;
begin
  Form := TThemeEditor.Create(Application);
  try
    // a built-in theme is a starting point: save it under a new name
    if IsBuiltInTheme(Theme.name) or SameText(Theme.name, SystemThemeName)
      then Form.EditName.Text := ''
      else Form.EditName.Text := Theme.name;
    Form.Swatch[0].Color := Theme.background; Form.Swatch[1].Color := Theme.text;
    Form.Swatch[2].Color := Theme.link;       Form.Swatch[3].Color := Theme.strong;
    Form.Swatch[4].Color := Theme.footnote;   Form.Swatch[5].Color := Theme.words;
    Form.Swatch[6].Color := Theme.note;       Form.Swatch[7].Color := Theme.red;
    Form.UpdatePreview;

    Result := Form.ShowModal = mrOk;
    if Result then
      begin
        Theme.name := Trim(Form.EditName.Text);
        Theme.background := Form.Swatch[0].Color; Theme.text     := Form.Swatch[1].Color;
        Theme.link       := Form.Swatch[2].Color; Theme.strong   := Form.Swatch[3].Color;
        Theme.footnote   := Form.Swatch[4].Color; Theme.words    := Form.Swatch[5].Color;
        Theme.note       := Form.Swatch[6].Color; Theme.red      := Form.Swatch[7].Color;
      end;
  finally
    Form.Free;
  end;
end;

end.
