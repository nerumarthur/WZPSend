unit DataModule.Global;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.ConsoleUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Comp.UI;

type
  TDemandaEnvio = class
  strict private
    FCdEnviaWhats: UInt32;
    FDestino: string;
    FMensagem: string;
  public
    property CdEnviaWhats: UInt32 read FCdEnviaWhats write FCdEnviaWhats;
    property Destino: string read FDestino write FDestino;
    property Mensagem: string read FMensagem write FMensagem;
  end;

  TDmGlobal = class(TDataModule)
    FDConnection: TFDConnection;
    qryInsertMensagem: TFDQuery;
    driverSQLite: TFDPhysSQLiteDriverLink;
    qryConsulta: TFDQuery;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    qryBaixaFila: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
    procedure FDConnectionBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function RetornarListaEnvio: TArray<TDemandaEnvio>;
    procedure EnviarMensagem(const pDestino: string; const pMensagem: string);
    procedure AlterarStatusEnviado(const pCdEnviaWhats: UInt32);
  end;

var
  DmGlobal: TDmGlobal;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

uses
  Variaveis.Server,
  Status.Mensagem;

{ TDmGlobal }

procedure TDmGlobal.AlterarStatusEnviado(const pCdEnviaWhats: UInt32);
begin
  qryBaixaFila.Active := False;
  qryBaixaFila.SQL.Clear;
  qryBaixaFila.SQL.Add('update envia_whats ');
  qryBaixaFila.SQL.Add('   set status = :status ');
  qryBaixaFila.SQL.Add('where cdenviawhats = :cdenviawhats');
  qryBaixaFila.ParamByName('status').AsByte := TStatusMensagem.Enviada.ConverterParaInt;
  qryBaixaFila.ParamByName('cdenviawhats').AsInteger := pCdEnviaWhats;
  qryBaixaFila.ExecSQL;
end;

procedure TDmGlobal.DataModuleCreate(Sender: TObject);
begin
  FDConnection.Connected := True;
end;

procedure TDmGlobal.EnviarMensagem(const pDestino, pMensagem: string);
begin
  qryInsertMensagem.Active := False;
  qryInsertMensagem.SQL.Clear;
  qryInsertMensagem.SQL.Add('insert into envia_whats ');
  qryInsertMensagem.SQL.Add('(destino, mensagem, status) values ( ');
  qryInsertMensagem.SQL.Add(':destino, :mensagem, :status)');
  qryInsertMensagem.ParamByName('destino').AsString := pDestino;
  qryInsertMensagem.ParamByName('mensagem').AsString := pMensagem;
  qryInsertMensagem.ParamByName('status').AsByte := TStatusMensagem.Pendente.ConverterParaInt;
  qryInsertMensagem.ExecSQL;
end;

procedure TDmGlobal.FDConnectionBeforeConnect(Sender: TObject);
begin
  var lListaParametros := TStringList.Create;
  try
    ExtractStrings([';'], [' '], PChar(TVariaveisServer.ConfigDataBase), lListaParametros);
    for var lI := 0 to lListaParametros.Count -1 do
    begin
      FDConnection.Params.Add(lListaParametros[lI]);
    end;
  finally
    lListaParametros.Free;
  end;
end;

function TDmGlobal.RetornarListaEnvio: TArray<TDemandaEnvio>;
begin
  var lLimiteEnvio := 4;
  var lIndex := 0;

  qryConsulta.Active := False;
  qryConsulta.SQL.Clear;
  qryConsulta.SQL.Add('select cdenviawhats, destino, mensagem, status ');
  qryConsulta.SQL.Add('from envia_whats where status = :status ');
  qryConsulta.ParamByName('status').AsByte := TStatusMensagem.Pendente.ConverterParaInt;
  qryConsulta.Active := True;

  SetLength(Result, qryConsulta.RecordCount);

  while (lIndex <= lLimiteEnvio) and (not qryConsulta.Eof) do
  begin
    var lDemandaEnvio := TDemandaEnvio.Create;
    lDemandaEnvio.CdEnviaWhats := qryConsulta.FieldByName('cdenviawhats').AsInteger;
    lDemandaEnvio.Destino := qryConsulta.FieldByName('destino').AsString;
    lDemandaEnvio.Mensagem := qryConsulta.FieldByName('mensagem').AsString;
    Result[lIndex] := lDemandaEnvio;

    Inc(lIndex);
    qryConsulta.Next;
  end;

  qryConsulta.Active := False;
end;

end.
