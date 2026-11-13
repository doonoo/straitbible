{$mode delphi}{$H+}
unit UnitChromeIcons;

// The toolbar and menu icons are dark drawings. On a dark theme the dark parts (outlines and
// dark gray fills) are lightened so they stay visible; colored parts are left alone.

interface

uses
  Classes, SysUtils, Math, Graphics, Controls, GraphType, IntfGraphics, FPImage;

// Fills List with a copy of the original icons, lightened when dark = True.
// Original keeps the untouched icons (created on the first call).
procedure TintImages(List: TImageList; var Original: TImageList; dark: boolean; tint: TColor);

implementation

procedure TintImages(List: TImageList; var Original: TImageList; dark: boolean; tint: TColor);
var
  i, x, y, r, g, b, lum, sat, tr, tg, tb, k : integer;
  bmp : TBitmap;
  img : TLazIntfImage;
  c : TFPColor;
  rgb : longint;
begin
  if Original = nil then
    begin
      Original := TImageList.Create(nil);
      Original.Assign(List);
    end;

  List.Assign(Original);
  if not dark then Exit;

  rgb := ColorToRGB(tint);
  tr := rgb and $FF;
  tg := (rgb shr 8) and $FF;
  tb := (rgb shr 16) and $FF;

  List.Clear;
  for i := 0 to Original.Count - 1 do
    begin
      bmp := TBitmap.Create;
      try
        Original.GetBitmap(i, bmp);
        img := bmp.CreateIntfImage;
        try
          for y := 0 to img.Height - 1 do
            for x := 0 to img.Width - 1 do
              begin
                c := img.Colors[x, y];
                if c.alpha < $1000 then Continue;      // (almost) transparent

                r := c.red shr 8;
                g := c.green shr 8;
                b := c.blue shr 8;
                lum := (r + g + b) div 3;
                sat := Max(r, Max(g, b)) - Min(r, Min(g, b));

                if (sat < 50) and (lum < 150) then      // dark gray: move towards the text color
                  begin
                    k := 100 - lum * 100 div 150;       // 100 for black, 0 for the limit
                    c.red   := (r + (tr - r) * k div 100) * 257;
                    c.green := (g + (tg - g) * k div 100) * 257;
                    c.blue  := (b + (tb - b) * k div 100) * 257;
                    img.Colors[x, y] := c;
                  end;
              end;
          bmp.LoadFromIntfImage(img);
        finally
          img.Free;
        end;
        List.Add(bmp, nil);
      finally
        bmp.Free;
      end;
    end;
end;

end.
