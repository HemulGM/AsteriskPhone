object FormIconSelect: TFormIconSelect
  Left = 0
  Top = 0
  BorderIcons = []
  Caption = #1048#1082#1086#1085#1082#1072' '#1082#1086#1085#1090#1072#1082#1090#1072
  ClientHeight = 397
  ClientWidth = 502
  Color = clBtnFace
  Constraints.MaxHeight = 436
  Constraints.MaxWidth = 518
  Constraints.MinHeight = 436
  Constraints.MinWidth = 518
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object DrawGridIcons: TDrawGrid
    Left = 0
    Top = 0
    Width = 502
    Height = 358
    BorderStyle = bsNone
    ColCount = 19
    DefaultColWidth = 24
    FixedCols = 0
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goThumbTracking]
    ScrollBars = ssVertical
    TabOrder = 0
    OnDrawCell = DrawGridIconsDrawCell
    OnMouseWheelDown = DrawGridIconsMouseWheelDown
    OnMouseWheelUp = DrawGridIconsMouseWheelUp
    ColWidths = (
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24
      24)
    RowHeights = (
      24
      24
      24
      24
      24)
  end
  object Panel1: TPanel
    Left = 0
    Top = 357
    Width = 502
    Height = 40
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 1
    object ButtonNoIcon: TButton
      Left = 8
      Top = 7
      Width = 75
      Height = 25
      Caption = #1053#1077#1090' '#1080#1082#1086#1085#1082#1080
      ModalResult = 5
      TabOrder = 0
    end
    object ButtonOK: TButton
      Left = 338
      Top = 7
      Width = 75
      Height = 25
      Caption = #1054#1050
      ModalResult = 1
      TabOrder = 1
    end
    object ButtonCancel: TButton
      Left = 419
      Top = 7
      Width = 75
      Height = 25
      Caption = #1054#1090#1084#1077#1085#1072
      ModalResult = 2
      TabOrder = 2
    end
  end
end
