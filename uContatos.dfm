object frmContatos: TfrmContatos
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Contatos'
  ClientHeight = 445
  ClientWidth = 850
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  TextHeight = 15
  object lblCliente: TLabel
    Left = 16
    Top = 12
    Width = 800
    Height = 20
    AutoSize = False
    Caption = 'Cliente'
  end
  object lista: TListView
    Left = 16
    Top = 40
    Width = 818
    Height = 200
    Columns = <
      item
        Caption = 'ID'
        Width = 65
      end
      item
        Caption = 'Nome'
        Width = 240
      end
      item
        Caption = 'Email'
        Width = 475
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnSelectItem = ListaSelectItem
  end
  object painelEdicao: TGroupBox
    Left = 16
    Top = 254
    Width = 818
    Height = 115
    Caption = 'Dados do contato'
    TabOrder = 1
    object lblNome: TLabel
      Left = 16
      Top = 24
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'Nome *'
    end
    object lblEmail: TLabel
      Left = 400
      Top = 24
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'Email'
    end
    object edtNome: TEdit
      Left = 16
      Top = 44
      Width = 365
      Height = 25
      MaxLength = 60
      TabOrder = 0
    end
    object edtEmail: TEdit
      Left = 400
      Top = 44
      Width = 395
      Height = 25
      MaxLength = 90
      TabOrder = 1
    end
  end
  object btnNovo: TButton
    Left = 16
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Novo'
    TabOrder = 2
    OnClick = AcaoClick
  end
  object btnAlterar: TButton
    Left = 119
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Alterar'
    TabOrder = 3
    OnClick = AcaoClick
  end
  object btnExcluir: TButton
    Left = 222
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Excluir'
    TabOrder = 4
    OnClick = AcaoClick
  end
  object btnSalvar: TButton
    Left = 325
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Salvar'
    TabOrder = 5
    OnClick = AcaoClick
  end
  object btnCancelar: TButton
    Left = 428
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Cancelar'
    TabOrder = 6
    OnClick = AcaoClick
  end
  object btnConsultar: TButton
    Left = 531
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Consultar'
    TabOrder = 7
    OnClick = AcaoClick
  end
  object btnFechar: TButton
    Left = 634
    Top = 390
    Width = 96
    Height = 32
    Caption = 'Fechar'
    TabOrder = 8
    OnClick = AcaoClick
  end
end
