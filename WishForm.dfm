object FormWish: TFormWish
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = #1042#1072#1096#1080' '#1087#1086#1078#1077#1083#1072#1085#1080#1103' '#1080#1083#1080' '#1085#1072#1081#1076#1077#1085#1085#1099#1077' '#1086#1096#1080#1073#1082#1080
  ClientHeight = 307
  ClientWidth = 570
  Color = 16316664
  Constraints.MaxHeight = 346
  Constraints.MaxWidth = 586
  Constraints.MinHeight = 346
  Constraints.MinWidth = 586
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PrintScale = poNone
  Scaled = False
  DesignSize = (
    570
    307)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 32
    Top = 39
    Width = 65
    Height = 13
    Caption = #1055#1086#1083#1085#1086#1077' '#1080#1084#1103
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 5987163
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Bevel1: TBevel
    Left = -4
    Top = 257
    Width = 574
    Height = 9
    Anchors = [akLeft, akBottom]
    Shape = bsTopLine
    ExplicitTop = 460
  end
  object Label8: TLabel
    Left = 32
    Top = 132
    Width = 66
    Height = 26
    Caption = #1055#1086#1078#1077#1083#1072#1085#1080#1103' '#1080#1083#1080' '#1086#1096#1080#1073#1082#1080
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 5987163
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    WordWrap = True
  end
  object Label12: TLabel
    Left = 8
    Top = 8
    Width = 138
    Height = 15
    Caption = #1054#1090' '#1082#1086#1075#1086' ('#1085#1077' '#1086#1073#1103#1079#1072#1090#1077#1083#1100#1085#1086')'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 5987163
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label14: TLabel
    Left = 8
    Top = 105
    Width = 43
    Height = 15
    Caption = #1044#1072#1085#1085#1099#1077
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 5987163
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 32
    Top = 68
    Width = 32
    Height = 13
    Caption = #1054#1090#1076#1077#1083
    Font.Charset = DEFAULT_CHARSET
    Font.Color = 5987163
    Font.Height = -11
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
  end
  object EditFromFIO: TEdit
    Left = 146
    Top = 35
    Width = 391
    Height = 23
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 3
  end
  object MemoWish: TMemo
    Left = 146
    Top = 128
    Width = 391
    Height = 105
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 0
  end
  object ButtonClose: TButton
    Left = 482
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
  object ButtonOK: TButton
    Left = 401
    Top = 272
    Width = 75
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1043#1086#1090#1086#1074#1086
    TabOrder = 1
    OnClick = ButtonOKClick
  end
  object EditFromGroup: TEdit
    Left = 146
    Top = 64
    Width = 391
    Height = 23
    BevelEdges = []
    BevelInner = bvNone
    BevelOuter = bvNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 4
  end
end
