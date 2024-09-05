unit Status.Mensagem;

interface

type
{$SCOPEDENUMS ON}
  TStatusMensagem = (Pendente, Enviada);
{$SCOPEDENUMS OFF}
  TStatusMensagemHelper = record helper for TStatusMensagem
  public
    function ConverterParaInt: UInt8;
    class function ConverterDeInt(const pValor: UInt8): TStatusMensagem; static;
  end;

implementation

{ TStatusMensagemHelper }

class function TStatusMensagemHelper.ConverterDeInt(const pValor: UInt8): TStatusMensagem;
begin
  Result := TStatusMensagem(pValor);
end;

function TStatusMensagemHelper.ConverterParaInt: UInt8;
begin
  Result := UInt8(Self);
end;

end.
