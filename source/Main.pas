unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, AppEvnts, Menus, ImgList;

type
  TMainForm = class(TForm)
    mmnMenuBar: TMainMenu;
    mniFile: TMenuItem;
    mniFileNew: TMenuItem;
    mniFileOpen: TMenuItem;
    mniFileSaveAs: TMenuItem;
    mniFileExit: TMenuItem;
    mniTools: TMenuItem;
    mniToolsMinimize: TMenuItem;
    mniToolsEditor: TMenuItem;
    mniToolsSettings: TMenuItem;
    mniHelp: TMenuItem;
    mniHelpAbout: TMenuItem;
    lsbCommands: TListBox;
    apeEvents: TApplicationEvents;
    tmrMouseLeave: TTimer;
    tmrPrepareCommand: TTimer;
    ondCommandList: TOpenDialog;
    svdCommandList: TSaveDialog;
    imlIcons: TImageList;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lsbCommandsDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure lsbCommandsMeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure lsbCommandsMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure lsbCommandsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure apeEventsMinimize(Sender: TObject);
    procedure apeEventsRestore(Sender: TObject);
    procedure tmrMouseLeaveTimer(Sender: TObject);
    procedure tmrPrepareCommandTimer(Sender: TObject);
    procedure mniFileNewClick(Sender: TObject);
    procedure mniFileOpenClick(Sender: TObject);
    procedure mniFileSaveAsClick(Sender: TObject);
    procedure mniFileExitClick(Sender: TObject);
    procedure mniToolsMinimizeClick(Sender: TObject);
    procedure mniToolsEditorClick(Sender: TObject);
    procedure mniToolsSettingsClick(Sender: TObject);
    procedure mniHelpAboutClick(Sender: TObject);
  public
    procedure LoadCommands;
    procedure LoadFromIni;
    procedure OnEnterSizeMove(var Msg: TWMNoParams); message WM_ENTERSIZEMOVE;
    procedure OnExitSizeMove(var Msg: TWMNoParams); message WM_EXITSIZEMOVE;
    procedure OnHotKey(var Msg: TWMHotKey); message WM_HOTKEY;
    procedure OnMove(var Msg: TWMMove); message WM_MOVE;
    procedure OnMoving(var Msg: TWMMoving); message WM_MOVING;
    procedure SaveToIni;
    procedure SendCommand(const Target: THandle; const Index: Byte;
      const IsAltSend: Boolean);
    procedure SwitchWindowState(const IsShow: Boolean = False);
  end;

var
  MainForm: TMainForm;
  WidthMin, WidthMax: Word;
  CommandFontSize, HotKeyFontSize: Byte;
  clList, clSelected, clText, clSeparator, clHotKey, clAltHotKey: TColor;
  HotKeyPosition, WindowPosition: string;

implementation

uses
  Clipbrd, IniFiles, Math, ShellAPI, About, CmdList, Editor, Settings;

const
  sCommandFileName: TFileName = 'command.lst';

  sIniSettings = 'Settings';
  sIniSettingsLeft = 'Left';
  sIniSettingsTop = 'Top';
  sIniSettingsMinWidth = 'Width_Min';
  sIniSettingsMaxWidth = 'Width_Max';
  sIniSettingsAlphaBlendValue = 'AlphaBlendValue';
  sIniSettingsDelayBeforeMinimize = 'DelayBeforeMinimize';
  sIniSettingsCommandFontSize = 'Font_Size';
  sIniSettingsHotKeyFontSize = 'HK_Font_Size';
  sIniSettingsWindowPosition = 'Window_Position';
  sIniSettingsHotKeyPosition = 'HotKey_Position';
  sIniSettingsCommandFileName = 'Command_List';

  sIniColors = 'Colors';
  sIniColorsList = 'List';
  sIniColorsSelected = 'Selected';
  sIniColorsText = 'Text';
  sIniColorsHotKey = 'HK_Team';
  sIniColorsAltHotKey = 'HK_Global';
  sIniColorsSeparator = 'Separator';

var
  IsAltSend, IsChangeForm: Boolean;
  CommandListName: TFileName;

{$R *.dfm}

procedure TMainForm.FormCanResize(Sender: TObject;
  var NewWidth, NewHeight: Integer; var Resize: Boolean);
