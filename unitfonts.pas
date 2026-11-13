unit UnitFonts;

// Extra fonts: every .ttf / .otf placed in the "fonts" folder next to the program
// (bundled fonts) or in the "Fonts" folder of the data directory (user fonts) is
// made available to the application.
//
// Windows: fonts are registered privately for this process (nothing is installed).
// Linux:   fonts are copied to ~/.local/share/fonts/unboundbible and the font cache is
//          refreshed; they become visible the next time the application starts.

interface

uses
  Classes, SysUtils;

function UserFontsPath: string;
function BundledFontsPath: string;
procedure LoadFonts;
function InstallFont(const FileName: string): boolean;

implementation

uses
  Forms, FileUtil, LazFileUtils, UnitUtils
  {$ifdef windows}, Windows {$endif}
  {$ifdef unix}, Process {$endif};

{$ifdef windows}
function AddFontResourceExW(lpszFilename: PWideChar; fl: DWORD; pdv: Pointer): LongInt;
  stdcall; external 'gdi32.dll' name 'AddFontResourceExW';
const
  FR_PRIVATE = $10;
{$endif}

function UserFontsPath: string;
begin
  Result := DataPath + DirectorySeparator + 'Fonts';
end;

function BundledFontsPath: string;
begin
  Result := Application.Location + 'fonts';
end;

{$ifdef unix}
function SystemFontsPath: string;
begin
  Result := GetUserDir + '.local/share/fonts/unboundbible';
end;

procedure RefreshFontCache;
var
  s : string = '';
begin
  try RunCommand('fc-cache', ['-f', SystemFontsPath], s); except end;
end;
{$endif}

// returns True when a font file was added in this call
function RegisterFont(const FileName: string): boolean;
{$ifdef unix}
var
  target : string;
{$endif}
begin
  {$ifdef windows}
    Result := AddFontResourceExW(PWideChar(UTF8Decode(FileName)), FR_PRIVATE, nil) > 0;
  {$endif}
  {$ifdef unix}
    Result := False;
    ForceDirectories(SystemFontsPath);
    target := SystemFontsPath + DirectorySeparator + ExtractFileName(FileName);
    if FileExists(target) then Exit;
    Result := FileUtil.CopyFile(FileName, target);
  {$endif}
end;

procedure LoadFolder(const Path: string; var added: boolean);
var
  List : TStringList;
  item : string;
begin
  if not DirectoryExists(Path) then Exit;
  List := FindAllFiles(Path, '*.ttf;*.otf;*.TTF;*.OTF', False);
  try
    for item in List do
      if RegisterFont(item) then added := True;
  finally
    List.Free;
  end;
end;

procedure LoadFonts;
var
  added : boolean = False;
begin
  LoadFolder(BundledFontsPath, added);
  LoadFolder(UserFontsPath, added);
  {$ifdef unix} if added then RefreshFontCache; {$endif}
  Screen.Fonts.Clear; // forces the list to be rebuilt on next access
end;

function InstallFont(const FileName: string): boolean;
var
  target : string;
  added : boolean = False;
begin
  Result := False;
  if not FileExists(FileName) then Exit;

  ForceDirectories(UserFontsPath);
  target := UserFontsPath + DirectorySeparator + ExtractFileName(FileName);
  if not FileExists(target) then
    if not FileUtil.CopyFile(FileName, target) then Exit;

  if RegisterFont(target) then added := True;
  {$ifdef unix} if added then RefreshFontCache; {$endif}
  Screen.Fonts.Clear;
  Result := True;
end;

end.
