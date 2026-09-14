unit uDMConexao;

interface

uses System.SysUtils, System.Classes, Data.DB, Data.SqlExpr;

type
  // Unica conexao. Os controllers a recebem por injecao no construtor.
  TdmConexao = class(TDataModule)
    SQLConnection: TSQLConnection;
  public
    procedure Conectar(const ACaminho: string = '');
    function NovaConsulta(const ASQL: string): TSQLQuery;
    procedure Executar(const ASQL: string);
    procedure Transacao(const AOperacao: TProc);
    function UltimoId: Int64;
  end;

var
  dmConexao: TdmConexao;

implementation

uses Data.DbxSqlite;

{$R *.dfm}

procedure TdmConexao.Conectar(const ACaminho: string);
var
  Q: TSQLQuery;
begin
  SQLConnection.Close;
  SQLConnection.LoginPrompt := False;
  SQLConnection.LoadParamsOnConnect := False;
  SQLConnection.DriverName := 'Sqlite';
  SQLConnection.Params.Values['DriverUnit'] := 'Data.DbxSqlite';
  SQLConnection.Params.Values['FailIfMissing'] := 'False';
  if ACaminho = '' then
    SQLConnection.Params.Values['Database'] :=
      ExtractFilePath(ParamStr(0)) + 'BDCANDIDATO.db'
  else
    SQLConnection.Params.Values['Database'] := ACaminho;
  try
    SQLConnection.Open;
    Executar('PRAGMA foreign_keys = ON');
    Executar('PRAGMA busy_timeout = 5000');
    Q := NovaConsulta('PRAGMA foreign_keys');
    try
      Q.Open;
      if Q.Fields[0].AsInteger <> 1 then
        raise Exception.Create('Nao foi possivel ativar as chaves estrangeiras.');
    finally
      Q.Free;
    end;
    Transacao(
      procedure
      begin
        Executar('CREATE TABLE IF NOT EXISTS TbClientes (' + sLineBreak +
          '  IdCliente INTEGER PRIMARY KEY AUTOINCREMENT,' + sLineBreak +
          '  NomeReduzido VARCHAR(20),' + sLineBreak +
          '  RazaoSocial VARCHAR(60),' + sLineBreak +
          '  NatJuridica CHAR(1),' + sLineBreak +
          '  CPFCNPJ VARCHAR(14),' + sLineBreak +
          '  DtNascimento DATETIME,' + sLineBreak +
          '  DtTmCadastro DATETIME' + sLineBreak + ')');
        Executar('CREATE TABLE IF NOT EXISTS TbContatos (' + sLineBreak +
          '  IdContato INTEGER PRIMARY KEY AUTOINCREMENT,' + sLineBreak +
          '  IdCliente INTEGER NOT NULL,' + sLineBreak +
          '  Nome VARCHAR(60),' + sLineBreak +
          '  Email VARCHAR(90),' + sLineBreak +
          '  FOREIGN KEY (IdCliente) REFERENCES TbClientes(IdCliente)' +
          sLineBreak + ')');
        Executar('CREATE INDEX IF NOT EXISTS IX_Contatos_Cliente ' +
          'ON TbContatos (IdCliente)');
      end);
  except
    SQLConnection.Close;
    raise;
  end;
end;

function TdmConexao.NovaConsulta(const ASQL: string): TSQLQuery;
begin
  Result := TSQLQuery.Create(nil);
  try
    Result.SQLConnection := SQLConnection;
    Result.SQL.Text := ASQL;
  except
    Result.Free;
    raise;
  end;
end;

procedure TdmConexao.Executar(const ASQL: string);
var
  Q: TSQLQuery;
begin
  Q := NovaConsulta(ASQL);
  try
    Q.ExecSQL;
  finally
    Q.Free;
  end;
end;

procedure TdmConexao.Transacao(const AOperacao: TProc);
var
  T: TTransactionDesc;
begin
  if SQLConnection.InTransaction then
    raise Exception.Create('Transacao aninhada nao permitida.');
  FillChar(T, SizeOf(T), 0);
  T.TransactionID := 1;
  T.IsolationLevel := xilREADCOMMITTED;

  SQLConnection.StartTransaction(T);
  try
    AOperacao();
    SQLConnection.Commit(T);
  except
    on E: Exception do
    begin
      try
        SQLConnection.Rollback(T);
      except
        on R: Exception do
          raise Exception.Create('Falha: ' + E.Message +
            '. Falha adicional no rollback: ' + R.Message);
      end;
      raise;
    end;
  end;
end;

function TdmConexao.UltimoId: Int64;
var
  Q: TSQLQuery;
begin
  Q := NovaConsulta('SELECT last_insert_rowid() AS Id');
  try
    Q.Open;
    if not TryStrToInt64(Q.Fields[0].AsString, Result) or (Result <= 0) then
      raise Exception.Create('Nao foi possivel obter o ID gerado pelo SQLite.');
  finally
    Q.Free;
  end;
end;

end.
