program BDCANDIDATO;

uses
  Vcl.Forms,
  Vcl.Dialogs,
  System.SysUtils,
  uPrincipal in 'uPrincipal.pas' {frmPrincipal},
  uDMConexao in 'uDMConexao.pas' {dmConexao: TDataModule},
  uCliente in 'uCliente.pas',
  uContato in 'uContato.pas',
  uIClienteController in 'uIClienteController.pas',
  uIContatoController in 'uIContatoController.pas',
  uClienteController in 'uClienteController.pas',
  uContatoController in 'uContatoController.pas',
  uClientes in 'uClientes.pas',
  uContatos in 'uContatos.pas',
  uUtils in 'uUtils.pas';

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Cadastro de Clientes e Contatos';
  try
    Application.CreateForm(TdmConexao, dmConexao);
    dmConexao.Conectar;
    Application.CreateForm(TfrmPrincipal, frmPrincipal);
    Application.Run;
  except
    on E: Exception do
    begin
      MessageDlg('Nao foi possivel iniciar a aplicacao.' + sLineBreak +
        E.Message + sLineBreak +
        'Verifique a permissao de escrita na pasta e a DLL sqlite3.dll Win32.',
        mtError, [mbOK], 0);
      ExitCode := 1;
    end;
  end;
end.
