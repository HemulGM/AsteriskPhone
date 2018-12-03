unit settings;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,IniFiles;

type
  TForm2 = class(TForm)
    number_edit: TEdit;
    context_edit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    btn_1: TEdit;
    btn_tel_1: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    btn_tel_2: TEdit;
    btn_2: TEdit;
    Label6: TLabel;
    btn_tel_3: TEdit;
    btn_3: TEdit;
    Label7: TLabel;
    btn_tel_4: TEdit;
    btn_4: TEdit;
    Label8: TLabel;
    btn_tel_5: TEdit;
    btn_5: TEdit;
    Label9: TLabel;
    btn_tel_6: TEdit;
    btn_6: TEdit;
    Label10: TLabel;
    btn_tel_7: TEdit;
    btn_7: TEdit;
    Label11: TLabel;
    btn_tel_8: TEdit;
    btn_8: TEdit;
    Label12: TLabel;
    btn_tel_10: TEdit;
    btn_10: TEdit;
    Label13: TLabel;
    btn_tel_9: TEdit;
    btn_9: TEdit;
    Label14: TLabel;
    btn_tel_12: TEdit;
    btn_12: TEdit;
    Label15: TLabel;
    btn_tel_11: TEdit;
    btn_11: TEdit;
    Label16: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

uses Main;

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
var
   fini: TIniFile;
   i:integer;
   btn_text:array[1..12]of TEdit;
   btn_nomer:array[1..12]of TEdit;

begin
   fini := TIniFile.Create(ExtractFilePath(Application.ExeName)+
           'init.ini');
           for i:=1 to 12 do begin
            btn_text[i]:= Form2.FindComponent('btn_'+inttostr(i)) as TEdit;
            btn_nomer[i]:= Form2.FindComponent('btn_tel_'+inttostr(i)) as TEdit;
            btn_text[i].Text := fini.ReadString('Button','btn_'+inttostr(i),'');
            btn_nomer[i].Text := fini.ReadString('Button','btn_tel_'+inttostr(i),'');
           end;
            number_edit.Text := fini.ReadString('NUM','number','');

   fini.Free;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
var
   fini: TIniFile;
   i:integer;
   btn_text:array[1..12]of TEdit;
   btn_nomer:array[1..12]of TEdit;

begin
   fini := TIniFile.Create(ExtractFilePath(Application.ExeName)+
           'init.ini');
           for i:=1 to 12 do begin
            btn_text[i]:= Form2.FindComponent('btn_'+inttostr(i)) as TEdit;
            btn_nomer[i]:= Form2.FindComponent('btn_tel_'+inttostr(i)) as TEdit;


   fini.WriteString('Button','btn_'+inttostr(i), btn_text[i].Text);
   fini.WriteString('Button','btn_tel_'+inttostr(i),btn_nomer[i].Text);
     end;

    fini.WriteString('NUM','number',number_edit.Text);
   fini.Free;


end;

end.
