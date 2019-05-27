unit About;

interface

uses
  Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, ExtCtrls;

type
  TAboutBox = class(TForm)
    Panel: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    License: TImage;
    OKButton: TButton;
    procedure ImageClick(Sender: TObject);
  end;

var
  AboutBox: TAboutBox;

implementation

uses
  ShellAPI;

{$R *.dfm}

procedure TAboutBox.ImageClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PChar((Sender as TControl).Hint), nil, nil, SW_SHOWNORMAL);
end;

end.

