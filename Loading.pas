unit Loading;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, sLabel,
  Vcl.Imaging.GIFImg, Vcl.ExtCtrls, acPNG, Vcl.ComCtrls;

type
  TFormLoading = class(TForm)
    sLabelFX1: TsLabelFX;
    ImageDialing: TImage;
    LabelState: TLabel;
    LabelVer: TLabel;
    ProgressBar: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private
    UpdateLog:TStringList;          //Лог обновления
    procedure ULog(Value:string);
  public
    class procedure SplashShow;
    class procedure SplashClose;
    procedure UpdateApp;
    procedure RunApp;
    procedure UpdateLoading(UpdateState:Integer);
  end;

var
  FormLoading: TFormLoading;
  aLink:string;
  procedure SetLoadState(str:string);

implementation
 uses Main, Main.CommonFunc;

{$R *.dfm}


procedure TFormLoading.ULog(Value:string);
begin
 UpdateLog.Insert(0, DateTimeToStr(Now)+': '+Value+' with _> "'+SysErrorMessage(GetLastError)+'"');
 if not DirectoryExists(ExtractFilePath(Application.ExeName)+'Logs') then CreateDir(ExtractFilePath(Application.ExeName)+'Logs');
 if DirectoryExists(ExtractFilePath(Application.ExeName)+'Logs') then
  begin
   try
    UpdateLog.SaveToFile(ExtractFilePath(Application.ExeName)+'Logs\'+LogName);
   except

   end;
  end;
end;

procedure TFormLoading.UpdateLoading(UpdateState:Integer);
begin
 if UpdateState > 0 then
  begin
   ProgressBar.Position:=UpdateState;
   ProgressBar.State:=pbsNormal;
   SetLoadState('Загрузка обновлений...');
  end
 else
  begin
   ProgressBar.Position:=1;
   ProgressBar.State:=pbsError;
   SetLoadState('Нет соединения');
  end
end;

procedure TFormLoading.RunApp;
begin
 WinExec(PAnsiChar(AnsiString(ExtractFilePath(Application.ExeName)+InternalExe)), SW_NORMAL);
end;

class procedure TFormLoading.SplashClose;
begin
 if Assigned(FormLoading) then FormLoading.Close;
end;

class procedure TFormLoading.SplashShow;
begin
 FormLoading:=TFormLoading.Create(nil);
 FormLoading.Repaint;
 FormLoading.Show;
 Application.ProcessMessages;
 SetLoadState('Запуск...');
end;

procedure TFormLoading.UpdateApp;
var TryInc:Integer;
begin
 LabelVer.Caption:='New';
 SetLoadState('Загрузка обновлений...');
 ULog('Начато обновление');
 ProgressBar.Show;
 Application.ProcessMessages;
 aLink:='';
 try
  aLink:=ParamStr(1);
 except
  begin
   aLink:='';
   ULog('except aLink:=ParamStr(1)');
  end;
 end;
 if aLink = '' then
  begin
   ULog('aLink = "", Exit');
   MessageBox(Application.Handle, 'В параметрах запуска не указана ссылка на файл обновлений!', 'Ошибка', MB_ICONERROR or MB_OK);
   Exit;
  end;

 StopUpdate:=False;
 TryInc:=1;
 while (not Application.Terminated) and (not StopUpdate) and (TryInc < 10) do
  begin
   SetLoadState('Загрузка. Попытка №'+IntToStr(TryInc));
   if FileExists(UpdateFile) then
    begin
     ULog('DeleteFile(UpdateFile) = '+IntToStr(Ord(DeleteFile(UpdateFile))));
    end;
   Application.ProcessMessages;
   ULog('GetInetFile(aLink, UpdateFile)');
   if GetInetFile(aLink, UpdateFile) then Break;
  end;

 Application.ProcessMessages;
 if StopUpdate then
  begin
   ULog('Обновление отменено, Exit');
   SetLoadState('Обновление отменено');
   ProgressBar.State:=pbsError;
   Application.ProcessMessages;
   Sleep(3000);
   Exit;
  end;

 if Application.Terminated then Exit;
 ULog('Закрытие конфликт. программ...');
 SetLoadState('Закрытие конфликт. программ...');
 WinExec(PAnsiChar(AnsiString('taskkill /f /im '+UpdateExe)), SW_HIDE);

 //Закрываем запущенные программы AsterLine
 ULog('Закрываем AsterLine...');
 SetLoadState('Закрываем AsterLine...');
 SendNotifyMessage(HWND_BROADCAST, WM_MSGCLOSE, 0, 0);
 //Подождём пока завершатся рабочие программы AsterLine.exe
 Sleep(3000);
 //Убиваем вручную, если что
 ULog('taskkill /f /im '+InternalExe);
 WinExec(PAnsiChar(AnsiString('taskkill /f /im '+InternalExe)), SW_HIDE);
 Sleep(2000);

 //Удаляем рабочий файл (тот, который заменяем)
 ULog('Обновление файлов... 1/3 DeleteFile(ExtractFilePath(Application.ExeName)+InternalExe)');
 SetLoadState('Обновление файлов... 1/3');
 if FileExists(ExtractFilePath(Application.ExeName)+InternalExe) then
  while not DeleteFile(ExtractFilePath(Application.ExeName)+InternalExe) do
   begin
    case MessageBox(Application.Handle, PChar('Не смог удалить файл "'#13#10+ExtractFilePath(Application.ExeName)+InternalExe+'"'#13#10'Повторить попытку?'), PWideChar(AppDesc+' - Внимание'), MB_ICONWARNING or MB_YESNOCANCEL) of
     ID_CANCEL:Exit;
     ID_NO:Break;
    end;
   end;
 ULog('Обновление файлов... 2/3 if FileExists(ExtractFilePath(Application.ExeName)+InternalExe) then Exit');
 SetLoadState('Обновление файлов... 2/3');
 if FileExists(ExtractFilePath(Application.ExeName)+InternalExe) then
  begin
   MessageBox(Application.Handle, 'Произошла ошибка при обновлении программы.'+#13#10+'Не смог удалить файл.', PWideChar(AppDesc+' - Внимание'), MB_ICONWARNING or MB_OK);
   Exit;
  end;
 ULog('Обновление файлов... 3/3 CopyFile(PWideChar(UpdateFile), PWideChar(ExtractFilePath(Application.ExeName)+InternalExe), True)');
 SetLoadState('Обновление файлов... 3/3');
 if not CopyFile(PWideChar(UpdateFile), PWideChar(ExtractFilePath(Application.ExeName)+InternalExe), True) then
  begin
   MessageBox(Application.Handle, 'Произошла ошибка при обновлении программы.'+#13#10+'Не смог скопировать файл.', PWideChar(AppDesc+' - Внимание'), MB_ICONWARNING or MB_OK);
   Exit;
  end;
 //Запускаем новую версию
 ULog('Создание ярлыка '+ExtractFilePath(Application.ExeName)+InternalExe);
 SetLoadState('Создание ярлыка');
 CreateShortcut(ExtractFilePath(Application.ExeName)+InternalExe);
end;

procedure SetLoadState(str:string);
begin
 if not Assigned(FormLoading) then Exit;
 FormLoading.LabelState.Caption:=str;
 FormLoading.Update;
 FormLoading.Refresh;
end;

procedure TFormLoading.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 StopUpdate:=True;
 CanClose:=True;
end;

procedure TFormLoading.FormCreate(Sender: TObject);
begin
 UpdateLog:=TStringList.Create;
 sLabelFX1.Caption:=AppDesc;
 LabelVer.Caption:=GetAppVersionStr;
 Color:=ColorDarker(GetAeroColor);
end;

procedure TFormLoading.FormPaint(Sender: TObject);
begin
 Canvas.Pen.Color:=ColorDarker(Color, 60);
 Canvas.Rectangle(0, 0, ClientWidth, ClientHeight);
end;

procedure TFormLoading.FormShow(Sender: TObject);
begin
 SetForegroundWindow(Handle);
end;

end.
