unit UnitESword;

// Imports Bible modules of e-Sword (.bblx) into the format of this program (.bbl.mybible).
//
// The modules of e-Sword are SQLite databases like the MySword ones, but the text of a verse may be RTF,
// and the modules downloaded through the e-Sword program have the text encrypted: those cannot be imported.

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TImportResult = (irOk, irEncrypted, irNotModule, irExists, irError);

function ImportESwordBible(const Source, TargetDir: string; out Target: string): TImportResult;
function ESwordText(const s: string; const codec: string = ''): string;

implementation

uses
  LazUtf8, LazFileUtils, LConvEncoding, sqlite3dyn;

//-------------------------------------------------------------------------------------------------
//                                          RTF to text
//-------------------------------------------------------------------------------------------------

function ByteToUtf8(b: byte; const codec: string): string;
var
  c : string;
begin
  if b < $80 then Exit(Chr(b));
  if (codec = '') or (codec = 'cp1252') then
    if b in [$81, $8D, $8F, $90, $9D] then Exit('');   // not assigned in Windows-1252
  c := Chr(b);
  if codec = 'cp1253' then Result := CP1253ToUTF8(c) else
  if codec = 'cp1255' then Result := CP1255ToUTF8(c) else
  if codec = 'cp1256' then Result := CP1256ToUTF8(c) else
  if codec = 'cp1251' then Result := CP1251ToUTF8(c) else
  if codec = 'cp1250' then Result := CP1250ToUTF8(c) else
  if codec = 'cp1254' then Result := CP1254ToUTF8(c) else
  if codec = 'cp1257' then Result := CP1257ToUTF8(c) else
  Result := CP1252ToUTF8(c);
end;

function CharsetToCodec(charset: integer): string;
begin
  case charset of
    161 : Result := 'cp1253';
    162 : Result := 'cp1254';
    177 : Result := 'cp1255';
    178 : Result := 'cp1256';
    186 : Result := 'cp1257';
    204 : Result := 'cp1251';
    238 : Result := 'cp1250';
    else  Result := 'cp1252';
  end;
end;

function IsDigit(c: char): boolean;
begin
  Result := c in ['0'..'9'];
end;

function IsLetter(c: char): boolean;
begin
  Result := c in ['a'..'z', 'A'..'Z'];
end;

// the character sets of the fonts listed in the font table of the text: {\fonttbl{\f1\fcharset161 Arial;}}
procedure ReadFonts(const s: string; out fonts: array of string);
var
  i, j, n, k, depth, cs : integer;
