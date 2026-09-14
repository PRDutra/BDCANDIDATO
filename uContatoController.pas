unit uContatoController;

interface

uses System.SysUtils, System.Generics.Collections, Data.DB, Data.SqlExpr,
  uContato, uIContatoController, uDMConexao;

type
  TContatoController = class(TInterfacedObject, IContatoController)
  private
    FConexao: TdmConexao;
    procedure Gravar(AObjeto: TContato; ANovo: Boolean);
  public
    constructor Create(AConexao: TdmConexao);
    procedure Validar(AObjeto: TContato);
    procedure Inserir(AObjeto: TContato);
    procedure Alterar(AObjeto: TContato);
    procedure Excluir(AIdContato: Int64; AIdCliente: Int64);
    function ConsultarPorCliente(AIdCliente: Int64): TObjectList<TContato>;
  end;

implementation

uses uUtils;

constructor TContatoController.Create(AConexao: TdmConexao);
begin
  inherited Create;
  Exigir(Assigned(AConexao), 'Conexao nao informada.');
  FConexao := AConexao;
end;

procedure TContatoController.Inserir(AObjeto: TContato);
begin
  Validar(AObjeto);
  Exigir(AObjeto.IdContato = 0, 'Novo registro deve possuir ID zero.');
  Gravar(AObjeto, True);
end;

procedure TContatoController.Alterar(AObjeto: TContato);
begin
  Validar(AObjeto);
  ValidarId(AObjeto.IdContato, 'IdContato');
  Gravar(AObjeto, False);
end;

procedure TContatoController.Validar(AObjeto: TContato);
begin
  Exigir(Assigned(AObjeto), 'Contato nao informado.');
  // Regras 11 a 13: nome obrigatorio, limites e vinculo obrigatorio.
  AObjeto.Nome := Trim(AObjeto.Nome);
  AObjeto.Email := Trim(AObjeto.Email);
  Exigir(AObjeto.Nome <> '', 'Informe o nome do contato.');
  Exigir(Length(AObjeto.Nome) <= 60, 'Nome do contato: maximo 60 caracteres.');
  Exigir(Length(AObjeto.Email) <= 90, 'Email: maximo 90 caracteres.');
  ValidarId(AObjeto.IdCliente, 'IdCliente');
end;

procedure TContatoController.Gravar(AObjeto: TContato; ANovo: Boolean);
var
  Q: TSQLQuery;
  iId: Int64;
begin
  iId := AObjeto.IdContato;
  FConexao.Transacao(
    procedure
    begin
      if ANovo then
        Q := FConexao.NovaConsulta(
          'INSERT INTO TbContatos (IdCliente, Nome, Email)' + sLineBreak +
          'VALUES (:IdCliente, :Nome, :Email)')
      else
        Q := FConexao.NovaConsulta(
          'UPDATE TbContatos SET' + sLineBreak +
          '  Nome = :Nome,' + sLineBreak +
          '  Email = :Email' + sLineBreak +
          'WHERE IdContato = :IdContato AND IdCliente = :IdCliente');
      try
        Q.ParamByName('IdCliente').AsLargeInt := AObjeto.IdCliente;
        Q.ParamByName('Nome').AsString := AObjeto.Nome;
        Q.ParamByName('Email').AsString := AObjeto.Email;
        if not ANovo then
          Q.ParamByName('IdContato').AsLargeInt := iId;
        Exigir(Q.ExecSQL = 1, 'Contato nao encontrado neste cliente.');
      finally
        Q.Free;
      end;
      if ANovo then
        iId := FConexao.UltimoId;
    end);
  AObjeto.IdContato := iId;
end;

procedure TContatoController.Excluir(AIdContato: Int64; AIdCliente: Int64);
var
  Q: TSQLQuery;
begin
  ValidarId(AIdContato, 'IdContato');
  ValidarId(AIdCliente, 'IdCliente');
  FConexao.Transacao(
    procedure
    begin
      Q := FConexao.NovaConsulta(
        'DELETE FROM TbContatos' + sLineBreak +
        'WHERE IdContato = :IdContato AND IdCliente = :IdCliente');
      try
        Q.ParamByName('IdContato').AsLargeInt := AIdContato;
        Q.ParamByName('IdCliente').AsLargeInt := AIdCliente;
        Exigir(Q.ExecSQL = 1, 'Contato nao encontrado neste cliente.');
      finally
        Q.Free;
      end;
    end);
end;

function TContatoController.ConsultarPorCliente(AIdCliente: Int64): TObjectList<TContato>;
var
  Q: TSQLQuery;
  C: TContato;
begin
  ValidarId(AIdCliente, 'IdCliente');
  Result := TObjectList<TContato>.Create(True);
  try
    Q := FConexao.NovaConsulta(
      'SELECT IdContato, IdCliente, Nome, Email' + sLineBreak +
      'FROM TbContatos' + sLineBreak +
      'WHERE IdCliente = :IdCliente' + sLineBreak +
      'ORDER BY Nome, IdContato');
    try
      Q.ParamByName('IdCliente').AsLargeInt := AIdCliente;
      Q.Open;
      while not Q.Eof do
      begin
        C := TContato.Create;
        Result.Add(C);
        C.IdContato := Q.FieldByName('IdContato').AsLargeInt;
        C.IdCliente := Q.FieldByName('IdCliente').AsLargeInt;
        C.Nome := Q.FieldByName('Nome').AsString;
        C.Email := Q.FieldByName('Email').AsString;
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