begin
  if not IsChangeForm then begin
    if AlphaBlend then NewWidth := Width else begin
      WidthMax := NewWidth;
      if WindowPosition = 'Left' then Left := 0 else
        if WindowPosition = 'Right' then Left := Screen.WorkAreaWidth - WidthMax;
    end;
    NewHeight := Height;
  end;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Commands.Free;
  SaveToIni;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  ondCommandList.InitialDir := GetCurrentDir;
  svdCommandList.InitialDir := GetCurrentDir;
  LoadFromIni;
  Commands := TCommandList.Create(CommandListName);
  LoadCommands;
  SwitchWindowState(True);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  lsbCommands.Refresh;
end;

procedure TMainForm.lsbCommandsDrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
const
  Gap = 2;
begin
  with lsbCommands.Canvas do if lsbCommands.Items[Index] = EmptyStr then begin
    State := [odDisabled];
    Brush.Color := clSeparator;
    FillRect(Rect);
  end else begin
    if Index = lsbCommands.ItemIndex then begin
      State := [odSelected];
      Brush.Color := clSelected;
    end else begin
      State := [odDefault];
      Brush.Color := clList;
    end;
    FillRect(Rect);
    Font.Height := CommandFontSize;
    Font.Color := clText;
    TextOut(Rect.Left + Gap, Rect.Top, lsbCommands.Items[Index]);
    Font.Height := HotKeyFontSize;
    if Assigned(Commands[Index].HotKey) then begin
      if Commands[Index].HotKey.IsRegister then Font.Color := clHotKey else Font.Color := clRed;
      if HotKeyPosition = 'Down' then TextOut(Rect.Left + Gap, Rect.Bottom - Font.Height, Commands[Index].HotKey.Text)
      else TextOut(Rect.Right - TextWidth(Commands[Index].HotKey.Text) - Gap, Rect.Top, Commands[Index].HotKey.Text);
    end;
    if Assigned(Commands[Index].AltHotKey) then begin
      if Commands[Index].AltHotKey.IsRegister then Font.Color := clAltHotKey else Font.Color := clRed;
      TextOut(Rect.Right - TextWidth(Commands[Index].AltHotKey.Text) - Gap, Rect.Bottom - Font.Height, Commands[Index].AltHotKey.Text);
    end;
  end;
end;

procedure TMainForm.lsbCommandsMeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  if lsbCommands.Items[Index] = EmptyStr then Height := 2 else
    if HotKeyPosition = 'Down' then Height := CommandFontSize + HotKeyFontSize else
      if HotKeyPosition = 'Right' then Height := Max(CommandFontSize, HotKeyFontSize * 2)
      else Height := CommandFontSize;
end;

procedure TMainForm.lsbCommandsMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if AlphaBlend then SwitchWindowState;
  lsbCommands.ItemIndex := lsbCommands.ItemAtPos(Point(X, Y), True);
  if (lsbCommands.Tag >= 0) and (lsbCommands.Tag <> lsbCommands.ItemIndex) then
    lsbCommandsDrawItem(lsbCommands, lsbCommands.Tag, lsbCommands.ItemRect(lsbCommands.Tag), [odDefault]);
  lsbCommands.Tag := lsbCommands.ItemIndex;
end;

procedure TMainForm.lsbCommandsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button <> mbMiddle) and (lsbCommands.Items[lsbCommands.ItemIndex] > EmptyStr) then begin
    IsAltSend := Button = mbRight;
    Tag := lsbCommands.ItemIndex;
    tmrPrepareCommand.Enabled := True;
    if not AlphaBlend then SwitchWindowState;
  end;
end;

procedure TMainForm.apeEventsMinimize(Sender: TObject);
begin
  Commands.UnregisterHotKeys;
  ShowWindow(Application.Handle, SW_SHOW);
end;

procedure TMainForm.apeEventsRestore(Sender: TObject);
begin
  Commands.RegisterHotKeys;
  ShowWindow(Application.Handle, SW_HIDE);
end;

procedure TMainForm.tmrMouseLeaveTimer(Sender: TObject);
begin
  if AlphaBlend = PtInRect(BoundsRect, Mouse.CursorPos) then SwitchWindowState;
end;

procedure TMainForm.tmrPrepareCommandTimer(Sender: TObject);
var
  ActiveWindow: THandle;
begin
  if Commands.TargetWindowName > EmptyStr then
    ActiveWindow := FindWindow(nil, PChar(Commands.TargetWindowName))
  else ActiveWindow := GetForegroundWindow;
  if ActiveWindow = Handle then ActiveWindow := 0;
  if (ActiveWindow > 0) and (GetKeyState(VK_SHIFT) + GetKeyState(VK_CONTROL) + GetKeyState(VK_MENU) >= 0)
  then begin
    SendCommand(ActiveWindow, Tag, IsAltSend);
    tmrPrepareCommand.Enabled := False;
  end;
