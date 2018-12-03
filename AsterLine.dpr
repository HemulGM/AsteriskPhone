program AsterLine;

uses
  Forms,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Dialogs,
  System.Win.ComObj,
  Main in 'Main.pas' {FormMain},
  Vcl.Themes,
  Vcl.Styles,
  Vcl.Imaging.GIFImg,
  DialUp in 'DialUp.pas' {FormDialing},
  About in 'About.pas' {FormAbout},
  Loading in 'Loading.pas' {FormLoading},
  IcoSelect in 'IcoSelect.pas' {FormIconSelect},
  Main.CommonFunc in '..\ToOffice\Main.CommonFunc.pas',
  Main.MD5 in '..\ToOffice\Main.MD5.pas',
  EditMemo in 'EditMemo.pas' {FormMemo},
  WishForm in 'WishForm.pas' {FormWish},
  MessageEvent in 'MessageEvent.pas' {FormMessage};

{$R *.res}

begin
  Version:=AppVersion(1, 77);
  Application.Initialize;
  Application.Title:=LinkApp;

  //Проверяем на уже запущенное приложение, елси что, открываем запущенное и сами выходим
  if not CheckAndCreateMutex('AsterLinePhoneForLKDU_HGM_2017', Mutex) then
   begin
    SendNotifyMessage(HWND_BROADCAST, WM_MSGSHOW, 0, 0);
    Halt(0);
   end;

  //Продолжаем запуск
  Application.HintHidePause:=5000;
  GIFImageDefaultAnimate:=True;
  Application.ShowMainForm:=False;

  //Проверка на автозагрузку
  FromAutorun:=(ParamStr(1) = '/autorun');
  if not FromAutorun then TFormLoading.SplashShow;

  //Создаём формы
  SetLoadState('Инициализация приложения...');
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormMemo, FormMemo);
  Application.CreateForm(TFormWish, FormWish);
  Application.CreateForm(TFormDialing, FormDialing);
  Application.CreateForm(TFormAbout, FormAbout);
  Application.CreateForm(TFormIconSelect, FormIconSelect);
  Application.CreateForm(TFormMessage, FormMessage);
  //Выполняем первую загрузку справочников
  FormMain.Init;
  Application.ShowMainForm:=not FromAutorun;
  TFormLoading.SplashClose;
  if not Initialized then
   begin
    MessageBox(Application.Handle, 'Загрузка программы завершена с ошибкой. Попробуйте запустить снова.', 'AsterLine. Ошибка', MB_ICONHAND or MB_OK);
    Halt(0);
   end;
  //Открываем приложение
  Application.Run;

  //После работы
  CloseHandle(Mutex);
end.

/////Изменения
///  0.1 - Базовый заклад. Альфа версия.
///  0.2 - Обновление интерфейса. Исправление мелочей. Доработка обновления.
///  0.5 - Исправление инициалов
///  0.8 - Обработана ситуация при запуске без доступа к сети.
///  1.23
///  1.41
