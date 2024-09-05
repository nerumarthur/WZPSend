unit DisparadorWZP.Principal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  uTWPPConnect,
  uTWPPConnect.ConfigCEF,
  uTWPPConnect.Constant,
  uTWPPConnect.JS,
  uWPPConnectDecryptFile,
  uTWPPConnect.Console,
  uTWPPConnect.Diversos,
  uTWPPConnect.AdjustNumber,
  uTWPPConnect.Config,
  uTWPPConnect.Classes,
  uTWPPConnect.Emoticons;

type
  TFPrincipal = class(TForm)
    WPPConnect: TWPPConnect;
    tmrProcessamento: TTimer;
    lblStatus: TLabel;
    pnlTopo: TPanel;
    pnlBotoes: TPanel;
    btnIniciar: TSpeedButton;
    pnlLog: TPanel;
    mmLog: TMemo;
    lblMeuNumero: TLabel;
    procedure tmrProcessamentoTimer(Sender: TObject);
    procedure btnIniciarClick(Sender: TObject);
    procedure WPPConnectAfterInjectJS(Sender: TObject);
    procedure WPPConnectConnected(Sender: TObject);
    procedure WPPConnectErroAndWarning(Sender: TObject; const PError, PInfoAdc: string);
    procedure WPPConnectGetIsAuthenticated(Sender: TObject; IsAuthenticated: Boolean);
    procedure WPPConnectGetIsLoaded(Sender: TObject; IsLoaded: Boolean);
    procedure WPPConnectWPPMonitorCrash(Sender: TObject; const WPPCrash: TWppCrash; AMonitorJSCrash: Boolean);
    procedure WPPConnectGetIsReady(Sender: TObject; IsReady: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure WPPConnectGetMyNumber(Sender: TObject);
  private
    { Private declarations }
    procedure LerFilaEDisparar;
    procedure Log(const pMensagem: string);
    function GetPercursoArquivoConfiguracao: string;
    procedure CarregarConfiguracaoBD(const pArquivoINI: string);
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

{$R *.dfm}

uses
  System.IniFiles,
  System.IOUtils,
  Variaveis.Server,
  DataModule.Global;

procedure TFPrincipal.btnIniciarClick(Sender: TObject);
begin
  if not WPPConnect.Auth(false) then
  begin
    WPPConnect.FormQrCodeType := TFormQrCodeType(1);
    WPPConnect.FormQrCodeStart;
  end;

  if not WPPConnect.FormQrCodeShowing then
    WPPConnect.FormQrCodeShowing := True;
end;

procedure TFPrincipal.FormCreate(Sender: TObject);
begin
  var lArquivoINI := GetPercursoArquivoConfiguracao;
  CarregarConfiguracaoBD(lArquivoINI);
end;

procedure TFPrincipal.CarregarConfiguracaoBD(const pArquivoINI: string);
begin
  var lArquivoINI := TIniFile.Create(pArquivoINI);
  var lJSONConfig := lArquivoINI.ReadString('DATABASE', 'CONFIG', string.Empty);

  TVariaveisServer.ConfigDataBase := lJSONConfig;
end;

function TFPrincipal.GetPercursoArquivoConfiguracao: string;
begin
{$IFDEF HORSE_ISAPI}
  Result := TPath.Combine(TPath.GetDirectoryName(GetModuleName(HInstance)), 'config.ini');
{$ELSE}
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'config.ini');
{$ENDIF}
end;

procedure TFPrincipal.LerFilaEDisparar;
begin
  var lDmGlobal := TDmGlobal.Create(Self);
  try
    var lListaEnvio := lDmGlobal.RetornarListaEnvio;
    for var lItemLista in lListaEnvio do
    begin
      WPPConnect.SendTextMessageEx(lItemLista.Destino + '@c.us', lItemLista.Mensagem, 'createChat: true');
      lDmGlobal.AlterarStatusEnviado(lItemLista.CdEnviaWhats);
      Log('Mensagem Enviada Para: ' + lItemLista.Destino + ' Conteúdo:' + lItemLista.Mensagem);
    end;
  finally
    lDmGlobal.Free;
  end;
end;

procedure TFPrincipal.Log(const pMensagem: string);
begin
  mmLog.Lines.Add(FormatDateTime('dd/mm/yyyy hh:mm', Now) + ' - ' + pMensagem);
end;

procedure TFPrincipal.tmrProcessamentoTimer(Sender: TObject);
begin
  tmrProcessamento.Enabled := False;
  LerFilaEDisparar;
  tmrProcessamento.Enabled := True;
end;

procedure TFPrincipal.WPPConnectAfterInjectJS(Sender: TObject);
begin
  WPPConnect.GetMyNumber;
end;

procedure TFPrincipal.WPPConnectConnected(Sender: TObject);
begin
  lblMeuNumero.Caption := 'My Number: ' + WPPConnect.MyNumber;
end;

procedure TFPrincipal.WPPConnectErroAndWarning(Sender: TObject; const PError, PInfoAdc: string);
begin
  raise Exception.Create(PError + ' - ' + PInfoAdc);
end;

procedure TFPrincipal.WPPConnectGetIsAuthenticated(Sender: TObject; IsAuthenticated: Boolean);
begin
  lblStatus.Caption := 'Autenticado';
end;

procedure TFPrincipal.WPPConnectGetIsLoaded(Sender: TObject; IsLoaded: Boolean);
begin
  lblStatus.Caption := 'Loading...';
  lblStatus.Caption := 'Offline';
  lblStatus.Font.Color := $002894FF;
  lblStatus.Font.Color := clGrayText;
end;

procedure TFPrincipal.WPPConnectGetIsReady(Sender: TObject; IsReady: Boolean);
begin
  tmrProcessamento.Enabled := True;
end;

procedure TFPrincipal.WPPConnectGetMyNumber(Sender: TObject);
begin
  lblMeuNumero.Caption := 'My Number: ' + WPPConnect.MyNumber;
end;

procedure TFPrincipal.WPPConnectWPPMonitorCrash(Sender: TObject; const WPPCrash: TWppCrash; AMonitorJSCrash: Boolean);
begin
  //se essa const vier true, quer dizer que parou de funcionar o Chromium e foi disparado pelo timer
  //do wppconnect que verifica se o js.abr continua funcionando.
  if AMonitorJSCrash then
  begin
    WPPConnect.RebootWPP;
    exit;
  end;
  //se caiu aqui é pq quem tá atualizando é o js.abr e a pagina do whatsapp continua funcionando.
  if (not(WPPCrash.MainLoaded)) or (not(WPPCrash.Authenticated)) then
    WPPConnect.RebootWPP;
end;

end.
