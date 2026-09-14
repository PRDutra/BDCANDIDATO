object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Cadastro de Clientes e Contatos'
  ClientHeight = 185
  ClientWidth = 480
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Segoe UI'
  Position = poScreenCenter
  object lblTitulo: TLabel
    Left = 32
    Top = 32
    Width = 400
    Height = 25
    AutoSize = False
    Caption = 'Cadastro de Clientes e Contatos'
  end
  object btnClientes: TButton
    Left = 32
    Top = 95
    Width = 230
    Height = 40
    Caption = 'Cadastro de clientes'
    TabOrder = 0
    OnClick = ClientesClick
  end
  object btnSair: TButton
    Left = 285
    Top = 95
    Width = 155
    Height = 40
    Caption = 'Sair'
    TabOrder = 1
    OnClick = SairClick
  end
end
