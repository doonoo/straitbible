unit FormPlan;

// Reading plan dialog ("Bible in a year"). Built in code, no .lfm.

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, ComCtrls, CheckLst;

procedure ShowReadingPlan;

implementation

uses FormMain, UnitPlan, UnitTools, UnitBible, UnitLocal;

type
  TPlanForm = class(TForm)
  private
    LabelDay, LabelToday, LabelProgress : TLabel;
    List : TCheckListBox;
    Progress : TProgressBar;
    Indexes : array of integer;   // chapter index of every line of the list
    procedure Fill;
    procedure ListClickCheck(Sender: TObject);
    procedure NextClick(Sender: TObject);
    procedure MarkClick(Sender: TObject);
    procedure RestartClick(Sender: TObject);
    function  ChapterName(index: integer): string;
  public
    constructor Create(AOwner: TComponent); override;
  end;

function TPlanForm.ChapterName(index: integer): string;
var
  book, chapter : integer;
  Item : TBook;
begin
  PlanChapter(index, book, chapter);
  Item := CurrBible.BookByNum(book);
  if Assigned(Item) then Result := Item.title else Result := '#' + IntToStr(book);
  Result += ' ' + IntToStr(chapter);
end;

constructor TPlanForm.Create(AOwner: TComponent);
var
  B : TButton;
  L : TLabel;
begin
  inherited CreateNew(AOwner);
  Caption := ' ' + T('Reading plan');
  BorderStyle := bsDialog;
  Position := poScreenCenter;
  ClientWidth := 440;
  ClientHeight := 372;

  LabelDay := TLabel.Create(Self);
  LabelDay.Parent := Self;
  LabelDay.Left := 14; LabelDay.Top := 14;
  LabelDay.Font.Style := [fsBold];

  LabelToday := TLabel.Create(Self);
  LabelToday.Parent := Self;
  LabelToday.Left := 14; LabelToday.Top := 40;

  L := TLabel.Create(Self);
  L.Parent := Self;
  L.Left := 14; L.Top := 70;
  L.Caption := T('Tick the chapters you have read');

  List := TCheckListBox.Create(Self);
  List.Parent := Self;
  List.Left := 14; List.Top := 92;
  List.Width := 412; List.Height := 110;
  List.OnClickCheck := ListClickCheck;

  Progress := TProgressBar.Create(Self);
  Progress.Parent := Self;
  Progress.Left := 14; Progress.Top := 218;
  Progress.Width := 412; Progress.Height := 18;
  Progress.Min := 0;
  Progress.Max := PlanChapters;

  LabelProgress := TLabel.Create(Self);
  LabelProgress.Parent := Self;
  LabelProgress.Left := 14; LabelProgress.Top := 242;

  B := TButton.Create(Self);
  B.Parent := Self; B.Caption := T('Go to next unread');
  B.Left := 14; B.Top := 280; B.Width := 200; B.Height := 30;
  B.OnClick := NextClick;

  B := TButton.Create(Self);
  B.Parent := Self; B.Caption := T('Mark today as read');
  B.Left := 226; B.Top := 280; B.Width := 200; B.Height := 30;
  B.OnClick := MarkClick;

  B := TButton.Create(Self);
  B.Parent := Self; B.Caption := T('Restart plan');
  B.Left := 14; B.Top := 326; B.Width := 200; B.Height := 30;
  B.OnClick := RestartClick;

  B := TButton.Create(Self);
  B.Parent := Self; B.Caption := T('Close');
  B.Left := 226; B.Top := 326; B.Width := 200; B.Height := 30;
  B.ModalResult := mrOk;
  B.Default := True;
  B.Cancel := True;

  Fill;
end;

procedure TPlanForm.Fill;
var
  first, last, i, n, day : integer;
begin
  day := PlanDay;
  if day > PlanDays
    then LabelDay.Caption := T('Day') + ' ' + IntToStr(day) + ' (' + T('plan period over') + ')'
    else LabelDay.Caption := T('Day') + ' ' + IntToStr(day) + ' / ' + IntToStr(PlanDays);

  PlanToday(first, last);
  List.Items.Clear;
  SetLength(Indexes, 0);

  if last >= first then
    begin
      LabelToday.Caption := T('Today') + ': ' + ChapterName(first);
      if last > first then LabelToday.Caption := LabelToday.Caption + ' - ' + ChapterName(last);
      for i := first to last do
        begin
          n := List.Items.Add(ChapterName(i));
          List.Checked[n] := PlanIsRead(i);
          SetLength(Indexes, n + 1);
          Indexes[n] := i;
        end;
    end
  else
    LabelToday.Caption := T('Nothing is planned for today.');

  n := PlanReadCount;
  Progress.Position := n;
  LabelProgress.Caption := IntToStr(n) + ' / ' + IntToStr(PlanChapters) + ' ' + T('chapters') +
    '  (' + IntToStr(n * 100 div PlanChapters) + '%)';
end;

procedure TPlanForm.ListClickCheck(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to List.Items.Count - 1 do
    PlanSetRead(Indexes[i], List.Checked[i]);
  MainForm.SaveSettings;
  Fill;
end;

procedure TPlanForm.NextClick(Sender: TObject);
var
  index, book, chapter : integer;
begin
  index := PlanNextUnread;
  if index < 0 then
    begin
      ShowMessage(T('Everything has been read.'));
      Exit;
    end;
  PlanChapter(index, book, chapter);
  MainForm.GoToChapter(book, chapter);
  ModalResult := mrOk;
end;

procedure TPlanForm.MarkClick(Sender: TObject);
var
  i : integer;
begin
  for i := 0 to Length(Indexes) - 1 do PlanSetRead(Indexes[i], True);
  MainForm.SaveSettings;
  Fill;
end;

procedure TPlanForm.RestartClick(Sender: TObject);
begin
  if MessageDlg(T('Restart plan'), T('Start the plan again from today? The chapters marked as read will be cleared.'),
       mtConfirmation, [mbYes, mbNo], 0) <> mrYes then Exit;
  PlanRestart;
  MainForm.SaveSettings;
  Fill;
end;

procedure ShowReadingPlan;
var
  Form : TPlanForm;
begin
  if PlanStart = 0 then
    begin
      PlanRestart; // the first time the plan starts today
      MainForm.SaveSettings;
    end;

  Form := TPlanForm.Create(Application);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

end.
