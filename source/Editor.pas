unit Editor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, ComCtrls;

type
  TfrmEditor = class(TForm)
    gpbHeader: TGroupBox;
    lbeTargetWindowName: TLabeledEdit;
    spbChooseTargetWindow: TSpeedButton;
    lbeOpenKey: TLabeledEdit;
    lbeSendKey: TLabeledEdit;
    lbeAltOpenKey: TLabeledEdit;
    lbeAltSendKey: TLabeledEdit;
    tmrCatchWindow: TTimer;
    ltvCommands: TListView;
    gpbCommand: TGroupBox;
    ckbDelay: TCheckBox;
    lbeText: TLabeledEdit;
    lbeHotKey: TLabeledEdit;
    lbeAltHotKey: TLabeledEdit;
    btnCommit: TButton;
    btnRollback: TButton;
    btnInsert: TButton;
    btnAppend: TButton;
    btnDelete: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure lbeHotKeyChange(Sender: TObject);
    procedure spbChooseTargetWindowClick(Sender: TObject);
    procedure tmrCatchWindowTimer(Sender: TObject);
    procedure ltvCommandsEdited(Sender: TObject; Item: TListItem;
      var S: String);
    procedure ltvCommandsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure btnCommitClick(Sender: TObject);
    procedure btnRollbackClick(Sender: TObject);
    procedure btnInsertClick(Sender: TObject);
    procedure btnAppendClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
  public
    procedure AddCommand(const Index: Shortint);
    procedure Clear;
    procedure ClearEditPanel;
    procedure LoadFromList;
    procedure SaveToFile(const FileName: TFileName);
  end;

var
  frmEditor: TfrmEditor;

implementation

uses Menus, CmdList;

const
  sAddEmptyString = 'Добавление пустой команды не имеет смысла.';
  sFileNotFound = 'Файл списка команд command.lst не найден.';

{$R *.dfm}

procedure TfrmEditor.lbeHotKeyChange(Sender: TObject);
begin
  if TextToShortCut((Sender as TLabeledEdit).Text) > 0
  then (Sender as TLabeledEdit).Font.Color := clBlack
  else (Sender as TLabeledEdit).Font.Color := clRed;
end;

procedure TfrmEditor.spbChooseTargetWindowClick(Sender: TObject);
begin
  tmrCatchWindow.Enabled := True;
end;

procedure TfrmEditor.tmrCatchWindowTimer(Sender: TObject);
var
  ActiveWindowHandle: THandle;
  WindowName: PChar;
  WindowNameLength: Integer;
begin
  ActiveWindowHandle := GetForegroundWindow;
  if ActiveWindowHandle <> Handle then begin
    WindowNameLength := GetWindowTextLength(ActiveWindowHandle);
    if WindowNameLength > 0 then begin
      GetMem(WindowName, WindowNameLength + 1);
      try
        if GetWindowText(ActiveWindowHandle, WindowName, WindowNameLength + 1) > 0
        then lbeTargetWindowName.Text := StrPas(WindowName)
        else lbeTargetWindowName.Text := SysErrorMessage(GetLastError);
      finally
        FreeMem(WindowName);
      end;
    end;
    tmrCatchWindow.Enabled := False;
    SetForegroundWindow(Handle);
  end;
end;

procedure TfrmEditor.ltvCommandsEdited(Sender: TObject; Item: TListItem;
  var S: String);
begin
  if S = EmptyStr then begin
    Item.Checked := False;
    Item.SubItems[0] := EmptyStr;
    Item.SubItems[1] := EmptyStr;
  end;
end;

procedure TfrmEditor.ltvCommandsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  ckbDelay.Checked := Item.Checked;
  lbeText.Text := Item.Caption;
  lbeHotKey.Text := Item.SubItems[0];
  lbeAltHotKey.Text := Item.SubItems[1];
end;

procedure TfrmEditor.btnCommitClick(Sender: TObject);
begin
  if lbeText.Text > EmptyStr then begin
    ltvCommands.Selected.Checked := ckbDelay.Checked;
    ltvCommands.Selected.Caption := lbeText.Text;
    if TextToShortCut(lbeHotKey.Text) = 0 then ltvCommands.Selected.SubItems[0] := lbeHotKey.Text
    else ltvCommands.Selected.SubItems[0] := ShortCutToText(TextToShortCut(lbeHotKey.Text));
    if TextToShortCut(lbeAltHotKey.Text) = 0 then ltvCommands.Selected.SubItems[1] := lbeAltHotKey.Text
    else ltvCommands.Selected.SubItems[1] := ShortCutToText(TextToShortCut(lbeAltHotKey.Text));
  end else lbeText.SetFocus;
