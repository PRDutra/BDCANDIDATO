object frmClientes: TfrmClientes
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Clientes'
  ClientHeight = 560
  ClientWidth = 850
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  object lista: TListView
    Left = 16
    Top = 16
    Width = 818
    Height = 200
    Columns = <
      item
        Caption = 'ID'
        Width = 65
      end
      item
        Caption = 'Nome reduzido'
        Width = 240
      end
      item
        Caption = 'Razao social'
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
    Top = 230
    Width = 818
    Height = 252
    Caption = 'Dados do cliente'
    TabOrder = 1
    object lblNome: TLabel
      Left = 16
      Top = 24
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'Nome reduzido *'
    end
    object lblRazao: TLabel
      Left = 280
      Top = 24
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'Razao social *'
    end
    object edtNomeReduzido: TEdit
      Left = 16
      Top = 44
      Width = 245
      Height = 25
      MaxLength = 20
      TabOrder = 0
    end
    object edtRazaoSocial: TEdit
      Left = 280
      Top = 44
      Width = 515
      Height = 25
      MaxLength = 60
      TabOrder = 1
    end
    object lblNatureza: TLabel
      Left = 16
      Top = 84
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'Natureza juridica *'
    end
    object lblDocumento: TLabel
      Left = 280
      Top = 84
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'CPF / CNPJ *'
    end
    object lblNascimento: TLabel
      Left = 560
      Top = 84
      Width = 220
      Height = 17
      AutoSize = False
      Caption = 'Nascimento (opcional)'
    end
    object cmbNatureza: TComboBox
      Left = 16
      Top = 104
      Width = 245
      Height = 25
      Style = csDropDownList
      TabOrder = 2
      Items.Strings = (
        'F - Pessoa Fisica'
        'J - Pessoa Juridica')
      OnChange = NaturezaChange
    end
    object edtDocumento: TMaskEdit
      Left = 280
      Top = 104
      Width = 250
      Height = 25
      EditMask = '000.000.000-00;0;_'
      MaxLength = 14
      TabOrder = 3
    end
    object dtNascimento: TDateTimePicker
      Left = 560
      Top = 104
      Width = 235
      Height = 25
      Date = 46000.000000000000000000
      Time = 0.000000000000000000
      ShowCheckbox = True
      Checked = False
      Format = 'dd/MM/yyyy'
      TabOrder = 4
    end
    object lblCadastro: TLabel
      Left = 16
      Top = 160
      Width = 770
      Height = 20
      AutoSize = False
      Caption = 'Cadastro: automatico'
    end
  end
  object btnNovo: TButton
    Left = 16
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Novo'
    TabOrder = 2
    OnClick = AcaoClick
  end
  object btnAlterar: TButton
    Left = 119
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Alterar'
    TabOrder = 3
    OnClick = AcaoClick
  end
  object btnExcluir: TButton
    Left = 222
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Excluir'
    TabOrder = 4
    OnClick = AcaoClick
  end
  object btnSalvar: TButton
    Left = 325
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Salvar'
    TabOrder = 5
    OnClick = AcaoClick
  end
  object btnCancelar: TButton
    Left = 428
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Cancelar'
    TabOrder = 6
    OnClick = AcaoClick
  end
  object btnConsultar: TButton
    Left = 531
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Consultar'
    TabOrder = 7
    OnClick = AcaoClick
  end
  object btnContatos: TButton
    Left = 634
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Contatos'
    TabOrder = 8
    OnClick = AcaoClick
  end
  object btnFechar: TButton
    Left = 737
    Top = 500
    Width = 96
    Height = 32
    Caption = 'Fechar'
    TabOrder = 9
    OnClick = AcaoClick
  end
end
