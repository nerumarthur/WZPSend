unit Variaveis.Server;

interface

type
  TVariaveisServer = class
  strict private
    class var FConfigDataBase: string;
  public
    class property ConfigDataBase: string read FConfigDataBase write FConfigDataBase;
  end;

implementation

end.
