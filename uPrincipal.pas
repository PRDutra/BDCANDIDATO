unit uPrincipal;

interface

uses System.Classes, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls;

type
  TfrmPrincipal = class(TForm)
    lblTitulo: TLabel;
    btnClientes: TButton;
    btnSair: TButton;
    procedure ClientesClick(ASender: TObject);
    procedure SairClick(ASender: TObject);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses uClientes, uClienteController, uDMConexao;

{$R *.dfm}

procedure TfrmPrincipal.ClientesClick(ASender: TObject);
var
  Tela: TfrmClientes;
begin
  Tela := TfrmClientes.Create(Self);
  try
    Tela.Inicializar(TClienteController.Create(dmConexao));
    Tela.ShowModal;
  finally
    Tela.Free;
  end;
end;

procedure TfrmPrincipal.SairClick(ASender: TObject);
begin
  Close;
end;

end.
