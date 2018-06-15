object frmEditor: TfrmEditor
  Left = 520
  Top = 292
  BorderStyle = bsDialog
  Caption = #1056#1077#1076#1072#1082#1090#1086#1088' '#1082#1086#1084#1072#1085#1076' Multiclip'
  ClientHeight = 442
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  ShowHint = True
  PixelsPerInch = 96
  TextHeight = 13
  object gpbHeader: TGroupBox
    Left = 8
    Top = 8
    Width = 609
    Height = 113
    Caption = ' '#1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1089#1087#1080#1089#1082#1072' '
    TabOrder = 0
    object spbChooseTargetWindow: TSpeedButton
      Left = 576
      Top = 16
      Width = 25
      Height = 25
      Caption = '...'
      OnClick = spbChooseTargetWindowClick
    end
    object lbeOpenKey: TLabeledEdit
      Left = 128
      Top = 48
      Width = 161
      Height = 21
      EditLabel.Width = 114
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1090#1082#1088#1099#1090#1100' '#1086#1089#1085#1086#1074#1085#1086#1081' '#1095#1072#1090
      LabelPosition = lpLeft
      LabelSpacing = 6
      TabOrder = 1
      OnChange = lbeHotKeyChange
    end
    object lbeSendKey: TLabeledEdit
      Left = 296
      Top = 48
      Width = 161
      Height = 21
      EditLabel.Width = 133
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1074' '#1086#1089#1085#1086#1074#1085#1086#1081' '#1095#1072#1090
      LabelPosition = lpRight
      LabelSpacing = 10
      TabOrder = 2
      OnChange = lbeHotKeyChange
    end
    object lbeAltOpenKey: TLabeledEdit
      Left = 168
      Top = 80
      Width = 121
      Height = 21
      EditLabel.Width = 150
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1090#1082#1088#1099#1090#1100' '#1072#1083#1100#1090#1077#1088#1085#1072#1090#1080#1074#1085#1099#1081' '#1095#1072#1090
      LabelPosition = lpLeft
      LabelSpacing = 10
      TabOrder = 3
      OnChange = lbeHotKeyChange
    end
    object lbeAltSendKey: TLabeledEdit
      Left = 296
      Top = 80
      Width = 121
      Height = 21
      EditLabel.Width = 169
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1090#1087#1088#1072#1074#1080#1090#1100' '#1074' '#1072#1083#1100#1090#1077#1088#1085#1072#1090#1080#1074#1085#1099#1081' '#1095#1072#1090
      LabelPosition = lpRight
      LabelSpacing = 13
      TabOrder = 4
      OnChange = lbeHotKeyChange
    end
    object lbeTargetWindowName: TLabeledEdit
      Left = 144
      Top = 16
      Width = 425
      Height = 21
      EditLabel.Width = 131
      EditLabel.Height = 13
      EditLabel.Caption = #1047#1072#1075#1086#1083#1086#1074#1086#1082' '#1094#1077#1083#1077#1074#1086#1075#1086' '#1086#1082#1085#1072
      LabelPosition = lpLeft
      LabelSpacing = 6
      TabOrder = 0
    end
  end
  object btnOK: TButton
    Left = 232
    Top = 408
    Width = 73
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 320
    Top = 408
    Width = 73
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 7
  end
  object ltvCommands: TListView
    Left = 8
    Top = 128
    Width = 417
    Height = 273
    Checkboxes = True
    Columns = <
      item
        Caption = #1050#1086#1084#1072#1085#1076#1072
        Width = 150
      end
      item
        Caption = #1054#1089#1085#1086#1074#1085#1086#1081' '#1095#1072#1090
        Width = 120
      end
      item
        Caption = #1040#1083#1100#1090#1077#1088#1085#1072#1090#1080#1074#1085#1099#1081' '#1095#1072#1090
        Width = 120
      end>
    GridLines = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnEdited = ltvCommandsEdited
    OnSelectItem = ltvCommandsSelectItem
  end
  object gpbCommand: TGroupBox
    Left = 432
    Top = 128
    Width = 185
    Height = 225
    Caption = ' '#1055#1072#1088#1072#1084#1077#1090#1088#1099' '#1082#1086#1084#1072#1085#1076#1099' '
    TabOrder = 2
    object ckbDelay: TCheckBox
      Left = 8
      Top = 24
      Width = 161
      Height = 17
      Caption = #1047#1072#1076#1077#1088#1078#1082#1072' '#1087#1077#1088#1077#1076' '#1086#1090#1087#1088#1072#1074#1082#1086#1081
      TabOrder = 0
    end
    object lbeText: TLabeledEdit
      Left = 8
      Top = 64
      Width = 169
      Height = 21
      EditLabel.Width = 30
      EditLabel.Height = 13
      EditLabel.Caption = #1058#1077#1082#1089#1090
      TabOrder = 1
    end
    object lbeHotKey: TLabeledEdit
      Left = 8
      Top = 104
      Width = 169
      Height = 21
      EditLabel.Width = 69
      EditLabel.Height = 13
      EditLabel.Caption = #1054#1089#1085#1086#1074#1085#1086#1081' '#1095#1072#1090
      TabOrder = 2
      OnChange = lbeHotKeyChange
    end
    object lbeAltHotKey: TLabeledEdit
      Left = 8
      Top = 144
      Width = 169
      Height = 21
      EditLabel.Width = 104
      EditLabel.Height = 13
      EditLabel.Caption = #1040#1083#1100#1090#1077#1088#1085#1072#1090#1080#1074#1085#1099#1081' '#1095#1072#1090
      TabOrder = 3
      OnChange = lbeHotKeyChange
    end
    object btnCommit: TButton
      Left = 8
      Top = 176
      Width = 81
      Height = 41
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      TabOrder = 4
      OnClick = btnCommitClick
    end
    object btnRollback: TButton
      Left = 96
      Top = 176
      Width = 81
      Height = 41
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      TabOrder = 5
      OnClick = btnRollbackClick
    end
  end
  object btnInsert: TButton
    Left = 432
    Top = 360
    Width = 57
    Height = 41
    Caption = #1042#1089#1090#1072#1074#1080#1090#1100
    TabOrder = 3
    OnClick = btnInsertClick
  end
  object btnAppend: TButton
    Left = 496
    Top = 360
    Width = 57
    Height = 41
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 4
    OnClick = btnAppendClick
  end
  object btnDelete: TButton
    Left = 560
    Top = 360
    Width = 57
    Height = 41
    Caption = #1059#1076#1072#1083#1080#1090#1100
    TabOrder = 5
    OnClick = btnDeleteClick
  end
  object tmrCatchWindow: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrCatchWindowTimer
    Left = 72
    Top = 160
  end
end
