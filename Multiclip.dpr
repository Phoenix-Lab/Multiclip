program Multiclip;

uses
  Forms,
  Windows,
  Main in 'source\Main.pas' {MainForm},
  About in 'source\About.pas' {AboutBox},
  CmdList in 'source\CmdList.pas',
  Editor in 'source\Editor.pas' {frmEditor},
  Settings in 'source\Settings.pas' {frmSettings};

const
  sMutexName = 'Multiclip_Control_Mutex';
  sProgramAlreadyRun = 'Программа Multiclip уже запущена';

var
  hMutex: THandle;

{$R *.res}

begin
  Application.Title := 'Multiclip';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TfrmEditor, frmEditor);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.CreateForm(TAboutBox, AboutBox);
  hMutex := OpenMutex(READ_CONTROL, True, sMutexName);
  if hMutex = 0 then begin
    hMutex := CreateMutex(nil, True, sMutexName);
    ShowWindow(Application.Handle, SW_HIDE);
    Application.Run;
    ReleaseMutex(hMutex);
  end else Application.MessageBox(sProgramAlreadyRun, PChar(Application.Title), MB_OK or MB_ICONSTOP);
  CloseHandle(hMutex);
end.

