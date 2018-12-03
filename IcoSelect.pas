unit IcoSelect;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Grids;

type
  TFormIconSelect = class(TForm)
    DrawGridIcons: TDrawGrid;
    Panel1: TPanel;
    ButtonNoIcon: TButton;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure DrawGridIconsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawGridIconsMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridIconsMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  FormIconSelect: TFormIconSelect;
  Ico:TIcon;

  function SelectIcon(const Selected:Integer; var IconID:Integer):Boolean;

implementation
 uses Main, Math;

{$R *.dfm}

function SelectIcon(const Selected:Integer; var IconID:Integer):Boolean;
var ID:Integer;
begin
 Result:=False;
 with FormIconSelect do
  begin
   ID:=Selected;
   if ID >= 0 then
    begin
     try
      DrawGridIcons.Row:=ID div DrawGridIcons.ColCount;
      DrawGridIcons.Col:=ID mod DrawGridIcons.ColCount;
     except
      begin
       DrawGridIcons.Row:=0;
       DrawGridIcons.Col:=0;
      end;
     end;
    end
   else
    begin
     DrawGridIcons.Row:=0;
     DrawGridIcons.Col:=0;
    end;
   case ShowModal of
    mrIgnore: ID:=-1;
    mrOK:     ID:=DrawGridIcons.Row * DrawGridIcons.ColCount + DrawGridIcons.Col;
   else
    Exit;
   end;
   if ID = IconID then Exit;
   IconID:=ID;
   Result:=True;
  end;
end;

procedure TFormIconSelect.DrawGridIconsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var ID:Integer;
begin
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol;
 if (ARow = DrawGridIcons.Row) and (ACol = DrawGridIcons.Col) then
  DrawGridIcons.Canvas.Brush.Color:=$00E8C36F;
 DrawGridIcons.Canvas.FillRect(Rect);
 if (ID >= 0) and (ID < FormMain.ImageListMans.Count) then
  begin
   FormMain.ImageListMans.GetIcon(ID, Ico);
   DrawGridIcons.Canvas.Draw(Rect.Left + (Rect.Width div 2 - Ico.Width div 2), Rect.Top + (Rect.Height div 2 - Ico.Height div 2), Ico);
  end;
end;

procedure TFormIconSelect.DrawGridIconsMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 (Sender as TDrawGrid).Perform(WM_VSCROLL, SB_LINEDOWN, 0);
end;

procedure TFormIconSelect.DrawGridIconsMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 (Sender as TDrawGrid).Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TFormIconSelect.FormCreate(Sender: TObject);
begin
 ClientHeight:=417;
 ClientWidth:=521;
 Ico:=TIcon.Create;
 DrawGridIcons.RowCount:=Ceil(FormMain.ImageListMans.Count / DrawGridIcons.ColCount);
end;

procedure TFormIconSelect.FormShow(Sender: TObject);
begin
 DrawGridIcons.Show;
end;

end.
