unit uCliente;

interface

type
  TCliente = class
  private
    FIdCliente: Int64;
    FNomeReduzido: string;
    FRazaoSocial: string;
    FNatJuridica: string;
    FCPFCNPJ: string;
    FDtNascimento: TDateTime;
    FDtTmCadastro: TDateTime;
  public
    property IdCliente: Int64 read FIdCliente write FIdCliente;
    property NomeReduzido: string read FNomeReduzido write FNomeReduzido;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property NatJuridica: string read FNatJuridica write FNatJuridica;
    property CPFCNPJ: string read FCPFCNPJ write FCPFCNPJ;
    property DtNascimento: TDateTime read FDtNascimento write FDtNascimento;
    property DtTmCadastro: TDateTime read FDtTmCadastro write FDtTmCadastro;
  end;

implementation

end.