end;

procedure TfrmEditor.btnRollbackClick(Sender: TObject);
begin
  ltvCommandsSelectItem(Self, ltvCommands.Selected, True);
end;

procedure TfrmEditor.btnInsertClick(Sender: TObject);
begin
  AddCommand(ltvCommands.ItemIndex);
end;

procedure TfrmEditor.btnAppendClick(Sender: TObject);
begin
  AddCommand(ltvCommands.Items.Count);
end;

procedure TfrmEditor.btnDeleteClick(Sender: TObject);
begin
  ltvCommands.DeleteSelected;
end;

{ Public procedures }

procedure TfrmEditor.AddCommand(const Index: Shortint);
begin
  with ltvCommands.Items.Insert(Index) do begin
    SubItems.Append(EmptyStr);
    SubItems.Append(EmptyStr);
    MakeVisible(False);
    Selected := True;
  end;
end;

procedure TfrmEditor.Clear;
var
  I: Shortint;
begin
  for I := 0 to gpbHeader.ControlCount - 1 do
    if gpbHeader.Controls[I] is TLabeledEdit then (gpbHeader.Controls[I] as TLabeledEdit).Clear;
  ltvCommands.Clear;
  ClearEditPanel;
end;

procedure TfrmEditor.ClearEditPanel;
begin
  ckbDelay.Checked := False;
  lbeText.Clear;
  lbeHotKey.Clear;
  lbeAltHotKey.Clear;
end;

procedure TfrmEditor.LoadFromList;
var
  I: Shortint;
begin
  if Assigned(Commands) then begin
    lbeTargetWindowName.Text := Commands.TargetWindowName;
    lbeOpenKey.Text := Commands.OpenKey;
    lbeSendKey.Text := Commands.SendKey;
    lbeAltOpenKey.Text := Commands.AltOpenKey;
    lbeAltSendKey.Text := Commands.AltSendKey;
    for I := 0 to Commands.Count - 1 do with ltvCommands.Items.Add do begin
      Caption := Commands[I].Text;
      Checked := Commands[I].IsDelay;
      if Assigned(Commands[I].HotKey) then SubItems.Append(Commands[I].HotKey.Text)
      else SubItems.Append(EmptyStr);
      if Assigned(Commands[I].AltHotKey) then SubItems.Append(Commands[I].AltHotKey.Text)
      else SubItems.Append(EmptyStr);
    end;
  end;
end;

procedure TfrmEditor.SaveToFile(const FileName: TFileName);
const
  TAB: Char = #9;
var
  Buffer: TStringList;
  I: Shortint;
  Serialize: string;
begin
  Buffer := TStringList.Create;
  try
    if (lbeTargetWindowName.Text > EmptyStr)
      or (lbeOpenKey.Text > EmptyStr) or (lbeAltOpenKey.Text > EmptyStr)
      or (lbeSendKey.Text > EmptyStr) or (lbeAltSendKey.Text > EmptyStr)
    then Buffer.Append(sCommandListSignature + TAB + lbeTargetWindowName.Text
      + TAB + lbeOpenKey.Text + TAB + lbeSendKey.Text + TAB + lbeAltOpenKey.Text
      + TAB + lbeAltSendKey.Text);
    for I := 0 to ltvCommands.Items.Count - 1 do with ltvCommands.Items[I] do
      if Caption = EmptyStr then Buffer.Append(Caption) else begin
        if Checked then Serialize := '%' + Caption else Serialize := Caption;
        if (SubItems[0] > EmptyStr) or (SubItems[1] > EmptyStr) then Serialize := Serialize + TAB + SubItems[0];
        if SubItems[1] > EmptyStr then Serialize := Serialize + TAB + SubItems[1];
        Buffer.Append(Serialize);
      end;
    Buffer.SaveToFile(FileName);
  finally
    Buffer.Free;
  end;
end;

end.

