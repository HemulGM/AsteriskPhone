unit MessageEvent;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, acPNG, Vcl.ExtCtrls, Vcl.Buttons,
  sSpeedButton, Vcl.StdCtrls, Main;

type
  TFormMessage = class(TForm)
    LabelMessage: TLabel;
    LabelFIO: TLabel;
    SpeedButtonClose: TsSpeedButton;
    TimerClose: TTimer;
    PanelLeft: TPanel;
    Image1: TImage;
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonCloseClick(Sender: TObject);
    procedure TimerCloseTimer(Sender: TObject);
    procedure FormClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure FormClose;
    procedure FormUp;
  end;

var
  FormMessage: TFormMessage;
  NeedTop, NeedHide:Integer;

implementation

{$R *.dfm}

procedure TFormMessage.FormClick(Sender: TObject);
begin
 FormMain.ActionShowWindowExecute(nil);
 FormMain.ActionChatExecute(nil);
 FormClose;
end;

procedure TFormMessage.FormClose;
var TopP:Double;
    TopL:Double;
    Delta:Double;
begin
 TimerClose.Enabled:=False;

 TopP:=Top;
 TopL:=Top;
 Delta:=1.5;
 AlphaBlendValue:=255;
 while Top < NeedHide do
  begin
   TopP:=TopP + Delta;
   Delta:=Delta + 0.5;
   Top:=Round(TopP);
   AlphaBlendValue:=Round((255 / 100) * ((NeedHide - Top)/((NeedHide - TopL) / 100)));
   Sleep(10);
   Application.ProcessMessages;
  end;
 Top:=NeedHide;
 AlphaBlendValue:=0;

 Visible:=False;
end;

procedure TFormMessage.FormShow(Sender: TObject);
begin
 Top:=Screen.Height;
 Left:=Screen.Width - Width - 40;
 NeedTop:=Screen.Height - Height - 80;
 NeedHide:=Screen.Height;
 SetForegroundWindow(Handle);
end;

procedure TFormMessage.FormUp;
var TopP, TopL:Double;
    Delta:Double;
begin
 Visible:=True;
 TopP:=Top;
 TopL:=Top;
 Delta:=1.5;
 AlphaBlendValue:=0;
 while Top > NeedTop do
  begin
   TopP:=TopP - Delta;
   Delta:=Delta + 0.5;
   Top:=Round(TopP);
   AlphaBlendValue:=255 - Round((255 / 100) * ((NeedTop - Top)/((NeedTop - TopL) / 100)));
   Sleep(10);
   Application.ProcessMessages;
  end;
 AlphaBlendValue:=255;
 Top:=NeedTop;
 TimerClose.Enabled:=True;
end;

procedure TFormMessage.SpeedButtonCloseClick(Sender: TObject);
begin
 FormClose;
end;

procedure TFormMessage.TimerCloseTimer(Sender: TObject);
begin
 FormClose;
end;

end.
