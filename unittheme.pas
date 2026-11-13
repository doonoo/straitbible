unit UnitTheme;

// Color themes. A theme sets the text area colors and the colors of links, Strong's
// numbers, footnotes, words of Christ, notes and cross references.
//
// Built-in themes are defined here. Custom themes are plain .ini files in the "Themes"
// folder of the data directory (created by the Customize dialog, or written by hand):
//
//   [Theme]
//   Background=FFFFFF
//   Text=000000
//   Link=000080
//   Strong=996633
//   Footnote=008080
//   Words=800000
//   Note=808080
//   Red=FF0000
//
// Colors are RRGGBB hex values.

interface

uses
  Classes, SysUtils, Graphics, IniFiles, UnitLib;

type
  TTheme = record
    name : string;
    background, text, link, strong, footnote, words, note, red : TColor;
  end;

const
  SystemThemeName = 'System default';

function ThemesPath: string;
procedure GetThemeNames(List: TStrings);
function LoadTheme(const name: string; out Theme: TTheme): boolean;
function SaveTheme(const Theme: TTheme): boolean;
function IsBuiltInTheme(const name: string): boolean;
function ThemeFileName(const name: string): string;
procedure ActivateTheme(const Theme: TTheme);
procedure DeactivateTheme;
function ColorToHex(c: TColor): string;

implementation

uses UnitUtils;

type
  TBuiltIn = record
    name : string;
    c : array [0..7] of TColor; // background, text, link, strong, footnote, words, note, red
  end;

const
  BuiltIn : array [0..4] of TBuiltIn = (
    (name: 'Light';
     c: ($FFFFFF, $000000, $800000, $336699, $808000, $000080, $808080, $0000FF)),
    (name: 'Dark';
     c: ($1E1E1E, $DCDCDC, $FF9900, $1F97FD, $CCCC66, $4242E5, $A0A0A0, $5050FF)),
    (name: 'Sepia';
     c: ($DCF0F8, $20384F, $802000, $1E5A8C, $5A7A00, $000080, $6E7F8B, $0000C0)),
    (name: 'Solarized Dark';
     c: ($362B00, $969483, $D28B26, $0089B5, $98A12A, $2F32DC, $756E58, $2F32DC)),
    (name: 'High Contrast';
     c: ($000000, $FFFFFF, $FFFF00, $00FFFF, $FFFF00, $00A5FF, $C0C0C0, $4040FF))
  );

function ThemesPath: string;
begin
  Result := DataPath + DirectorySeparator + 'Themes';
end;

function SafeName(const name: string): string;
var
  i : integer;
