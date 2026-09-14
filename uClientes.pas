unit uClientes;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, Vcl.ExtCtrls,
  uCliente, uIClienteController;

type
  TfrmClientes = class(TForm)
    lblNome: TLabel;
    lblRazao: TLabel;
    lblNatureza: TLabel;
    lblDocumento: TLabel;
    lblNascimento: TLabel;
    lista: TListView;
    painelEdicao: TGroupBox;
    btnNovo: TButton;
    btnAlterar: TButton;
    btnExcluir: TButton;
    btnSalvar: TButton;
    btnCancelar: TButton;
    btnConsultar: TButton;
    btnFechar: TButton;
    edtNomeReduzido: TEdit;
    edtRazaoSocial: TEdit;
    cmbNatureza: TComboBox;
    edtDocumento: TMaskEdit;
    dtNascimento: TDateTimePicker;
    lblCadastro: TLabel;
    btnContatos: TButton;
    procedure NaturezaChange(ASender: TObject);
    procedure AcaoClick(ASender: TObject);
    procedure ListaSelectItem(ASender: TObject; AItem: TListItem; ASelected: Boolean);
    procedure FormCloseQuery(ASender: TObject; var ACanClose: Boolean);
  private
    FController: IClienteController;
    FItens: TObjectList<TCliente>;
    FEditando: Boolean;
    FId: Int64;
    function Selecionado: TCliente;
    procedure Atualizar;
    procedure Exibir;
    procedure AtualizarCamposNatJuridica;
    procedure Estado(AEditando: Boolean);
    procedure Salvar;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Inicializar(const AController: IClienteController);
  end;

implementation

uses Vcl.Dialogs, uUtils, uContatos, uContatoController, uDMConexao;

{$R *.dfm}

constructor TfrmClientes.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Estado(False);
end;

destructor TfrmClientes.Destroy;
begin
  lista.OnSelectItem := nil;
  lista.Items.Clear;
  FItens.Free;
  FController := nil;
  inherited;
end;

procedure TfrmClientes.Inicializar(const AController: IClienteController);
begin
  FController := AController;
  Atualizar;
end;

function TfrmClientes.Selecionado: TCliente;
begin
  Result := nil;
  if Assigned(lista.Selected) then
    Result := TCliente(lista.Selected.Data);
end;

procedure TfrmClientes.Atualizar;
var
  Novos: TObjectList<TCliente>;
  C: TCliente;
  Item: TListItem;
begin
  Novos := FController.Consultar;
  lista.Items.BeginUpdate;
  try
    lista.Items.Clear;
    FreeAndNil(FItens);
    FItens := Novos;
    for C in FItens do
    begin
      Item := lista.Items.Add;
      Item.Caption := IntToStr(C.IdCliente);
      Item.SubItems.Add(C.NomeReduzido);
      Item.SubItems.Add(C.RazaoSocial);
      Item.Data := C;
    end;
    if lista.Items.Count > 0 then
      lista.Items[0].Selected := True;
  finally
    lista.Items.EndUpdate;
  end;
  Exibir;
  Estado(False);
end;

procedure TfrmClientes.Estado(AEditando: Boolean);
begin
  FEditando := AEditando;
  painelEdicao.Enabled := AEditando;
  lista.Enabled := not AEditando;
  btnNovo.Enabled := not AEditando;
  btnConsultar.Enabled := not AEditando;
  btnAlterar.Enabled := not AEditando and (Selecionado <> nil);
  btnExcluir.Enabled := btnAlterar.Enabled;
  btnContatos.Enabled := btnAlterar.Enabled;
  btnSalvar.Enabled := AEditando;
  btnCancelar.Enabled := AEditando;
end;

procedure TfrmClientes.ListaSelectItem(ASender: TObject; AItem: TListItem; ASelected: Boolean);
begin
  if not FEditando then
  begin
    Exibir;
    Estado(False);
  end;
end;

procedure TfrmClientes.Exibir;
var
  C: TCliente;