end;

procedure TMainForm.mniFileNewClick(Sender: TObject);
begin
  if (frmEditor.ShowModal = mrOk) and svdCommandList.Execute then begin
    CommandListName := svdCommandList.FileName;
    frmEditor.SaveToFile(CommandListName);
    Commands.Free;
    Commands := TCommandList.Create(CommandListName);
    LoadCommands;
  end;
  frmEditor.Clear;
end;

procedure TMainForm.mniFileOpenClick(Sender: TObject);
begin
  if ondCommandList.Execute then begin
    CommandListName := ondCommandList.FileName;
    Commands.Free;
    Commands := TCommandList.Create(CommandListName);
    LoadCommands;
  end;
end;

procedure TMainForm.mniFileSaveAsClick(Sender: TObject);
begin
  if svdCommandList.Execute then Commands.SaveToFile(svdCommandList.FileName);
end;

procedure TMainForm.mniFileExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.mniToolsMinimizeClick(Sender: TObject);
begin
  Application.Minimize;
end;

procedure TMainForm.mniToolsEditorClick(Sender: TObject);
begin
  frmEditor.LoadFromList;
  if frmEditor.ShowModal = mrOk then begin
    frmEditor.SaveToFile(CommandListName);
    Commands.Free;
    Commands := TCommandList.Create(CommandListName);
    LoadCommands;
  end;
  frmEditor.Clear;
end;

procedure TMainForm.mniToolsSettingsClick(Sender: TObject);
begin
  if frmSettings.ShowModal = mrOk then begin
    WidthMin := frmSettings.speMinWidth.Value;
    AlphaBlendValue := frmSettings.speAlpha.Value;
    tmrMouseLeave.Interval := frmSettings.speDelay.Value;
    WindowPosition := frmSettings.cbbWindowPosition.Text;
    HotKeyPosition := frmSettings.cbbHotKeyPosition.Text;
    CommandFontSize := frmSettings.speCommandFontSize.Value;
    HotKeyFontSize := frmSettings.speHotKeyFontSize.Value;
    clList := frmSettings.crbList.Selected;
    clSelected := frmSettings.crbSelected.Selected;
    clText := frmSettings.crbText.Selected;
    clHotKey := frmSettings.crbMainHotKey.Selected;
    clAltHotKey := frmSettings.crbAltHotKey.Selected;
    clSeparator := frmSettings.crbSeparator.Selected;
    LoadCommands;
    SwitchWindowState(True);
  end;
end;

procedure TMainForm.mniHelpAboutClick(Sender: TObject);
begin
  AboutBox.ShowModal;
end;

{ Handlers of Windows messages }

procedure TMainForm.OnEnterSizeMove(var Msg: TWMNoParams);
begin
  tmrMouseLeave.Enabled := False;
end;

procedure TMainForm.OnExitSizeMove(var Msg: TWMNoParams);
begin
  tmrMouseLeave.Enabled := True;
end;

procedure TMainForm.OnHotKey(var Msg: TWMHotKey);
var
  I: Shortint;
begin
  for I := 0 to Commands.Count - 1 do if Commands[I].Text > EmptyStr then begin
    if Assigned(Commands[I].HotKey) and (Msg.HotKey = Commands[I].HotKey.Atom) then begin
      IsAltSend := False;
      Tag := I;
    end;
    if Assigned(Commands[I].AltHotKey) and (Msg.HotKey = Commands[I].AltHotKey.Atom) then begin
      IsAltSend := True;
      Tag := I;
    end;
    tmrPrepareCommand.Enabled := Tag >= 0;
    if Tag >= 0 then Break;
  end;
end;

procedure TMainForm.OnMove(var Msg: TWMMove);
begin
  if not IsChangeForm then begin
    IsChangeForm := True;
    if Left = 0 then WindowPosition := 'Left' else
      if Left + Width = Screen.WorkAreaWidth then WindowPosition := 'Right'
      else WindowPosition := 'Manual';
    IsChangeForm := False;
  end;
end;

procedure TMainForm.OnMoving(var Msg: TWMMoving);
var
  OffsetX, OffsetY: Integer;
