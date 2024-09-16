unit Registros.WZPSendServer;

interface

type
  TRegistradorImplementacoesWZPSendServer = class
  strict private
    class function GetPercursoArquivoConfiguracao: string;
    class procedure CarregarConfiguracaoBD(const pArquivoINI: string);
    class procedure RegistrarMiddlewareServersHorse;
    class procedure RegistrarControllers;
  public
    class procedure Registrar;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.IniFiles,
  Horse,
  Horse.Jhonson,
  Horse.CORS,
  Horse.OctetStream,

  Variaveis.Server,

  Controller.Mensagens;

{ TRegistradorImplementacoesWZPSendServer }

class procedure TRegistradorImplementacoesWZPSendServer.CarregarConfiguracaoBD(const pArquivoINI: string);
begin
  var lArquivoINI := TIniFile.Create(pArquivoINI);
  var lJSONConfig := lArquivoINI.ReadString('DATABASE', 'CONFIG', string.Empty);

  TVariaveisServer.ConfigDataBase := lJSONConfig;
end;

class function TRegistradorImplementacoesWZPSendServer.GetPercursoArquivoConfiguracao: string;
begin
{$IFDEF HORSE_ISAPI}
  Result := TPath.Combine(TPath.GetDirectoryName(GetModuleName(HInstance)), 'config.ini');
{$ELSE}
  Result := TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'config.ini');
{$ENDIF}
end;

class procedure TRegistradorImplementacoesWZPSendServer.Registrar;
begin
  RegistrarMiddlewareServersHorse;
  RegistrarControllers;

  var lArquivoINI := GetPercursoArquivoConfiguracao;
  CarregarConfiguracaoBD(lArquivoINI);
end;

class procedure TRegistradorImplementacoesWZPSendServer.RegistrarControllers;
begin
  TControllerMensagens.Registrar;
end;

class procedure TRegistradorImplementacoesWZPSendServer.RegistrarMiddlewareServersHorse;
begin
  THorse
    .Use(Jhonson)
    .Use(CORS)
    .Use(OctetStream)
end;

end.
