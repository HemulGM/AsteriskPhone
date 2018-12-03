object FormMemo: TFormMemo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1085#1080#1077
  ClientHeight = 242
  ClientWidth = 342
  Color = clBtnFace
  Constraints.MinHeight = 259
  Constraints.MinWidth = 251
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object MemoData: TMemo
    Left = 0
    Top = 0
    Width = 342
    Height = 201
    Align = alClient
    BorderStyle = bsNone
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 201
    Width = 342
    Height = 41
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      342
      39)
    object ButtonCancel: TButton
      Left = 261
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #1054#1090#1084#1077#1085#1072
      TabOrder = 0
      OnClick = ButtonCancelClick
    end
    object ButtonOK: TButton
      Left = 180
      Top = 7
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = '&'#1054#1050
      ModalResult = 1
      TabOrder = 1
    end
  end
end
