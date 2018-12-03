program astermi;

uses
  Forms,
  aster in 'aster.pas' {Form1},
  settings in 'settings.pas' {Form2},
  zvon_form in 'zvon_form.pas' {zvonok};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'ИТ Телефон ';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(Tzvonok, zvonok);
  Application.Run;
end.
