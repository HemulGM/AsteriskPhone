unit OtherEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, acPNG;

type
  TFormOtherEdit = class(TForm)
    Label1: TLabel;
    EditCatalogFIO: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    EditCatalogEMail: TEdit;
    Label5: TLabel;
    EditCatalogNumLandline: TEdit;
    Label6: TLabel;
    EditCatalogNumIn: TEdit;
    Label7: TLabel;
    EditCatalogNumCell: TEdit;
    MemoComment: TMemo;
    Bevel1: TBevel;
    ButtonClose: TButton;
    ButtonOK: TButton;
    CheckBoxShare: TCheckBox;
    Image1: TImage;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    EditAddress: TEdit;
    EditPosition: TEdit;
    Label15: TLabel;
    Label16: TLabel;
    EditLand: TEdit;
    EditIn: TEdit;
    EditCell: TEdit;
    ButtonEditPostion: TButton;
    ButtonEditAdr: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure EditCatalogNumLandlineChange(Sender: TObject);
    procedure EditCatalogNumInChange(Sender: TObject);
    procedure EditCatalogNumCellChange(Sender: TObject);
    procedure ButtonEditPostionClick(Sender: TObject);
    procedure ButtonEditAdrClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormOtherEdit: TFormOtherEdit;

implementation
 uses Main, EditMemo;

{$R *.dfm}

procedure TFormOtherEdit.ButtonEditAdrClick(Sender: TObject);
begin
 FormMemo.SetData(EditAddress.Text);
 if FormMemo.ShowModal = mrOK then
  begin
   EditAddress.Text:=FormMemo.GetData;
  end;
end;

procedure TFormOtherEdit.ButtonEditPostionClick(Sender: TObject);
begin
 FormMemo.SetData(EditPosition.Text);
 if FormMemo.ShowModal = mrOK then
  begin
   EditPosition.Text:=FormMemo.GetData;
  end;
end;

procedure TFormOtherEdit.ButtonOKClick(Sender: TObject);
begin
 if Length(EditCatalogFIO.Text) < 3 then
  begin
   MessageBox(Application.Handle, 'Неверно заполнено поле "Полное имя". Имя должно иметь больше двух символов!', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 ModalResult:=mrOk;
end;

procedure TFormOtherEdit.EditCatalogNumCellChange(Sender: TObject);
begin
 EditCell.Text:=FieldToNumber(GetNumberOnly(EditCatalogNumCell.Text));
end;

procedure TFormOtherEdit.EditCatalogNumInChange(Sender: TObject);
begin
 EditIn.Text:=FieldToNumber(GetNumberOnly(EditCatalogNumIn.Text));
end;

procedure TFormOtherEdit.EditCatalogNumLandlineChange(Sender: TObject);
begin
 EditLand.Text:=FieldToNumber(GetNumberOnly(EditCatalogNumLandline.Text));
end;

procedure TFormOtherEdit.FormCreate(Sender: TObject);
begin
 ClientWidth:=570;
 ClientHeight:=510;
 Left:=Round(Screen.Width div 2 - Width div 2);
 Top:=Round(Screen.Height div 2 - Height div 2);
end;

end.
