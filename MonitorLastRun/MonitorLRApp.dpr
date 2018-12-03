program MonitorLRApp;

uses
  Vcl.Forms,
  MonitorLR in 'MonitorLR.pas' {FormLRMon},
  Vcl.Themes,
  Vcl.Styles,
  Main.CommonFunc in '..\..\ToOffice\Main.CommonFunc.pas',
  Main.MD5 in '..\..\ToOffice\Main.MD5.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormLRMon, FormLRMon);
  Application.Run;
end.
