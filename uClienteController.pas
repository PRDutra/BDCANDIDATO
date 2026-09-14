unit uClienteController;

interface

uses System.SysUtils, System.Generics.Collections, Data.DB, Data.SqlExpr,
  uCliente, uIClienteController, uDMConexao;

type
  TClienteController = class(TInterfacedObject, IClienteController)
  private
    FConexao: TdmConexao;
    procedure Gravar(AObjeto: TCliente; ANovo: Boolean);
  public
    constructor Create(AConexao: TdmConexao);
    procedure Validar(AObjeto: TCliente);
    procedure Inserir(AObjeto: TCliente);
    procedure Alterar(AObjeto: TCliente);
    procedure Excluir(AIdCliente: Int64);
    function Consultar: TObjectList<TCliente>;
  end;

implementation

uses uUtils;

constructor TClienteController.Create(AConexao: TdmConexao);
begin
  inherited Create;
  Exigir(Assigned(AConexao), 'Conexao nao informada.');
  FConexao := AConexao;
end;

procedure TClienteController.Inserir(AObjeto: TCliente);
begin
  Validar(AObjeto);
  Exigir(AObjeto.IdCliente = 0, 'Novo registro deve possuir ID zero.');
  Gravar(AObjeto, True);
end;

procedure TClienteController.Alterar(AObjeto: TCliente);
begin
  Validar(AObjeto);
  ValidarId(AObjeto.IdCliente, 'IdCliente');
  Gravar(AObjeto, False);
end;

procedure TClienteController.Validar(AObjeto: TCliente);
var
  C: Char;
begin
  Exigir(Assigned(AObjeto), 'Cliente nao informado.');
  AObjeto.NomeReduzido := Trim(AObjeto.NomeReduzido);
  AObjeto.RazaoSocial := Trim(AObjeto.RazaoSocial);
  // Regras 1 a 5: obrigatoriedade, limites e natureza juridica restrita.
  Exigir(AObjeto.NomeReduzido <> '', 'Informe o nome reduzido.');
  Exigir(Length(AObjeto.NomeReduzido) <= 20, 'Nome reduzido: maximo 20 caracteres.');
  // Pessoa fisica pode ter razao social vazia; pessoa juridica deve informa-la.
  if AObjeto.NatJuridica = 'J' then
    Exigir(AObjeto.RazaoSocial <> '', 'Informe a razao social.');
  Exigir(Length(AObjeto.RazaoSocial) <= 60, 'Razao social: maximo 60 caracteres.');
  Exigir((AObjeto.NatJuridica = 'F') or (AObjeto.NatJuridica = 'J'),
    'Natureza juridica deve ser F ou J.');
  // Aceita a pontuacao das mascaras, mas rejeita letras e outros caracteres.
  for C in AObjeto.CPFCNPJ do
    Exigir(CharInSet(C, ['0'..'9', '.', '/', '-', ' ']), 'CPF/CNPJ invalido.');
  AObjeto.CPFCNPJ := SomenteNumeros(AObjeto.CPFCNPJ);
  // Regras 6 a 8: somente numeros; nao exige digitos verificadores.
  if AObjeto.NatJuridica = 'F' then
    Exigir(Length(AObjeto.CPFCNPJ) = 11, 'CPF deve conter 11 digitos.')
  else
    Exigir(Length(AObjeto.CPFCNPJ) = 14, 'CNPJ deve conter 14 digitos.');
  // Regra 9: zero representa nascimento nao informado (NULL no banco).
  Exigir((AObjeto.DtNascimento >= 0) and (AObjeto.DtNascimento < Date + 1),
    'Nascimento invalido ou posterior a data atual.');
end;

procedure TClienteController.Gravar(AObjeto: TCliente; ANovo: Boolean);
var
  Q: TSQLQuery;
  iId: Int64;
  Cadastro: TDateTime;
