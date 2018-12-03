unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sButton, Vcl.Mask,
  sMaskEdit, sCustomComboEdit, sToolEdit, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdMultipartFormData;

type
  TFormMain = class(TForm)
    IdHTTP1: TIdHTTP;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

function GetFileSize(FileName:string):Integer;
var FS:TFileStream;
begin
 try
  FS:=TFileStream.Create(Filename, fmOpenRead);
 except
  Result:= -1;
 end;
 if Result <> -1 then Result:=FS.Size;
 FS.Free;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var Stream:TIdMultipartFormDataStream;
    s:string;
begin
 Stream:= TIdMultipartFormDataStream.Create;
 if (GetFileSize(ParamStr(1)) / 1024 / 1024) > 20 then
  begin
   ShowMessage('Размер файла превышает 20 мб.');
   Application.Terminate;
  end;
 try
  Stream.AddFile('userfile', ParamStr(1), ''); //http://soft.comul.int/files/AsterLine.exe   //http://192.168.0.206/lkdusoft/files/
  s:=IdHTTP1.Post('http://soft.comul.int/upload.php', Stream);
  ShowMessage(s);
 finally
  Stream.Free;
 end;
 Application.Terminate;
end;

end.
