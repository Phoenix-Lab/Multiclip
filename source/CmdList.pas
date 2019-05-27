unit CmdList;

interface

uses
  SysUtils, Classes, Contnrs;

type
  THotKey = class
  private
    FAtom: Word;
    FModifiers: Cardinal;
    FIsRegister: Boolean;
    FText: string;
    FVirtualCode: Byte;
    procedure SetRegister(const Value: Boolean);
  public
    constructor Create(const AText: string);
    destructor Destroy; override;
    property Atom: Word read FAtom;
    property IsRegister: Boolean read FIsRegister write SetRegister;
    property Text: string read FText;
  end;

  TCommand = class
    HotKey: THotKey;
    AltHotKey: THotKey;
  private
    FIsDelay: Boolean;
    FText: string;
  public
    constructor Create(AText: string);
    destructor Destroy; override;
    property IsDelay: Boolean read FIsDelay;
    property Text: string read FText;
  end;

  TCommandList = class
  private
    FAltOpenKey: string;
    FAltSendKey: string;
    FList: TObjectList;
    FOpenKey: string;
    FSendKey: string;
    FTargetWindowName: string;
    function GetCount: Byte;
    function GetItem(Index: Byte): TCommand;
  public
    constructor Create(const FileName: string);
    destructor Destroy; override;
    procedure LoadFromFile(const FileName: string);
    procedure RegisterHotKeys;
    procedure SaveToFile(const FileName: string);
    procedure UnregisterHotKeys;
    property AltOpenKey: string read FAltOpenKey;
    property AltSendKey: string read FAltSendKey;
    property Count: Byte read GetCount;
    property List[Index: Byte]: TCommand read GetItem; default;
    property OpenKey: string read FOpenKey;
    property SendKey: string read FSendKey;
    property TargetWindowName: string read FTargetWindowName;
  end;

const
  sCommandListSignature = 'MCLST';

var
  Commands: TCommandList;

implementation

uses
  Windows, StrUtils, Menus, Main;

const
  sAtomPrefix = 'Multiclip_';
  sDefaultHotKey = 'Enter';

{ TCommandList }

constructor TCommandList.Create(const FileName: string);
begin
  FList := TObjectList.Create;
  if FileExists(FileName) then
    LoadFromFile(FileName);
  RegisterHotKeys;
end;

destructor TCommandList.Destroy;
begin
  UnregisterHotKeys;
  FList.Free;
end;

function TCommandList.GetCount: Byte;
begin
  Result := FList.Count;
end;

function TCommandList.GetItem(Index: Byte): TCommand;
begin
  if Index < Count then
    Result := FList[Index] as TCommand
  else Result := nil;
end;

procedure TCommandList.LoadFromFile(const FileName: string);
const
  TAB: Char = #9;
var
  Buffer, Lexer: TStringList;
  I: Shortint;
begin
  Buffer := TStringList.Create;
  Lexer := TStringList.Create;
  Lexer.Delimiter := TAB;
  try
    Buffer.LoadFromFile(FileName);
    if Buffer.Count = 0 then
      raise EReadError.CreateFmt('Файл "%s" пуст', [FileName]);
    Lexer.DelimitedText := '"' + StringReplace(Buffer[0], TAB, '"' + TAB + '"',
      [rfReplaceAll]) + '"';
    if (Lexer.Count > 0) and SameText(Lexer[0], sCommandListSignature) then
    begin
      FTargetWindowName := Lexer[1];
      FOpenKey := Lexer[2];
      FSendKey := Lexer[3];
      FAltOpenKey := Lexer[4];
      FAltSendKey := Lexer[5];
      Buffer.Delete(0);
    end;
    if SameText(FSendKey, EmptyStr) then
      FSendKey := sDefaultHotKey;
    if SameText(FAltSendKey, EmptyStr) then
      FAltSendKey := sDefaultHotKey;
    FList.Clear;
    for I := 0 to Buffer.Count - 1 do
      FList.Add(TCommand.Create(Buffer[I]));
  finally
    Lexer.Free;
    Buffer.Free;
  end;
end;

procedure TCommandList.RegisterHotKeys;
var
  I: Shortint;
begin
  for I := 0 to Count - 1 do
    with FList[I] as TCommand do
    begin
      if Assigned(HotKey) then
        HotKey.IsRegister := True;
      if Assigned(AltHotKey) then
        AltHotKey.IsRegister := True;
    end;
