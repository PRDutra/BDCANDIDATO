# BDCANDIDATO

Cadastro de clientes e contatos em Delphi 13 Community Edition, VCL e Win32,
com SQLite, dbExpress e `TSQLConnection`. Somente componentes nativos.

## Abrir e executar

1. Abra `BDCANDIDATO.dpr` ou `BDCANDIDATO.dproj` no Delphi 13 Community Edition.
2. Selecione **Windows 32-bit** e execute **Project > Build BDCANDIDATO**.
3. Mantenha `sqlite3.dll` **Win32** e `BDCANDIDATO.db` ao lado do executável.
   A DLL incluída foi copiada da pasta `bin` da instalação do Delphi 13.
4. Execute o programa. A pasta do executável deve permitir escrita.

O projeto está configurado para Win32, com saída na pasta do projeto. Caso
altere a pasta de saída na IDE, copie o banco e a DLL para a nova pasta.
A Community Edition desta instalação não permite compilação pelo `dcc32.exe`
no terminal; use a IDE. Não são necessários pacotes de runtime, GetIt,
drivers de terceiros, servidor de banco nem configurações em arquivos INI.

## Organização e responsabilidades

| Arquivos | Responsabilidade |
| --- | --- |
| `BDCANDIDATO.dpr`, `BDCANDIDATO.dproj` | Inicialização, Win32 e projeto da IDE |
| `uCliente.pas`, `uContato.pas` | Modelos encapsulados por propriedades |
| `uIClienteController.pas`, `uIContatoController.pas` | Contratos utilizados pelas telas |
| `uClienteController.pas`, `uContatoController.pas` | Validação, consulta e persistência SQL |
| `uDMConexao.pas`, `uDMConexao.dfm` | Conexão, criação do banco e transações |
| `uPrincipal`, `uClientes`, `uContatos` (`.pas` e `.dfm`) | Views VCL |
| `uUtils.pas` | Normalização numérica, validação de IDs e datas ISO |
| `BDCANDIDATO.db` | Banco SQLite vazio, pronto para entrega |
| `testes/BDCANDIDATO_TESTES.dpr` | Testes de integração sem bibliotecas externas |
| `testes/resultado-testes.txt` | Resultado da execução dos testes |

MVC simples: as Views editam modelos com controles comuns e chamam interfaces;
os controllers validam e executam SQL; o DataModule concentra a conexão.
O formulário principal compõe o cadastro de clientes, que compõe a tela de
contatos. Não existem camadas artificiais de services/repositories/factories.

`TListView` é usado exclusivamente para consulta e seleção. Não há datasets
editáveis nas telas. As listas retornadas pelos controllers possuem os modelos
e são liberadas pelos formulários. Os controllers descendem de
`TInterfacedObject` e são liberados pela contagem de referências das interfaces.
Eles recebem uma referência não proprietária ao DataModule, que vive até o
encerramento da aplicação. Formulários modais são liberados em `finally`.

## Conexão e criação automática

`TdmConexao.Conectar` usa `DriverName = 'Sqlite'`, a unit nativa
`Data.DbxSqlite`, `LoginPrompt = False` e `FailIfMissing = False`.
O caminho padrão é `ExtractFilePath(ParamStr(0)) + 'BDCANDIDATO.db'`.

O próprio driver dbExpress cria o arquivo ausente. Em seguida a aplicação
ativa e verifica `PRAGMA foreign_keys = ON`, configura espera de bloqueio
de cinco segundos e cria as duas tabelas e o índice por cliente dentro de
uma transação, com `IF NOT EXISTS`. A aplicação não recria nem apaga dados
existentes. Um banco com esquema incompatível exige correção própria;
não há migrações automáticas destrutivas.

As colunas e a FK seguem o enunciado. SQLite não impõe os tamanhos declarados
em `VARCHAR(n)`; por isso os limites são verificados tanto nos controllers
quanto nos controles VCL. O banco não usa exclusão em cascata: o controller
executa explicitamente a exclusão dos contatos e depois do cliente.

## Regras e SQL

As regras estão comentadas nos métodos `Validar` e `Gravar` dos controllers.
Nome reduzido, razão social e nome do contato são obrigatórios após `Trim`.
Limites: 20, 60, 60 e 90 caracteres, respectivamente para nome reduzido,
razão social, nome do contato e email. Natureza aceita exclusivamente F/J.
CPF exige 11 dígitos e CNPJ 14, sem validação adicional de dígitos verificadores.
As máscaras mudam com a natureza; só números são persistidos.