begin
  Result := Trim(name);
  for i := 1 to Length(Result) do
    if Result[i] in ['\','/',':','*','?','"','<','>','|'] then Result[i] := '_';
end;

function ThemeFileName(const name: string): string;
begin
  Result := ThemesPath + DirectorySeparator + SafeName(name) + '.ini';
end;

function ColorToHex(c: TColor): string;
begin
  c := ColorToRGB(c);
  Result := IntToHex(Red(c), 2) + IntToHex(Green(c), 2) + IntToHex(Blue(c), 2);
end;

function HexToColor(s: string; default: TColor): TColor;
var
  n : longint;
begin
  s := Trim(s);
  if (s <> '') and (s[1] = '#') then Delete(s, 1, 1);
  if (Length(s) <> 6) or not TryStrToInt('$' + s, n) then Exit(default);
  Result := RGBToColor((n shr 16) and $FF, (n shr 8) and $FF, n and $FF);
end;

function IsBuiltInTheme(const name: string): boolean;
var
  i : integer;
begin
  for i := 0 to High(BuiltIn) do
    if SameText(BuiltIn[i].name, name) then Exit(True);
  Result := False;
end;

procedure GetThemeNames(List: TStrings);
var
  i : integer;
  SR : TSearchRec;
  n : string;
begin
  List.Clear;
  List.Add(SystemThemeName);
  for i := 0 to High(BuiltIn) do List.Add(BuiltIn[i].name);

  if FindFirst(ThemesPath + DirectorySeparator + '*.ini', faAnyFile, SR) = 0 then
    begin
      repeat
        n := ChangeFileExt(SR.Name, '');
        if List.IndexOf(n) < 0 then List.Add(n);
      until FindNext(SR) <> 0;
      FindClose(SR);
    end;
end;

function LoadTheme(const name: string; out Theme: TTheme): boolean;
var
  i : integer;
  Ini : TIniFile;
  Base : TTheme;
begin
  Result := False;

  // defaults come from the Light theme so a hand-written file may leave colors out
  Base.name := name;
  Base.background := BuiltIn[0].c[0]; Base.text := BuiltIn[0].c[1];
  Base.link := BuiltIn[0].c[2];       Base.strong := BuiltIn[0].c[3];
  Base.footnote := BuiltIn[0].c[4];   Base.words := BuiltIn[0].c[5];
  Base.note := BuiltIn[0].c[6];       Base.red := BuiltIn[0].c[7];
  Theme := Base;

  for i := 0 to High(BuiltIn) do
    if SameText(BuiltIn[i].name, name) then
      begin
        Theme.name := BuiltIn[i].name;
        Theme.background := BuiltIn[i].c[0]; Theme.text := BuiltIn[i].c[1];
        Theme.link := BuiltIn[i].c[2];       Theme.strong := BuiltIn[i].c[3];
        Theme.footnote := BuiltIn[i].c[4];   Theme.words := BuiltIn[i].c[5];
        Theme.note := BuiltIn[i].c[6];       Theme.red := BuiltIn[i].c[7];
        Exit(True);
      end;

  if not FileExists(ThemeFileName(name)) then Exit;

  Ini := TIniFile.Create(ThemeFileName(name));
  try
    Theme.background := HexToColor(Ini.ReadString('Theme', 'Background', ''), Base.background);
    Theme.text       := HexToColor(Ini.ReadString('Theme', 'Text',       ''), Base.text);
    Theme.link       := HexToColor(Ini.ReadString('Theme', 'Link',       ''), Base.link);
    Theme.strong     := HexToColor(Ini.ReadString('Theme', 'Strong',     ''), Base.strong);
    Theme.footnote   := HexToColor(Ini.ReadString('Theme', 'Footnote',   ''), Base.footnote);
    Theme.words      := HexToColor(Ini.ReadString('Theme', 'Words',      ''), Base.words);
    Theme.note       := HexToColor(Ini.ReadString('Theme', 'Note',       ''), Base.note);
    Theme.red        := HexToColor(Ini.ReadString('Theme', 'Red',        ''), Base.red);
  finally
    Ini.Free;
  end;
  Result := True;
end;

function SaveTheme(const Theme: TTheme): boolean;
var
  Ini : TIniFile;
begin
  Result := False;
  if (SafeName(Theme.name) = '') or IsBuiltInTheme(Theme.name) then Exit;
  ForceDirectories(ThemesPath);
  try
    Ini := TIniFile.Create(ThemeFileName(Theme.name));
    try
      Ini.WriteString('Theme', 'Background', ColorToHex(Theme.background));
      Ini.WriteString('Theme', 'Text',       ColorToHex(Theme.text));
      Ini.WriteString('Theme', 'Link',       ColorToHex(Theme.link));
      Ini.WriteString('Theme', 'Strong',     ColorToHex(Theme.strong));
      Ini.WriteString('Theme', 'Footnote',   ColorToHex(Theme.footnote));
      Ini.WriteString('Theme', 'Words',      ColorToHex(Theme.words));
      Ini.WriteString('Theme', 'Note',       ColorToHex(Theme.note));
      Ini.WriteString('Theme', 'Red',        ColorToHex(Theme.red));
    finally
      Ini.Free;
    end;
    Result := True;
  except
    Result := False;
  end;
end;

procedure ActivateTheme(const Theme: TTheme);
begin
  ThemeLink     := Theme.link;
  ThemeStrong   := Theme.strong;
  ThemeFootnote := Theme.footnote;
  ThemeWords    := Theme.words;
  ThemeNote     := Theme.note;
  ThemeRed      := Theme.red;
  ThemeEnabled  := True;
end;

procedure DeactivateTheme;
begin
  ThemeEnabled := False;
end;

end.
