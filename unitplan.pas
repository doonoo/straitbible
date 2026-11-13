unit UnitPlan;

// "Bible in a year" reading plan. The 1189 chapters of the 66 books are read in order, spread
// evenly over 365 days (about three chapters a day). Which chapters have been read is kept in
// the [Plan] section of config.ini.

interface

uses
  Classes, SysUtils, IniFiles;

const
  PlanChapters = 1189;
  PlanDays = 365;

var
  PlanStart : TDateTime = 0;  // 0 = no plan started
  PlanRead : string = '';     // one char per chapter: '1' read, '0' not read

procedure PlanLoad(Ini: TIniFile);
procedure PlanSave(Ini: TIniFile);
procedure PlanRestart;
procedure PlanChapter(index: integer; out book, chapter: integer); // index 0 .. PlanChapters-1
function  PlanDay: integer;                                         // 1 on the first day, 0 = not started
procedure PlanToday(out first, last: integer);                      // chapter indexes of today
function  PlanIsRead(index: integer): boolean;
procedure PlanSetRead(index: integer; value: boolean);
function  PlanReadCount: integer;
function  PlanNextUnread: integer;                                  // -1 when everything is read

implementation

const
  ChaptersInBook : array [1..66] of integer = (
    50,40,27,36,34,24,21,4,31,24,22,25,29,36,10,13,10,42,150,31,12,8,66,52,5,48,12,14,3,9,
    1,4,7,3,3,3,2,14,4,28,16,24,21,28,16,16,13,6,6,4,4,5,3,6,4,3,1,13,5,5,3,5,1,1,1,22);

procedure FixRead;
begin
  if Length(PlanRead) <> PlanChapters then
    PlanRead := StringOfChar('0', PlanChapters);
end;

procedure PlanLoad(Ini: TIniFile);
begin
  PlanStart := Ini.ReadFloat('Plan', 'Start', 0);
  PlanRead := Ini.ReadString('Plan', 'Read', '');
  FixRead;
end;

procedure PlanSave(Ini: TIniFile);
begin
  Ini.WriteFloat('Plan', 'Start', PlanStart);
  Ini.WriteString('Plan', 'Read', PlanRead);
end;

procedure PlanRestart;
begin
  PlanStart := Trunc(Date);
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
  first := ((d - 1) * PlanChapters) div PlanDays;
  last := (d * PlanChapters) div PlanDays - 1;
  if first > PlanChapters - 1 then first := PlanChapters;
  if last > PlanChapters - 1 then last := PlanChapters - 1;
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
  for i := 1 to PlanChapters do
    if PlanRead[i] = '1' then Result += 1;
end;

function PlanNextUnread: integer;
var
  i : integer;
begin
  FixRead;
  for i := 1 to PlanChapters do
    if PlanRead[i] = '0' then Exit(i - 1);
  Result := -1;
end;

end.