begin
  if Msg.DragRect.Left < Screen.WorkAreaLeft then
    OffsetX := Screen.WorkAreaLeft - Msg.DragRect.Left
  else if Msg.DragRect.Right > Screen.WorkAreaRect.Right then
    OffsetX := Screen.WorkAreaRect.Right - Msg.DragRect.Right
  else OffsetX := 0;
  if Msg.DragRect.Top < Screen.WorkAreaTop then
    OffsetY := Screen.WorkAreaTop - Msg.DragRect.Top
  else if Msg.DragRect.Bottom > Screen.WorkAreaRect.Bottom then
    OffsetY := Screen.WorkAreaRect.Bottom - Msg.DragRect.Bottom
  else OffsetY := 0;
  OffsetRect(Msg.DragRect^, OffsetX, OffsetY);
end;

{ Public procedures }

procedure TMainForm.LoadCommands;
var
  I: Shortint;
begin
  lsbCommands.Items.BeginUpdate;
  try
    lsbCommands.Clear;
    for I := 0 to Commands.Count - 1 do lsbCommands.Items.Add(Commands[I].Text);
  finally
    lsbCommands.Items.EndUpdate;
  end;
  IsChangeForm := True;
  ClientHeight := lsbCommands.ItemRect(lsbCommands.Count - 1).Bottom;
  if Height > Screen.WorkAreaHeight then Height := Screen.WorkAreaHeight;
  IsChangeForm := False;
end;

procedure TMainForm.LoadFromIni;
begin
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do try
    Left := ReadInteger(sIniSettings, sIniSettingsLeft, Left);
    Top := ReadInteger(sIniSettings, sIniSettingsTop, Top);
    WidthMin := ReadInteger(sIniSettings, sIniSettingsMinWidth, 20);
    WidthMax := ReadInteger(sIniSettings, sIniSettingsMaxWidth, 300);
    if WidthMax < WidthMin then WidthMax := WidthMin;
    AlphaBlendValue := ReadInteger(sIniSettings, sIniSettingsAlphaBlendValue, 40);
    tmrMouseLeave.Interval := ReadInteger(sIniSettings, sIniSettingsDelayBeforeMinimize, 300);
    CommandFontSize := ReadInteger(sIniSettings, sIniSettingsCommandFontSize, 30);
    HotKeyFontSize := ReadInteger(sIniSettings, sIniSettingsHotKeyFontSize, 15);
    WindowPosition := ReadString(sIniSettings, sIniSettingsWindowPosition, 'Right');
    if (WindowPosition <> 'Left') and (WindowPosition <> 'Right') and (WindowPosition <> 'Manual') then WindowPosition := 'Right';
    HotKeyPosition := ReadString(sIniSettings, sIniSettingsHotKeyPosition, 'Down');
    if (HotkeyPosition <> 'Down') and (HotkeyPosition <> 'Right') then HotkeyPosition := 'Right';
    CommandListName := ReadString(sIniSettings, sIniSettingsCommandFileName, sCommandFileName);
    clList := StringToColor(ReadString(sIniColors, sIniColorsList, 'clWhite'));
    clSelected := StringToColor(ReadString(sIniColors, sIniColorsSelected, 'clLime'));
    clText := StringToColor(ReadString(sIniColors, sIniColorsText, 'clBlack'));
    clHotKey := StringToColor(ReadString(sIniColors, sIniColorsHotKey, 'clOlive'));
    clAltHotKey := StringToColor(ReadString(sIniColors, sIniColorsAltHotKey, 'clGreen'));
    clSeparator := StringToColor(ReadString(sIniColors, sIniColorsSeparator, 'clBlack'));
  finally
    Free;
  end;
end;

