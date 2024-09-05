program DisparadorWZP;

uses
  Vcl.Forms,
  Windows,
  uTWPPConnect.ConfigCEF,
  iniFiles,
  SysUtils,
  MidasLib,
  DisparadorWZP.Principal in '..\view\DisparadorWZP.Principal.pas' {FPrincipal},
  DataModule.Global in '..\datamodules\DataModule.Global.pas' {DmGlobal: TDataModule},
  Status.Mensagem in '..\utils\Status.Mensagem.pas',
  Variaveis.Server in '..\utils\Variaveis.Server.pas';

{$R *.res}

var
  lArquivoINI: TIniFile;
  lPathAPP: string;
  lPathCEF: string;
begin
  try
    lArquivoINI := Tinifile.Create(ExtractFilePath(Application.ExeName) + 'ConfTWPPConnect.ini');
  except on E: Exception do
  end;

  lPathAPP := ExtractFilePath(Application.ExeName);
  lPathCEF := 'cef4\';

  {config path custom}
  with GlobalCEFApp do
  begin
    SetPathCache(lPathAPP + lPathCEF + 'cache');
    SetPathUserDataPath(lPathAPP + lPathCEF+'User Data');
    SetPathLocalesDirPath(lPathAPP + lPathCEF+'locales') ;
    SetPathResourcesDirPath(lPathAPP);
    SetPathFrameworkDirPath(lPathAPP) ;
    SetLogConsole (lPathAPP + lPathCEF+ 'logs\Log Console');
    SetLogConsoleActive (true) ;
  end;

  {create file ini}
  try
    lArquivoINI.WriteString('Path Defines', 'Binary', lPathAPP + lPathCEF);
    lArquivoINI.WriteString('Path Defines', 'FrameWork', lPathAPP + lPathCEF);
    lArquivoINI.WriteString('Path Defines', 'Resources', lPathAPP + lPathCEF);
    lArquivoINI.WriteString('Path Defines', 'Locales', lPathAPP + lPathCEF + 'locales');
    lArquivoINI.WriteString('Path Defines', 'Cache', lPathAPP + lPathCEF + 'cache');
    lArquivoINI.WriteString('Path Defines', 'Data User', lPathAPP + lPathCEF + 'User Data');
    lArquivoINI.WriteString('Path Defines', 'Log File', lPathAPP + lPathCEF + 'logs\Log File');
    lArquivoINI.WriteString('Path Defines', 'Log Console', lPathAPP + lPathCEF + 'logs\Log Console');

    //Config Values Default Language
    if not(lArquivoINI.ValueExists('Config', 'language')) then
      lArquivoINI.WriteString('Path Defines', 'language', 'pt-BR');

    if not(lArquivoINI.ValueExists('Config', 'AcceptLanguageList')) then
      lArquivoINI.WriteString('Config', 'AcceptLanguageList', 'pt-BR,pt-BR;q=0.9,en-US;q=0.8,en;q=0.7');

    {read file ini}
    GlobalCEFApp.PathLogFile          := lPathAPP + lPathCEF + 'logs\';
    GlobalCEFApp.PathFrameworkDirPath := lArquivoINI.ReadString('Path Defines', 'FrameWork', '');
    GlobalCEFApp.PathResourcesDirPath := lArquivoINI.ReadString('Path Defines', 'Resources', '');
    GlobalCEFApp.PathLocalesDirPath   := lArquivoINI.ReadString('Path Defines', 'Locales', '');
    GlobalCEFApp.Pathcache            := lArquivoINI.ReadString('Path Defines', 'Cache', '');
    GlobalCEFApp.PathUserDataPath     := lArquivoINI.ReadString('Path Defines', 'Data User', '');

    GlobalCEFApp.DisableBlinkFeatures := 'AutomationControlled';

  except on E: Exception do
  end;

  GlobalCEFApp.DisableBlinkFeatures := 'AutomationControlled';

  {start service cef4delphi chromium}
  if not GlobalCEFApp.StartMainProcess then Exit;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFPrincipal, FPrincipal);
  Application.CreateForm(TDmGlobal, DmGlobal);
  Application.Run;
end.