begin
  C := Selecionado;
  FId := 0;
  edtNomeReduzido.Clear;
  edtRazaoSocial.Clear;
  cmbNatureza.ItemIndex := 0;
  edtDocumento.Clear;
  dtNascimento.Date := Date;
  dtNascimento.Checked := False;
  lblCadastro.Caption := 'Cadastro: automatico';
  if Assigned(C) then
  begin
    FId := C.IdCliente;
    edtNomeReduzido.Text := C.NomeReduzido;
    edtRazaoSocial.Text := C.RazaoSocial;
    if C.NatJuridica = 'J' then
      cmbNatureza.ItemIndex := 1;
    if C.DtNascimento <> 0 then
      dtNascimento.Date := C.DtNascimento;
    dtNascimento.Checked := C.DtNascimento <> 0;
    lblCadastro.Caption := 'Cadastro: ' + DateTimeToStr(C.DtTmCadastro);
  end;
  AtualizarCamposNatJuridica;
  if Assigned(C) then
    edtDocumento.Text := C.CPFCNPJ;
end;

procedure TfrmClientes.NaturezaChange(ASender: TObject);
begin
  AtualizarCamposNatJuridica;
end;

procedure TfrmClientes.AtualizarCamposNatJuridica;
var
  bPessoaJuridica: Boolean;
begin
  // Razao social pertence ao cadastro de pessoa juridica.
  bPessoaJuridica := cmbNatureza.ItemIndex = 1;
  edtRazaoSocial.Enabled := bPessoaJuridica;
  lblRazao.Enabled := bPessoaJuridica;
  if not bPessoaJuridica then
    edtRazaoSocial.Clear;

  edtDocumento.Text := '';
  if cmbNatureza.ItemIndex = 0 then
    edtDocumento.EditMask := '000.000.000-00;0;_'
  else
    edtDocumento.EditMask := '00.000.000/0000-00;0;_';
end;

procedure TfrmClientes.Salvar;
var
  C: TCliente;
begin
  C := TCliente.Create;
  try
    C.IdCliente := FId;
    C.NomeReduzido := edtNomeReduzido.Text;
    C.RazaoSocial := edtRazaoSocial.Text;
    if cmbNatureza.ItemIndex = 0 then
      C.NatJuridica := 'F'
    else if cmbNatureza.ItemIndex = 1 then
      C.NatJuridica := 'J';
    C.CPFCNPJ := edtDocumento.Text;
    if dtNascimento.Checked then
      C.DtNascimento := Trunc(dtNascimento.Date);
    if FId = 0 then
      FController.Inserir(C)
    else
      FController.Alterar(C);
  finally
    C.Free;
  end;
  // Commit concluido: sair da edicao antes de atualizar a consulta.
  Estado(False);
  Atualizar;
end;

procedure TfrmClientes.AcaoClick(ASender: TObject);
var
  Tela: TfrmContatos;
begin
  try
    if ASender = btnFechar then
      Close
    else if ASender = btnConsultar then
      Atualizar
    else if ASender = btnNovo then
    begin
      lista.Selected := nil;
      Exibir;
      Estado(True);
      edtNomeReduzido.SetFocus;
    end
    else if ASender = btnAlterar then
    begin
      Exigir((Selecionado <> nil), 'Selecione um registro.');
      Exibir;
      Estado(True);
      edtNomeReduzido.SetFocus;
    end
    else if ASender = btnCancelar then
    begin
      Estado(False);
      Exibir;
    end
    else if ASender = btnSalvar then
      Salvar
    else if ASender = btnExcluir then
    begin
      Exigir((Selecionado <> nil), 'Selecione um registro.');
      if MessageDlg('Excluir este cliente e todos os seus contatos?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        FController.Excluir(Selecionado.IdCliente);
        Atualizar;
      end;
    end
    else if ASender = btnContatos then
    begin
      Exigir((Selecionado <> nil), 'Selecione um cliente.');
      Tela := TfrmContatos.Create(Self);
      try
        Tela.Inicializar(TContatoController.Create(dmConexao),
          Selecionado.IdCliente, Selecionado.NomeReduzido);
        Tela.ShowModal;
      finally
        Tela.Free;
      end;
    end;
  except
    on E: Exception do
      MessageDlg('Nao foi possivel concluir a operacao.' + sLineBreak +
        E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmClientes.FormCloseQuery(ASender: TObject; var ACanClose: Boolean);
begin
  ACanClose := not FEditando;
  if FEditando then
    ACanClose := MessageDlg('Descartar as alteracoes nao salvas?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

end.
