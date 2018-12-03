unit WishForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormWish = class(TForm)
    Label1: TLabel;
    Bevel1: TBevel;
    Label8: TLabel;
    Label12: TLabel;
    Label14: TLabel;
    EditFromFIO: TEdit;
    MemoWish: TMemo;
    ButtonClose: TButton;
    ButtonOK: TButton;
    Label2: TLabel;
    EditFromGroup: TEdit;
    procedure ButtonOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormWish: TFormWish;

implementation

{$R *.dfm}

procedure TFormWish.ButtonOKClick(Sender: TObject);
begin
 if Length(MemoWish.Text) < 3 then
  begin
   MessageBox(Application.Handle, 'Неверно заполнено поле "Пожелания". Имя должно иметь больше двух символов!', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 ModalResult:=mrOk;
end;

end.