end;

procedure TCommandList.SaveToFile(const FileName: string);
const
  TAB: Char = #9;
var
  Buffer: TStringList;
  I: Shortint;
  Serialize: string;
begin
  Buffer := TStringList.Create;
  try
    if not SameText(TargetWindowName + OpenKey + SendKey + AltOpenKey
      + AltSendKey, EmptyStr)
    then
      Buffer.Append(sCommandListSignature + TAB + TargetWindowName + TAB
        + OpenKey + TAB + SendKey + TAB + AltOpenKey + TAB + AltSendKey);
    for I := 0 to Count - 1 do
      if SameText(List[I].Text, EmptyStr) then
        Buffer.Append(EmptyStr)
      else
      begin
        if List[I].IsDelay then
          Serialize := '%' + List[I].Text
        else Serialize := List[I].Text;
        if Assigned(List[I].AltHotKey) then
        begin
          Serialize := Serialize + TAB;
          if Assigned(List[I].HotKey) then
            Serialize := Serialize + List[I].HotKey.Text;
          Serialize := Serialize + TAB + List[I].AltHotKey.Text;
        end
        else
          if Assigned(List[I].HotKey) then
            Serialize := Serialize + TAB + List[I].HotKey.Text;
        Buffer.Append(Serialize);
      end;
    Buffer.SaveToFile(FileName);
  finally
    Buffer.Free;
  end;
end;

procedure TCommandList.UnregisterHotKeys;
var
  I: Shortint;
begin
  for I := 0 to Count - 1 do
    with FList[I] as TCommand do
    begin
      if Assigned(HotKey) then
        HotKey.IsRegister := False;
      if Assigned(AltHotKey) then
        AltHotKey.IsRegister := False;
    end;
end;

{ THotKey }

constructor THotKey.Create(const AText: string);
var
  Shortcut: TShortCut;
begin
  FIsRegister := False;
  FText := AText;
  Shortcut := TextToShortCut(AText);
  if Shortcut = 0 then
    FAtom := 0
  else
  begin
    FAtom := GlobalFindAtom(PChar(sAtomPrefix + AText));
    if FAtom = 0 then
      FAtom := GlobalAddAtom(PChar(sAtomPrefix + AText));
    if Shortcut and scShift > 0 then
      FModifiers := FModifiers or MOD_SHIFT;
    if Shortcut and scCtrl > 0 then
      FModifiers := FModifiers or MOD_CONTROL;
    if Shortcut and scAlt > 0 then
      FModifiers := FModifiers or MOD_ALT;
    FVirtualCode := Byte(Shortcut);
  end;
end;

destructor THotKey.Destroy;
begin
  IsRegister := False;
  if FAtom > 0 then
    GlobalDeleteAtom(FAtom);
  inherited;
end;

procedure THotKey.SetRegister(const Value: Boolean);
begin
  if FAtom = 0 then
    FIsRegister := False
  else
    if not FIsRegister and Value then
      FIsRegister := RegisterHotKey(MainForm.Handle, FAtom, FModifiers,
        FVirtualCode)
    else
      if FIsRegister and not Value then
        FIsRegister := not UnregisterHotKey(MainForm.Handle, FAtom)
      else FIsRegister := Value;
end;

{ TCommand }

constructor TCommand.Create(AText: string);
const
  TAB: Char = #9;
var
  TabPosition: Byte;
begin
  TabPosition := Pos(TAB, AText);
  if TabPosition = 0 then
    FText := AText
  else
  begin
    FText := LeftStr(AText, TabPosition - 1);
    Delete(AText, 1, TabPosition);
    TabPosition := Pos(TAB, AText);
    if TabPosition = 0 then
      HotKey := THotKey.Create(AText)
    else
    begin
      HotKey := THotKey.Create(LeftStr(AText, TabPosition - 1));
      AltHotKey := THotKey.Create(RightStr(AText, Length(AText) - TabPosition));
    end;
  end;
  FIsDelay := not SameText(FText, EmptyStr) and SameText(FText[1], '%');
  if FIsDelay then Delete(FText, 1, 1);
end;

destructor TCommand.Destroy;
begin
  HotKey.Free;
  AltHotKey.Free;
  inherited;
end;

end.