Nascimento é opcional: a caixa do seletor de data desmarcada significa NULL.
Uma data informada não pode estar no futuro. Cadastro é preenchido com `Now`
somente na inclusão e preservado na alteração. As datas são armazenadas como
texto ISO em colunas DATETIME, mantendo o horário local sem conversão de fuso.
IDs são positivos nas operações sobre registros existentes; a inclusão exige
ID zero e só atribui a identidade gerada ao modelo depois do commit.

Todas as inclusões, alterações e exclusões usam `TSQLQuery.ExecSQL` e parâmetros.
Nenhum dado do usuário é concatenado ao SQL. Não se usa edição automática de
datasets. O driver SQLite pode retornar expressões como `last_insert_rowid()`
como WideMemo; o ID é lido por posição e convertido com `TryStrToInt64`.

## Transações e erros

`TdmConexao.Transacao` recebe a operação e usa a API real
`TSQLConnection.StartTransaction(TTransactionDesc)`, `Commit` e `Rollback`.
Essa sobrecarga é legada e marcada como deprecated pela Embarcadero, mas está
disponível e foi compilada/testada no Delphi 13 Win32. Foi mantida para atender
ao uso explícito de StartTransaction solicitado na avaliação.

Inclusão, alteração, exclusão e criação das tabelas passam por esse método.
Não são admitidas transações aninhadas. Falhas executam rollback e propagam
a exceção. Se o próprio rollback falhar, sua mensagem acompanha a falha original.
Os formulários apresentam mensagens e conservam a edição quando a gravação
falha. Cancelar descarta alterações dos controles, sem escrever no banco.

Na exclusão de cliente, uma única transação envolve os dois DELETEs:
contatos primeiro, cliente depois. O teste de integração instala um gatilho
temporário que aborta o segundo DELETE e verifica a recuperação dos contatos.

## Validação realizada e roteiro de entrega

A aplicação foi compilada e executada no Delphi 13 Community Edition instalado,
com destino Win32. Os testes são executados contra um arquivo exclusivo de teste,
criado e removido pela própria suíte; não modificam o banco de entrega.

Para repetir, abra `testes/BDCANDIDATO_TESTES.dpr`, selecione Win32, execute
**Build** e rode o executável. Mantenha a DLL Win32 ao lado dele. A saída também
é gravada em `resultado-testes.txt`; código de saída zero indica sucesso.

Os 47 testes passaram. Eles cobrem CRUD dos dois modelos, parâmetros com apóstrofos, datas,
persistência após reconexão, validações, FK, rollback integral, carregamento
dos quatro DFM, máscaras, estado de botões e integridade SQLite. Também acionam
Novo, Alterar, Salvar e Cancelar nas telas, incluindo persistência por esses botões.

Antes da entrega, faça também a conferência visual na máquina de avaliação:

- Novo cliente F com CPF; salvar, selecionar e alterar.
- Cliente J com CNPJ; alternar as máscaras e preencher o documento completo.
- Nascimento opcional, data futura e campos obrigatórios vazios.
- Contatos de dois clientes distintos, incluindo alteração e exclusão.
- Cancelar uma edição e tentar fechar durante uma edição.
- Excluir cliente com contatos; confirmar que ambos desapareceram.
- Fechar e reabrir para verificar os registros remanescentes.
- Conferir TabOrder e layout com a escala de tela utilizada pelo avaliador.

Entregue os `.dpr`, `.dproj`, `.pas`, `.dfm`, o banco e este README. A pasta
`testes` é apoio opcional para a análise. `.dcu`, `.dproj.local`, `.identcache`
e arquivos de histórico da IDE não são necessários para compilar os fontes.

## Referências de compatibilidade

- [Configuração de TSQLConnection e FailIfMissing](https://docwiki.embarcadero.com/RADStudio/Sydney/en/Setting_Up_TSQLConnection)
- [API StartTransaction](https://docwiki.embarcadero.com/Libraries/Sydney/en/Data.SqlExpr.TSQLConnection.StartTransaction)
- [Delphi 13 Community Edition](https://www.embarcadero.com/products/delphi/starter)

As assinaturas e o comportamento específicos do Delphi 13 também foram
conferidos nos fontes `Data.SqlExpr.pas`, `Data.DbxSqlite.pas` e
`System.DateUtils.pas` da instalação local, além dos testes de execução.
