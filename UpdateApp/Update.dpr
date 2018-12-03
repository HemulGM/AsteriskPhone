program Update;

uses
  Vcl.Forms,
  Main in '..\Main.pas' {FormMain},
  About in '..\About.pas' {FormAbout},
  CRC in '..\CRC.pas',
  DialUp in '..\DialUp.pas' {FormDialing},
  IcoSelect in '..\IcoSelect.pas' {FormIconSelect},
  Loading in '..\Loading.pas' {FormLoading},
  OtherEdit in '..\OtherEdit.pas' {FormOtherEdit},
  Settings in '..\Settings.pas' {FormSettings},
  Main.CommonFunc in '..\..\ToOffice\Main.CommonFunc.pas',
  Main.MD5 in '..\..\ToOffice\Main.MD5.pas',
  EditMemo in '..\EditMemo.pas' {FormMemo},
  WishForm in '..\WishForm.pas' {FormWish},
  MessageEvent in '..\MessageEvent.pas' {FormMessage};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar:= False;
  Application.CreateForm(TFormLoading, FormLoading);
  FormLoading.Show;
  FormLoading.UpdateApp;
  Application.Terminate;
  //Application.Run;
  FormLoading.RunApp;
end.

