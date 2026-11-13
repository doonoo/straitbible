unit FormAbout;

interface

uses Classes, Graphics, Forms, Controls, StdCtrls, Buttons, ExtCtrls, SysUtils, LCLIntf;

type

  { TAboutBox }

  TAboutBox = class(TForm)
    LabelGPL: TLabel;
    LabelName: TLabel;
    LabelBased: TLabel;
    LabelProject: TLabel;
    LabelVersion: TLabel;
    Image: TImage;
    procedure FormCreate(Sender: TObject);
    procedure LabelBasedClick(Sender: TObject);
    procedure LabelProjectClick(Sender: TObject);
  public
    procedure Localize;
  end;

var
  AboutBox: TAboutBox;

implementation

uses UnitUtils, UnitLocal;

{$R *.lfm}

procedure TAboutBox.FormCreate(Sender: TObject);
begin
  LabelName.Caption := ApplicationName;
end;

procedure TAboutBox.Localize;
begin
  Caption := ' ' + T('About');
  LabelVersion.Caption := T('Version') + ' ' + ApplicationVersion;
  LabelBased.Caption := T('Based on Unbound Bible by Vladimir Rybant');
end;

// the program this one is based on
procedure TAboutBox.LabelBasedClick(Sender: TObject);
begin
  OpenURL(OriginalURL);
end;

procedure TAboutBox.LabelProjectClick(Sender: TObject);
begin
  OpenURL(ProjectURL);
end;

end.
