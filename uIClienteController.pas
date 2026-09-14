unit uIClienteController;

interface

uses System.Generics.Collections, uCliente;

type
  IClienteController = interface
    ['{8A48B502-5D90-41ED-85A2-AF082984E411}']
    procedure Validar(AObjeto: TCliente);
    procedure Inserir(AObjeto: TCliente);
    procedure Alterar(AObjeto: TCliente);
    procedure Excluir(AIdCliente: Int64);
    function Consultar: TObjectList<TCliente>;
  end;

implementation

end.
