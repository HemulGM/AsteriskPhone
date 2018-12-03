object zvonok: Tzvonok
  Left = 270
  Top = 397
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'zvonok'
  ClientHeight = 57
  ClientWidth = 539
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 77
    Height = 13
    Caption = #1042#1072#1084' '#1079#1074#1086#1085#1086#1082' '#1086#1090':'
  end
  object name_caption: TLabel
    Left = 96
    Top = 8
    Width = 77
    Height = 13
    Caption = '###########'
  end
  object hangup: TSpeedButton
    Left = 352
    Top = 8
    Width = 121
    Height = 22
    Caption = #1055#1086#1083#1086#1078#1080#1090#1100' '#1090#1088#1091#1073#1082#1091
    OnClick = hangupClick
  end
  object SpeedButton2: TSpeedButton
    Left = 480
    Top = 8
    Width = 57
    Height = 33
    Caption = #1055#1077#1088#1077#1074#1086#1076
    OnClick = SpeedButton2Click
  end
  object num_caption: TLabel
    Left = 120
    Top = 32
    Width = 61
    Height = 13
    Caption = 'num_caption'
  end
  object num_sip: TLabel
    Left = 248
    Top = 32
    Width = 39
    Height = 13
    Caption = 'num_sip'
  end
  object num_cid: TLabel
    Left = 360
    Top = 40
    Width = 40
    Height = 13
    Caption = 'num_cid'
  end
end
