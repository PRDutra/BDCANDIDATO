unit uContato;

interface

type
  TContato = class
  private
    FIdContato: Int64;
    FIdCliente: Int64;
    FNome: string;
    FEmail: string;
  public
    property IdContato: Int64 read FIdContato write FIdContato;
    property IdCliente: Int64 read FIdCliente write FIdCliente;
    property Nome: string read FNome write FNome;
    property Email: string read FEmail write FEmail;
  end;

implementation

end.
