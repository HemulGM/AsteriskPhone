unit Main.AsterLine.Update;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.jpeg;

type
  TFormUpdate = class(TForm)
    ProgressBar1: TProgressBar;
    ProgressBar2: TProgressBar;
    LabelDownFrom: TLabel;
    LabelDownTo: TLabel;
    LabelUpState: TLabel;
    ButtonStopUpdate: TButton;
    Label1: TLabel;
    ImageBG: TImage;
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormPaint(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormUpdate: TFormUpdate;

implementation

{$R *.dfm}

procedure TFormUpdate.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ReleaseCapture;
 Perform(WM_SysCommand, $F012, 0);
end;

procedure TFormUpdate.FormPaint(Sender: TObject);
begin
 Canvas.Pen.Color:=clWhite;
 Color:=clWhite;
 Canvas.Draw(0, 0, ImageBG.Picture.Graphic);
 Canvas.FrameRect(Canvas.ClipRect);
 Canvas.MoveTo(0, 50);
 Canvas.LineTo(ClientWidth, 50);
end;

end.
