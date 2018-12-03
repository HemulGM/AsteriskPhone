unit EditMemo;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TFormMemo = class(TForm)
    MemoData: TMemo;
    PanelBottom: TPanel;
    ButtonCancel: TButton;
    ButtonOK: TButton;
    procedure ButtonCancelClick(Sender: TObject);
  private
    FOldData:string;
  public
    procedure SetData(Data:string);
    function GetData:string;
  end;

var
  FormMemo: TFormMemo;

implementation

{$R *.dfm}

procedure TFormMemo.ButtonCancelClick(Sender: TObject);
begin
 if MemoData.Text <> FOldData then
  begin
   if MessageBox(Application.Handle, 'Отменить изменения?', 'Вопрос', MB_ICONINFORMATION or MB_YESNO) <> ID_YES then Exit;
  end;
 ModalResult:=mrCancel;
end;

function TFormMemo.GetData: string;
begin
 Result:=MemoData.Text;
end;

procedure TFormMemo.SetData(Data: string);
begin
 FOldData:=Data;
 MemoData.Text:=Data;
end;

end.
