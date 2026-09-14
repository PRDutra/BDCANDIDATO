unit uIContatoController;

interface

uses System.Generics.Collections, uContato;

type
  IContatoController = interface
    ['{42DB31F2-D977-4F3C-B961-F4C8B0E5C103}']
    procedure Validar(AObjeto: TContato);
    procedure Inserir(AObjeto: TContato);
    procedure Alterar(AObjeto: TContato);
    procedure Excluir(AIdContato: Int64; AIdCliente: Int64);
    function ConsultarPorCliente(AIdCliente: Int64): TObjectList<TContato>;
  end;

implementation

end.