begin
  for i := Low(fonts) to High(fonts) do fonts[i] := '';
  i := Pos('\fonttbl', s);
  if i = 0 then Exit;
  depth := 0;
  n := Length(s);
  j := i;
  // go back to the opening brace of the table
  while (j > 1) and (s[j] <> '{') do Dec(j);
  i := j;
  while i <= n do
    begin
      if s[i] = '{' then Inc(depth);
      if s[i] = '}' then
        begin
          Dec(depth);
          if depth <= 0 then Break;
        end;
      if (s[i] = '\') and (i < n) and (s[i+1] = 'f') and (i+2 <= n) and IsDigit(s[i+2]) then
        begin
          k := 0;
          j := i + 2;
          while (j <= n) and IsDigit(s[j]) do begin k := k * 10 + Ord(s[j]) - 48; Inc(j); end;
          // look for \fcharsetNNN inside this group
          cs := -1;
          while (j <= n) and (s[j] <> '}') and (s[j] <> '{') do
            begin
              if Copy(s, j, 9) = '\fcharset' then
                begin
                  cs := 0;
                  Inc(j, 9);
                  while (j <= n) and IsDigit(s[j]) do begin cs := cs * 10 + Ord(s[j]) - 48; Inc(j); end;
                  Break;
                end;
              Inc(j);
            end;
          if (cs >= 0) and (k <= High(fonts)) then fonts[k] := CharsetToCodec(cs);
        end;
      Inc(i);
    end;
end;

function Collapse(const s: string): string;
var
  i : integer;
  space : boolean;
begin
  Result := '';
  space := false;
  for i := 1 to Length(s) do
    if s[i] in [' ', #9, #10, #13] then space := true
    else
      begin
        if space and (Result <> '') then Result += ' ';
        space := false;
        Result += s[i];
      end;
end;

// RTF -> text with the tags <b> <i> <br> that the program understands. Text without RTF stays as it is.
function ESwordText(const s: string; const codec: string = ''): string;
type
  TGroup = record bold, ital : boolean; skip : integer; end;
var
  fonts : array [0..63] of string;
  stack : array of TGroup;
  out_ : string;
  i, n, num, skip, font : integer;
  bold, ital, neg, hasnum : boolean;
  w, rest : string;
  g : TGroup;

  procedure Flag(name: char; on: boolean);
  begin
    if (name = 'b') and (on <> bold) then
      begin if on then out_ += '<b>' else out_ += '</b>'; bold := on; end;
    if (name = 'i') and (on <> ital) then
      begin if on then out_ += '<i>' else out_ += '</i>'; ital := on; end;
  end;

  function CodecOfFont: string;
  begin
    Result := '';
    if (font >= 0) and (font <= High(fonts)) then Result := fonts[font];
    if (Result = '') and (font <> 0) then Result := codec;
    if Result = '' then Result := 'cp1252';
  end;

begin
  if Pos('\', s) = 0 then Exit(Trim(s));

  ReadFonts(s, fonts);
  SetLength(stack, 0);
  out_ := '';
  bold := false; ital := false;
  skip := 0; font := 0;
  n := Length(s);
  i := 1;

  while i <= n do
    begin
      case s[i] of
        '{' :
          begin
            g.bold := bold; g.ital := ital; g.skip := skip;
            SetLength(stack, Length(stack) + 1);
            stack[High(stack)] := g;
            Inc(i);
            rest := Copy(s, i, 12);
            if (Copy(rest, 1, 2) = '\*') or (Copy(rest, 1, 8) = '\fonttbl') or (Copy(rest, 1, 9) = '\colortbl')
              or (Copy(rest, 1, 11) = '\stylesheet') or (Copy(rest, 1, 5) = '\info') or (Copy(rest, 1, 5) = '\pict')
              then skip := Length(stack);
          end;

        '}' :
          begin
            if Length(stack) > 0 then
              begin
                g := stack[High(stack)];
                SetLength(stack, Length(stack) - 1);
                skip := g.skip;
                Flag('i', g.ital);
                Flag('b', g.bold);
              end;
            Inc(i);
          end;

        '\' :
          begin
            if (i < n) and IsLetter(s[i+1]) then
              begin
                Inc(i);
                w := '';
                while (i <= n) and IsLetter(s[i]) do begin w += s[i]; Inc(i); end;
                neg := false; hasnum := false; num := 0;
                if (i <= n) and (s[i] = '-') then begin neg := true; Inc(i); end;
                while (i <= n) and IsDigit(s[i]) do
                  begin hasnum := true; num := num * 10 + Ord(s[i]) - 48; Inc(i); end;
                if neg then num := -num;
                if (i <= n) and (s[i] = ' ') then Inc(i);

                if skip = 0 then
                  begin
                    if (w = 'b') or (w = 'i') then
                      begin
                        if Length(stack) > 0 then Flag(w[1], not (hasnum and (num = 0)));
                      end
                    else if w = 'f' then begin if hasnum then font := num; end
                    else if w = 'par' then out_ += '<br>'
                    else if w = 'tab' then out_ += ' '
                    else if w = 'plain' then begin Flag('b', false); Flag('i', false); end
                    else if (w = 'u') and hasnum then
                      begin
                        if num < 0 then num += 65536;
                        out_ += UnicodeToUTF8(num);
                        if (i <= n) and (s[i] = '?') then Inc(i);
                      end;
                  end;
              end
            else if (i < n) and (s[i+1] = '''') then
              begin
                if skip = 0 then
                  out_ += ByteToUtf8(StrToIntDef('$' + Copy(s, i + 2, 2), 63), CodecOfFont);
                Inc(i, 4);
              end
            else
              begin
                if (skip = 0) and (i < n) then out_ += s[i+1];
                Inc(i, 2);
              end;
          end;

        else
          begin
            if (skip = 0) and not (s[i] in [#10, #13]) then out_ += s[i];
            Inc(i);
          end;
      end;
    end;

  Flag('i', false);
  Flag('b', false);
  Result := Collapse(out_);
end;

// the description of a module is HTML in e-Sword
function HtmlToText(s: string): string;
var
  i : integer;
  tag : boolean;
begin
  s := StringReplace(s, '</p>', LineEnding, [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '<br />', LineEnding, [rfReplaceAll, rfIgnoreCase]);
  s := StringReplace(s, '<br>', LineEnding, [rfReplaceAll, rfIgnoreCase]);
  Result := '';
  tag := false;
  for i := 1 to Length(s) do
    begin
      if s[i] = '<' then tag := true
      else if s[i] = '>' then tag := false
      else if not tag then Result += s[i];
    end;
  Result := StringReplace(Result, '&nbsp;', ' ', [rfReplaceAll]);
  Result := StringReplace(Result, '&quot;', '"', [rfReplaceAll]);
  Result := StringReplace(Result, '&rsquo;', '’', [rfReplaceAll]);
  Result := StringReplace(Result, '&lsquo;', '‘', [rfReplaceAll]);
  Result := StringReplace(Result, '&copy;', '©', [rfReplaceAll]);
  Result := StringReplace(Result, '&lt;', '<', [rfReplaceAll]);
  Result := StringReplace(Result, '&gt;', '>', [rfReplaceAll]);
  Result := StringReplace(Result, '&amp;', '&', [rfReplaceAll]);
  Result := Trim(Result);
end;

//-------------------------------------------------------------------------------------------------
//                                          SQLite
//-------------------------------------------------------------------------------------------------

function Open(const FileName: string; readonly: boolean; out db: psqlite3): boolean;
var
  flags : integer;
begin
  db := nil;
  if readonly then flags := SQLITE_OPEN_READONLY else flags := SQLITE_OPEN_READWRITE or SQLITE_OPEN_CREATE;
  Result := (sqlite3_open_v2(PAnsiChar(FileName), @db, flags, nil) = SQLITE_OK);
  if not Result and (db <> nil) then begin sqlite3_close(db); db := nil; end;
end;

function Exec(db: psqlite3; const sql: string): boolean;
var
  st : psqlite3_stmt;
begin
  st := nil;
  Result := false;
  if sqlite3_prepare_v2(db, PAnsiChar(sql), -1, @st, nil) <> SQLITE_OK then Exit;
  Result := sqlite3_step(st) in [SQLITE_DONE, SQLITE_ROW];
  sqlite3_finalize(st);
end;

function ColText(st: psqlite3_stmt; i: integer): string;
var
  p : pansichar;
begin
  p := sqlite3_column_text(st, i);
  if p = nil then Result := '' else Result := p;
end;

function ImportESwordBible(const Source, TargetDir: string; out Target: string): TImportResult;
var
  src, dst : psqlite3;
  rd, wr : psqlite3_stmt;
  names, values : array of string;
  tmp, title, abbr, info, version, codec, text : string;
  i, count : integer;
  ot, nt, strong, rtl : boolean;

  function Value(const name: string): string;
  var
    k : integer;
  begin
    Result := '';
    for k := 0 to High(names) do
      if SameText(names[k], name) then Exit(values[k]);
  end;

begin
  Result := irError;
  src := nil; dst := nil; rd := nil; wr := nil;
  Target := IncludeTrailingPathDelimiter(TargetDir) + ExtractFileNameWithoutExt(ExtractFileName(Source)) + '.bbl.mybible';

  if not Assigned(sqlite3_open_v2) then InitialiseSQLite;
  if not Assigned(sqlite3_open_v2) then Exit;
  if FileExists(Target) then Exit(irExists);

  if not Open(Source, true, src) then Exit(irNotModule);
  try
    // the Bible table and its details
    if sqlite3_prepare_v2(src, 'SELECT * FROM Details LIMIT 1', -1, @rd, nil) <> SQLITE_OK then Exit(irNotModule);
    if sqlite3_step(rd) <> SQLITE_ROW then begin sqlite3_finalize(rd); Exit(irNotModule); end;
    SetLength(names, sqlite3_column_count(rd));
    SetLength(values, Length(names));
    for i := 0 to High(names) do
      begin
        names[i] := sqlite3_column_name(rd, i);
        values[i] := ColText(rd, i);
      end;
    sqlite3_finalize(rd); rd := nil;

    if sqlite3_prepare_v2(src, 'SELECT Book, Chapter, Verse, Scripture FROM Bible ORDER BY Book, Chapter, Verse',
      -1, @rd, nil) <> SQLITE_OK then Exit(irNotModule);

    title   := Value('Title');
    if title = '' then title := Value('Description');
    abbr    := Value('Abbreviation');
    info    := Value('Information');
    if info = '' then info := Value('Comments');
    version := Value('Version');
    strong  := (Value('Strongs') = '1') or (Value('Strong') = '1') or (Value('Strongs') = '-1') or (Value('Strong') = '-1');
    rtl     := (Value('RightToLeft') <> '') and (Value('RightToLeft') <> '0');
    codec   := '';
    if SameText(Value('Font'), 'Greek')    then codec := 'cp1253';
    if SameText(Value('Font'), 'Hebrew')   then codec := 'cp1255';
    if SameText(Value('Font'), 'Cyrillic') then codec := 'cp1251';
    if SameText(Value('Font'), 'Arabic')   then codec := 'cp1256';
    ot := false; nt := false;

    tmp := Target + '.part';
    DeleteFile(tmp);
    if not Open(tmp, false, dst) then Exit;

    Exec(dst, 'BEGIN');
    Exec(dst, 'CREATE TABLE Details (Title NVARCHAR(255), Description TEXT, Abbreviation NVARCHAR(50), Comments TEXT, ' +
              'Version TEXT, Language NVARCHAR(3), RightToLeft BOOL, OT BOOL, NT BOOL, Strong BOOL)');
    Exec(dst, 'CREATE TABLE Bible (Book INT, Chapter INT, Verse INT, Scripture TEXT)');
    if sqlite3_prepare_v2(dst, 'INSERT INTO Bible VALUES (?,?,?,?)', -1, @wr, nil) <> SQLITE_OK then Exit;

    count := 0;
    while sqlite3_step(rd) = SQLITE_ROW do
      begin
        if (count = 0) and (sqlite3_column_type(rd, 3) = SQLITE_BLOB) then
          begin
            Result := irEncrypted;
            Exit;
          end;
        i := sqlite3_column_int(rd, 0);
        if i <= 39 then ot := true else if i >= 40 then nt := true;
        text := ESwordText(ColText(rd, 3), codec);
        sqlite3_bind_int(wr, 1, i);
        sqlite3_bind_int(wr, 2, sqlite3_column_int(rd, 1));
        sqlite3_bind_int(wr, 3, sqlite3_column_int(rd, 2));
        sqlite3_bind_text(wr, 4, PAnsiChar(text), Length(text), sqlite3_destructor_type(SQLITE_TRANSIENT));
        sqlite3_step(wr);
        sqlite3_reset(wr);
        Inc(count);
      end;
    sqlite3_finalize(wr); wr := nil;
    if count = 0 then Exit(irNotModule);

    Exec(dst, 'CREATE INDEX BookChapterVerseIndex ON Bible (Book, Chapter, Verse)');

    if sqlite3_prepare_v2(dst, 'INSERT INTO Details VALUES (?,?,?,?,?,?,?,?,?,?)', -1, @wr, nil) <> SQLITE_OK then Exit;
    sqlite3_bind_text(wr, 1, PAnsiChar(title), Length(title), sqlite3_destructor_type(SQLITE_TRANSIENT));
    text := HtmlToText(ESwordText(info));
    if text = '' then text := title;
    sqlite3_bind_text(wr, 2, PAnsiChar(text), Length(text), sqlite3_destructor_type(SQLITE_TRANSIENT));
    sqlite3_bind_text(wr, 3, PAnsiChar(abbr), Length(abbr), sqlite3_destructor_type(SQLITE_TRANSIENT));
    sqlite3_bind_text(wr, 4, PAnsiChar(text), Length(text), sqlite3_destructor_type(SQLITE_TRANSIENT));
    sqlite3_bind_text(wr, 5, PAnsiChar(version), Length(version), sqlite3_destructor_type(SQLITE_TRANSIENT));
    if rtl then sqlite3_bind_text(wr, 6, 'he', 2, sqlite3_destructor_type(SQLITE_TRANSIENT)) else sqlite3_bind_text(wr, 6, '', 0, sqlite3_destructor_type(SQLITE_TRANSIENT));
    sqlite3_bind_int(wr, 7, Ord(rtl));
    sqlite3_bind_int(wr, 8, Ord(ot));
    sqlite3_bind_int(wr, 9, Ord(nt));
    sqlite3_bind_int(wr, 10, Ord(strong));
    sqlite3_step(wr);
    sqlite3_finalize(wr); wr := nil;

    Exec(dst, 'COMMIT');
    sqlite3_close(dst); dst := nil;
    if RenameFile(tmp, Target) then Result := irOk;
  finally
    if wr <> nil then sqlite3_finalize(wr);
    if rd <> nil then sqlite3_finalize(rd);
    if src <> nil then sqlite3_close(src);
    if dst <> nil then sqlite3_close(dst);
    if Result <> irOk then DeleteFile(tmp);
  end;
end;

end.

