unit Settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin;

type
  TfrmSettings = class(TForm)
    lblMinWidth: TLabel;
    lblAlpha: TLabel;
    lblDelay: TLabel;
    lblWindowPosition: TLabel;
    lblHotKeyPosition: TLabel;
    lblCommandFontSize: TLabel;
    lblHotKeyFontSize: TLabel;
    speMinWidth: TSpinEdit;
    speAlpha: TSpinEdit;
    speDelay: TSpinEdit;
    cbbWindowPosition: TComboBox;
    cbbHotKeyPosition: TComboBox;
    speCommandFontSize: TSpinEdit;
    speHotKeyFontSize: TSpinEdit;
    bvlSeparator: TBevel;
    lblList: TLabel;
    lblSelected: TLabel;
    lblText: TLabel;
    lblMainHotKey: TLabel;
    lblAltHotKey: TLabel;
    lblSeparator: TLabel;
    crbList: TColorBox;
    crbSelected: TColorBox;
    crbText: TColorBox;
    crbMainHotKey: TColorBox;
    crbAltHotKey: TColorBox;
    crbSeparator: TColorBox;
    OKButton: TButton;
    CancelButton: TButton;
    procedure FormShow(Sender: TObject);
    procedure ColorBoxSelect(Sender: TObject);
  end;

var
  frmSettings: TfrmSettings;

implementation

uses Main;

{$R *.dfm}

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  speMinWidth.Value := WidthMin;
  speAlpha.Value := MainForm.AlphaBlendValue;
  speDelay.Value := MainForm.tmrMouseLeave.Interval;
  cbbWindowPosition.ItemIndex := cbbWindowPosition.Items.IndexOf(WindowPosition);
  cbbHotKeyPosition.ItemIndex := cbbHotKeyPosition.Items.IndexOf(HotKeyPosition);
  speCommandFontSize.Value := CommandFontSize;
  speHotKeyFontSize.Value := HotKeyFontSize;
  crbList.Selected := clList;
  crbSelected.Selected := clSelected;
  crbText.Selected := clText;
  crbMainHotKey.Selected := clHotKey;
  crbAltHotKey.Selected := clAltHotKey;
  crbSeparator.Selected := clSeparator;
end;

procedure TfrmSettings.ColorBoxSelect(Sender: TObject);
begin
  if Sender is TColorBox then with (Sender as TColorBox) do
    if Selected = clRed then Selected := DefaultColorColor;
end;

end.

