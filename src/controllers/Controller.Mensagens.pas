unit Controller.Mensagens;

interface

uses
  Horse;

type
  TControllerMensagens = class
  strict private
    procedure DoPostEnviarMensagem(pRequest: THorseRequest; pResponse: THorseResponse);
  strict protected
    class procedure PostEnviarMensagem(pRequest: THorseRequest; pResponse: THorseResponse);
  public
    class procedure Registrar;
  end;

implementation

uses
  System.JSON,
  DataModule.Global;

{ TControllerMensagens }

procedure TControllerMensagens.DoPostEnviarMensagem(pRequest: THorseRequest; pResponse: THorseResponse);
begin
  var lDmGlobal := TDmGlobal.Create(nil);
  try
    var lJSONBody := pRequest.Body<TJSONObject>;
    var lDestino: string;
    var lMensagem: string;

    if not lJSONBody.TryGetValue<string>('destino', lDestino) or
      not lJSONBody.TryGetValue<string>('mensagem', lMensagem) then
    begin
      pResponse.Send('Falta argumentos!').Status(THTTPStatus.BadRequest);
    end else
    begin
      lDmGlobal.EnviarMensagem(lDestino, lMensagem);
      pResponse.Send('Mensagem Enviada para a Fila!').Status(THTTPStatus.Created);
    end;
  finally
    lDmGlobal.Free;
  end;
end;

class procedure TControllerMensagens.PostEnviarMensagem(pRequest: THorseRequest; pResponse: THorseResponse);
begin
  var lInstancia := Self.Create;
  try
    lInstancia.DoPostEnviarMensagem(pRequest, pResponse);
  finally
    lInstancia.Free;
  end;
end;

class procedure TControllerMensagens.Registrar;
begin
  THorse.Post('/enviarmensagem', Self.PostEnviarMensagem);
end;

end.
