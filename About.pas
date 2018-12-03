unit About;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sLabel, acPNG,
  Vcl.ExtCtrls;

type
  TFormAbout = class(TForm)
    Image1: TImage;
    Image2: TImage;
    ButtonClose: TButton;
    ButtonChkUpdate: TButton;
    LabelDesc: TLabel;
    LabelVer: TLabel;
    sLabel2: TLabel;
    sLabel3: TLabel;
    procedure FormShow(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure ButtonChkUpdateClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  FormAbout: TFormAbout;

implementation
 uses Main;

{$R *.dfm}

procedure TFormAbout.ButtonChkUpdateClick(Sender: TObject);
begin
 if FormMain.CheckingVersion then
  begin
   MessageBox(Application.Handle, 'Проверка обновлений уже выполняется! Подождите.', '', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 Hide;
 Close;
 Update;
 Application.ProcessMessages;
 FormMain.CheckActualVersion(True);
end;

procedure TFormAbout.ButtonCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TFormAbout.FormCreate(Sender: TObject);
begin
 ClientHeight:=269;
 ClientWidth:=369;
end;

procedure TFormAbout.FormShow(Sender: TObject);
begin
 LabelDesc.Caption:=AppDesc;
 LabelVer.Caption:='Версия '+GetAppVersionStr;
 Left:=Round(Screen.Width div 2 - Width div 2);
 Top:=Round(Screen.Height div 2 - Height div 2);
end;

end.