begin
  iId := AObjeto.IdCliente;
  Cadastro := Now; // Regra 10: gerado na inclusao e preservado na alteracao.
  FConexao.Transacao(
    procedure
    begin
      if ANovo then
        Q := FConexao.NovaConsulta(
          'INSERT INTO TbClientes' + sLineBreak +
          '  (NomeReduzido, RazaoSocial, NatJuridica, CPFCNPJ, DtNascimento, DtTmCadastro)' + sLineBreak +
          'VALUES' + sLineBreak +
          '  (:NomeReduzido, :RazaoSocial, :NatJuridica, :CPFCNPJ, :DtNascimento, :DtTmCadastro)')
      else
        Q := FConexao.NovaConsulta(
          'UPDATE TbClientes SET' + sLineBreak +
          '  NomeReduzido = :NomeReduzido,' + sLineBreak +
          '  RazaoSocial = :RazaoSocial,' + sLineBreak +
          '  NatJuridica = :NatJuridica,' + sLineBreak +
          '  CPFCNPJ = :CPFCNPJ,' + sLineBreak +
          '  DtNascimento = :DtNascimento' + sLineBreak +
          'WHERE IdCliente = :IdCliente');
      try
        Q.ParamByName('NomeReduzido').AsString := AObjeto.NomeReduzido;
        Q.ParamByName('RazaoSocial').AsString := AObjeto.RazaoSocial;
        Q.ParamByName('NatJuridica').AsString := AObjeto.NatJuridica;
        Q.ParamByName('CPFCNPJ').AsString := AObjeto.CPFCNPJ;
        Q.ParamByName('DtNascimento').AsString := DataSQL(AObjeto.DtNascimento);
        if AObjeto.DtNascimento = 0 then
          Q.ParamByName('DtNascimento').Clear;
        if ANovo then
          Q.ParamByName('DtTmCadastro').AsString := DataSQL(Cadastro)
        else
          Q.ParamByName('IdCliente').AsLargeInt := iId;
        Exigir(Q.ExecSQL = 1, 'Cliente nao encontrado para gravacao.');
      finally
        Q.Free;
      end;
      if ANovo then
        iId := FConexao.UltimoId;
    end);
  // So atualiza a identidade em memoria depois do commit.
  AObjeto.IdCliente := iId;
  if ANovo then
    AObjeto.DtTmCadastro := Cadastro;
end;

procedure TClienteController.Excluir(AIdCliente: Int64);
var
  Q: TSQLQuery;
begin
  ValidarId(AIdCliente, 'IdCliente');
  // Regra 14: contatos e cliente excluidos na mesma transacao, nesta ordem.
  FConexao.Transacao(
    procedure
    begin
      Q := FConexao.NovaConsulta(
        'DELETE FROM TbContatos' + sLineBreak + 'WHERE IdCliente = :IdCliente');
      try
        Q.ParamByName('IdCliente').AsLargeInt := AIdCliente;
        Q.ExecSQL;
      finally
        Q.Free;
      end;
      Q := FConexao.NovaConsulta(
        'DELETE FROM TbClientes' + sLineBreak + 'WHERE IdCliente = :IdCliente');
      try
        Q.ParamByName('IdCliente').AsLargeInt := AIdCliente;
        Exigir(Q.ExecSQL = 1, 'Cliente nao encontrado para exclusao.');
      finally
        Q.Free;
      end;
    end);
end;

function TClienteController.Consultar: TObjectList<TCliente>;
var
  Q: TSQLQuery;
  C: TCliente;
begin
  Result := TObjectList<TCliente>.Create(True);
  try
    Q := FConexao.NovaConsulta(
      'SELECT IdCliente, NomeReduzido, RazaoSocial, NatJuridica, CPFCNPJ,' + sLineBreak +
      '  DtNascimento, DtTmCadastro' + sLineBreak +
      'FROM TbClientes' + sLineBreak + 'ORDER BY NomeReduzido, IdCliente');
    try
      Q.Open;
      while not Q.Eof do
      begin
        C := TCliente.Create;
        Result.Add(C);
        C.IdCliente := Q.FieldByName('IdCliente').AsLargeInt;
        C.NomeReduzido := Q.FieldByName('NomeReduzido').AsString;
        C.RazaoSocial := Q.FieldByName('RazaoSocial').AsString;
        C.NatJuridica := Q.FieldByName('NatJuridica').AsString;
        C.CPFCNPJ := Q.FieldByName('CPFCNPJ').AsString;
        C.DtNascimento := LerDataSQL(Q.FieldByName('DtNascimento').AsString);
        C.DtTmCadastro := LerDataSQL(Q.FieldByName('DtTmCadastro').AsString);
        Q.Next;
      end;
    finally
      Q.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

end.
