program WZPSendServer;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Horse,
  Registros.WZPSendServer in 'registros\Registros.WZPSendServer.pas',
  Controller.Mensagens in '..\controllers\Controller.Mensagens.pas',
  DataModule.Global in '..\datamodules\DataModule.Global.pas' {DmGlobal: TDataModule},
  Status.Mensagem in '..\utils\Status.Mensagem.pas',
  Variaveis.Server in '..\utils\Variaveis.Server.pas';

begin
  ReportMemoryLeaksOnShutdown := True;

  TRegistradorImplementacoesWZPSendServer.Registrar;

  THorse.Get('ping',
    procedure(pRequest: THorseRequest; pResponse: THorseResponse)
    begin
      pResponse.Send('pong');
    end);

  THorse.Post('echo',
    procedure(pRequest: THorseRequest; pResponse: THorseResponse)
    begin
      Writeln('echo ' + pRequest.Body);
      pResponse
        .Status(THTTPStatus.Created)
        .Send(pRequest.Body);
    end);

  THorse.Listen(9000,
    procedure
    begin
      Writeln('Server is runing on port ' + THorse.Port.ToString);
      Writeln('Press return to stop...');

{$IFDEF MSWINDOWS}
      Readln;
{$ELSE}
      while True do
      begin
        Sleep(100);
      end;
{$ENDIF}

      THorse.StopListen;
    end);
end.