procedure TMainForm.SaveToIni;
begin
  with TIniFile.Create(ChangeFileExt(Application.ExeName, '.ini')) do try
    WriteInteger(sIniSettings, sIniSettingsLeft, Left);
    WriteInteger(sIniSettings, sIniSettingsTop, Top);
    WriteInteger(sIniSettings, sIniSettingsMinWidth, WidthMin);
    WriteInteger(sIniSettings, sIniSettingsMaxWidth, WidthMax);
    WriteInteger(sIniSettings, sIniSettingsAlphaBlendValue, AlphaBlendValue);
    WriteInteger(sIniSettings, sIniSettingsDelayBeforeMinimize, tmrMouseLeave.Interval);
    WriteInteger(sIniSettings, sIniSettingsCommandFontSize, CommandFontSize);
    WriteInteger(sIniSettings, sIniSettingsHotKeyFontSize, HotKeyFontSize);
    WriteString(sIniSettings, sIniSettingsWindowPosition, WindowPosition);
    WriteString(sIniSettings, sIniSettingsHotKeyPosition, HotKeyPosition);
    WriteString(sIniSettings, sIniSettingsCommandFileName, ExtractRelativePath(IncludeTrailingPathDelimiter(GetCurrentDir), CommandListName));
    WriteString(sIniColors, sIniColorsList, ColorToString(clList));
    WriteString(sIniColors, sIniColorsSelected, ColorToString(clSelected));
    WriteString(sIniColors, sIniColorsText, ColorToString(clText));
    WriteString(sIniColors, sIniColorsHotKey, ColorToString(clHotKey));
    WriteString(sIniColors, sIniColorsAltHotKey, ColorToString(clAltHotKey));
    WriteString(sIniColors, sIniColorsSeparator, ColorToString(clSeparator));
  finally
    Free;
  end;
end;

procedure TMainForm.SendCommand(const Target: THandle; const Index: Byte;
  const IsAltSend: Boolean);
const
  sPasteShortCut = 'Ctrl+V';
var
  OpenKey, SendKey: TShortCut;

  procedure ClickShortCut(const ShortCut: TShortCut);
  var
    Input: TInput;
    IsAlt, IsCtrl, IsShift: Boolean;
  begin;
    IsAlt := ShortCut and scAlt > 0;
    IsCtrl := ShortCut and scCtrl > 0;
    IsShift := ShortCut and scShift > 0;
    Input.Itype := INPUT_KEYBOARD;
    Input.ki.dwFlags := 0;
    if IsAlt then begin
      Input.ki.wVk := VK_MENU;
      SendInput(1, Input, SizeOf(Input));
    end;
    if IsCtrl then begin
      Input.ki.wVk := VK_CONTROL;
      SendInput(1, Input, SizeOf(Input));
    end;
    if IsShift then begin
      Input.ki.wVk := VK_SHIFT;
      SendInput(1, Input, SizeOf(Input));
    end;
    Input.ki.wVk := Byte(ShortCut);
    SendInput(1, Input, SizeOf(Input));
    Input.ki.dwFlags := KEYEVENTF_KEYUP;
    SendInput(1, Input, SizeOf(Input));
    if IsShift then begin
      Input.ki.wVk := VK_SHIFT;
      SendInput(1, Input, SizeOf(Input));
    end;
    if IsCtrl then begin
      Input.ki.wVk := VK_CONTROL;
      SendInput(1, Input, SizeOf(Input));
    end;
    if IsAlt then begin
      Input.ki.wVk := VK_MENU;
      SendInput(1, Input, SizeOf(Input));
    end;
  end;

  procedure SetClipboardText;
  var
    hClipboard: THandle;
  begin
    Clipboard.Open;
    try
      Clipboard.AsText := Commands[Index].Text;
      hClipboard := Clipboard.GetAsHandle(CF_TEXT);
      if hClipboard <> INVALID_HANDLE_VALUE then
        Clipboard.SetAsHandle(CF_LOCALE, hClipboard);
    finally
      Clipboard.Close;
    end;
  end;
begin
  SetClipboardText;
  SetForegroundWindow(Target);
  if IsAltSend then begin
    OpenKey := TextToShortCut(Commands.AltOpenKey);
    SendKey := TextToShortCut(Commands.AltSendKey);
  end else begin
    OpenKey := TextToShortCut(Commands.OpenKey);
    SendKey := TextToShortCut(Commands.SendKey);
  end;
  if OpenKey > 0 then ClickShortCut(OpenKey);
  ClickShortCut(TextToShortCut(sPasteShortCut));
  if not Commands[Tag].IsDelay and (SendKey > 0) then ClickShortCut(SendKey);
  Tag := -1;
end;

procedure TMainForm.SwitchWindowState(const IsShow: Boolean = False);
begin
  AlphaBlend := not IsShow and not AlphaBlend;
  IsChangeForm := True;
  if WindowPosition <> 'Manual' then begin
    if AlphaBlend then Width := WidthMin else Width := WidthMax;
    if WindowPosition = 'Left' then Left := 0 else
      if WindowPosition = 'Right' then Left := Screen.WorkAreaWidth - Width;
  end;
  ClientHeight := lsbCommands.ItemRect(lsbCommands.Count - 1).Bottom;
  IsChangeForm := False;
end;

end.

