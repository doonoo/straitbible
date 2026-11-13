unit UnitPlan;

// Reading plans. The chapters of the plan are read in order, spread evenly over the days of the
// plan. Which chapters have been read is kept for all plans together (a chapter read in one
// plan counts in the others), in the [Plan] section of config.ini.
//
//   0  the whole Bible in a year (1189 chapters, 365 days)
//   1  the New Testament in 90 days
//   2  Psalms and Proverbs in 60 days

interface

uses
  Classes, SysUtils, IniFiles;

const
  PlanChapters = 1189;  // chapters in the Bible
  PlanTypes = 3;

var
  PlanStart : TDateTime = 0;  // 0 = no plan started
  PlanType : integer = 0;
  PlanRead : string = '';     // one char per chapter of the Bible: '1' read, '0' not read

procedure PlanLoad(Ini: TIniFile);
procedure PlanSave(Ini: TIniFile);
procedure PlanRestart;                                              // starts again today, keeps what has been read
procedure PlanClearRead;
procedure PlanChapter(index: integer; out book, chapter: integer); // index 0 .. PlanChapters-1
function  PlanFirst: integer;                                       // first chapter of the plan
function  PlanLast: integer;                                        // last chapter of the plan
function  PlanSize: integer;                                        // number of chapters of the plan
function  PlanLength: integer;                                      // number of days of the plan
function  PlanDay: integer;                                         // 1 on the first day, 0 = not started
procedure PlanToday(out first, last: integer);                      // chapter indexes of today
function  PlanIsRead(index: integer): boolean;
procedure PlanSetRead(index: integer; value: boolean);
function  PlanReadCount: integer;                                   // chapters of the plan that have been read
function  PlanNextUnread: integer;                                  // -1 when the whole plan has been read

implementation

const
  ChaptersInBook : array [1..66] of integer = (
    50,40,27,36,34,24,21,4,31,24,22,25,29,36,10,13,10,42,150,31,12,8,66,52,5,48,12,14,3,9,
    1,4,7,3,3,3,2,14,4,28,16,24,21,28,16,16,13,6,6,4,4,5,3,6,4,3,1,13,5,5,3,5,1,1,1,22);

// index of the first chapter of a book
function BookStart(book: integer): integer;
var
  b : integer;
begin
  Result := 0;
  for b := 1 to book - 1 do Result += ChaptersInBook[b];
end;

procedure FixRead;
begin
  if Length(PlanRead) <> PlanChapters then
    PlanRead := StringOfChar('0', PlanChapters);
end;

procedure PlanLoad(Ini: TIniFile);
begin
  PlanStart := Ini.ReadFloat('Plan', 'Start', 0);
  PlanType := Ini.ReadInteger('Plan', 'Type', 0);
  if (PlanType < 0) or (PlanType >= PlanTypes) then PlanType := 0;
  PlanRead := Ini.ReadString('Plan', 'Read', '');
  FixRead;
end;

procedure PlanSave(Ini: TIniFile);
begin
  Ini.WriteFloat('Plan', 'Start', PlanStart);
  Ini.WriteInteger('Plan', 'Type', PlanType);
  Ini.WriteString('Plan', 'Read', PlanRead);
end;

procedure PlanRestart;
begin
  PlanStart := Trunc(Date);
end;

procedure PlanClearRead;
begin
  PlanRead := StringOfChar('0', PlanChapters);
end;

procedure PlanChapter(index: integer; out book, chapter: integer);
var
  b : integer;
begin
  book := 66;
  chapter := ChaptersInBook[66];
  if index < 0 then index := 0;
  for b := 1 to 66 do
    begin
      if index < ChaptersInBook[b] then
        begin
          book := b;
          chapter := index + 1;
          Exit;
        end;
      index -= ChaptersInBook[b];
    end;
end;

function PlanFirst: integer;
begin
  case PlanType of
    1 : Result := BookStart(40);   // Matthew
    2 : Result := BookStart(19);   // Psalms
  else
    Result := 0;
  end;
end;

function PlanLast: integer;
begin
  case PlanType of
    1 : Result := PlanChapters - 1;
    2 : Result := BookStart(21) - 1; // the end of Proverbs
  else
    Result := PlanChapters - 1;
  end;
end;

function PlanSize: integer;
begin
  Result := PlanLast - PlanFirst + 1;
end;

function PlanLength: integer;
begin
  case PlanType of
    1 : Result := 90;
    2 : Result := 60;
  else
    Result := 365;
  end;
end;

function PlanDay: integer;
begin
  if PlanStart = 0 then Exit(0);
  Result := Trunc(Date) - Trunc(PlanStart) + 1;
  if Result < 1 then Result := 1;
end;

procedure PlanToday(out first, last: integer);
var
  d : integer;
begin
  d := PlanDay;
  if d < 1 then d := 1;
  first := PlanFirst + ((d - 1) * PlanSize) div PlanLength;
  last := PlanFirst + (d * PlanSize) div PlanLength - 1;
  if first > PlanLast then first := PlanLast + 1;
  if last > PlanLast then last := PlanLast;
end;

function PlanIsRead(index: integer): boolean;
begin
  FixRead;
  Result := (index >= 0) and (index < PlanChapters) and (PlanRead[index + 1] = '1');
end;

procedure PlanSetRead(index: integer; value: boolean);
begin
  FixRead;
  if (index < 0) or (index >= PlanChapters) then Exit;
  if value then PlanRead[index + 1] := '1' else PlanRead[index + 1] := '0';
end;

function PlanReadCount: integer;
var
  i : integer;
begin
  FixRead;
  Result := 0;
  for i := PlanFirst to PlanLast do
    if PlanRead[i + 1] = '1' then Result += 1;
end;

function PlanNextUnread: integer;
var
  i : integer;
begin
  FixRead;
  for i := PlanFirst to PlanLast do
    if PlanRead[i + 1] = '0' then Exit(i);
  Result := -1;
end;

end.
