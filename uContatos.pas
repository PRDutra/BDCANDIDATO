unit uContatos;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Mask, Vcl.ExtCtrls,
  uContato, uIContatoController;

type
  TfrmContatos = class(TForm)
    lblNome: TLabel;
    lblEmail: TLabel;
    lista: TListView;
    painelEdicao: TGroupBox;
    btnNovo: TButton;
    btnAlterar: TButton;
    btnExcluir: TButton;
    btnSalvar: TButton;
    btnCancelar: TButton;
    btnConsultar: TButton;
    btnFechar: TButton;
    edtNome: TEdit;
    edtEmail: TEdit;
    lblCliente: TLabel;
    procedure AcaoClick(ASender: TObject);
    procedure ListaSelectItem(ASender: TObject; AItem: TListItem; ASelected: Boolean);
    procedure FormCloseQuery(ASender: TObject; var ACanClose: Boolean);
  private
    FController: IContatoController;
    FItens: TObjectList<TContato>;
    FEditando: Boolean;
    FId: Int64;
    FIdCliente: Int64;
    function Selecionado: TContato;
    procedure Atualizar;
    procedure Exibir;
    procedure Estado(AEditando: Boolean);
    procedure Salvar;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Inicializar(const AController: IContatoController; AIdCliente: Int64; const ANomeCliente: string);
  end;

implementation

uses Vcl.Dialogs, uUtils;

{$R *.dfm}

constructor TfrmContatos.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Estado(False);
end;

destructor TfrmContatos.Destroy;
begin
  lista.OnSelectItem := nil;
  lista.Items.Clear;
  FItens.Free;
  FController := nil;
  inherited;
end;

procedure TfrmContatos.Inicializar(const AController: IContatoController; AIdCliente: Int64; const ANomeCliente: string);
begin
  FController := AController;
  ValidarId(AIdCliente, 'IdCliente');
  FIdCliente := AIdCliente;
  lblCliente.Caption := 'Cliente: ' + IntToStr(AIdCliente) + ' - ' + ANomeCliente;
  Atualizar;
end;

function TfrmContatos.Selecionado: TContato;
begin
  Result := nil;
  if Assigned(lista.Selected) then
    Result := TContato(lista.Selected.Data);
end;

procedure TfrmContatos.Atualizar;
var
  Novos: TObjectList<TContato>;
  C: TContato;
  Item: TListItem;
begin
  Novos := FController.ConsultarPorCliente(FIdCliente);
  lista.Items.BeginUpdate;
  try
    lista.Items.Clear;
    FreeAndNil(FItens);
    FItens := Novos;
    for C in FItens do
    begin
      Item := lista.Items.Add;
      Item.Caption := IntToStr(C.IdContato);
      Item.SubItems.Add(C.Nome);
      Item.SubItems.Add(C.Email);
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

procedure TfrmContatos.Estado(AEditando: Boolean);
begin
  FEditando := AEditando;
  painelEdicao.Enabled := AEditando;
  lista.Enabled := not AEditando;
  btnNovo.Enabled := not AEditando;
  btnConsultar.Enabled := not AEditando;
  btnAlterar.Enabled := not AEditando and (Selecionado <> nil);
  btnExcluir.Enabled := btnAlterar.Enabled;
  btnSalvar.Enabled := AEditando;
  btnCancelar.Enabled := AEditando;
end;

procedure TfrmContatos.ListaSelectItem(ASender: TObject; AItem: TListItem; ASelected: Boolean);
begin
  if not FEditando then
  begin
    Exibir;
    Estado(False);
  end;
end;

procedure TfrmContatos.Exibir;
var
  C: TContato;
begin
  C := Selecionado;
  FId := 0;
  edtNome.Clear;
  edtEmail.Clear;
  if Assigned(C) then
  begin
    FId := C.IdContato;
    edtNome.Text := C.Nome;
    edtEmail.Text := C.Email;
  end;
end;

procedure TfrmContatos.Salvar;
var
  C: TContato;
begin
  C := TContato.Create;
  try
    C.IdContato := FId;
    C.IdCliente := FIdCliente;
    C.Nome := edtNome.Text;
    C.Email := edtEmail.Text;
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

procedure TfrmContatos.AcaoClick(ASender: TObject);
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
      edtNome.SetFocus;
    end
    else if ASender = btnAlterar then
    begin
      Exigir((Selecionado <> nil), 'Selecione um registro.');
      Exibir;
      Estado(True);
      edtNome.SetFocus;
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
      if MessageDlg('Excluir este contato?',
        mtConfirmation, [mbYes, mbNo], 0) = mrYes then
      begin
        FController.Excluir(Selecionado.IdContato, FIdCliente);
        Atualizar;
      end;
    end;
  except
    on E: Exception do
      MessageDlg('Nao foi possivel concluir a operacao.' + sLineBreak +
        E.Message, mtError, [mbOK], 0);
  end;
end;

procedure TfrmContatos.FormCloseQuery(ASender: TObject; var ACanClose: Boolean);
begin
  ACanClose := not FEditando;
  if FEditando then
    ACanClose := MessageDlg('Descartar as alteracoes nao salvas?',
      mtConfirmation, [mbYes, mbNo], 0) = mrYes;
end;

end.
