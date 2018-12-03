unit DialUp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Main, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ImgList, acPNG, Vcl.Imaging.GIFImg, Vcl.Buttons, sSpeedButton,
  Vcl.ComCtrls, System.ImageList, Main.CommonFunc;

type
  TFormDialing = class(TForm)
    ImageList64: TImageList;
    LabelinSubject: TLabel;
    LabelinNumber: TLabel;
    LabelState: TLabel;
    SpeedButtonHangup: TsSpeedButton;
    SpeedButtonHome: TsSpeedButton;
    PanelDialupLeft: TPanel;
    ImageMan: TImage;
    ButtonPanelHide: TsSpeedButton;
    ImageDialing: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SpeedButtonHangupClick(Sender: TObject);
    procedure SpeedButtonHomeClick(Sender: TObject);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ButtonPanelHideClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure ShowDial;
  end;

var
  FormDialing: TFormDialing;


implementation

{$R *.dfm}

procedure TFormDialing.ShowDial;
begin
 Show;
end;

procedure TFormDialing.ButtonPanelHideClick(Sender: TObject);
begin
 Close;
end;

procedure TFormDialing.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 FormMain.Log('Action:=caHide;');
 Action:=caHide;
 Hide;
 Visible:=False;
 FormMain.Log('if FormMain.GlobalState <> gsIdle then FormMain.DialupShow(False);');
 if FormMain.GlobalState <> gsIdle then FormMain.DialupShow(False);
end;

procedure TFormDialing.FormCreate(Sender: TObject);
begin
 ClientWidth:=505;
 ClientHeight:=81;
 Left:=Screen.Width - Width - 40;
 Top:=Screen.Height - Height - 80;
 Caption:=AppDesc+' - звонок';
end;

procedure TFormDialing.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ReleaseCapture;
 Perform(WM_SYSCOMMAND, $F012, 0);
end;

procedure TFormDialing.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button = mbRight then FormMain.ShowNumbersForButton(FormMain.CID);
end;

procedure TFormDialing.FormShow(Sender: TObject);
begin
 Color:=FormMain.PanelMenu.Color;
 PanelDialupLeft.Color:=ColorLighter(Color, 30);
end;

procedure TFormDialing.SpeedButtonHangupClick(Sender: TObject);
begin
 FormMain.ButtonCallDownClick(Sender);
end;

procedure TFormDialing.SpeedButtonHomeClick(Sender: TObject);
begin
 FormMain.Show;
 Close;
end;

end.
