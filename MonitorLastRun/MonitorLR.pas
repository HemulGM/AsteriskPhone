unit MonitorLR;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.ExtCtrls, Data.Win.ADODB,
  Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls, Vcl.ComCtrls, System.ImageList, IdMultipartFormData,
  Vcl.ImgList, Vcl.Buttons, sSpeedButton, sPanel, Main.CommonFunc, System.Generics.Collections,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, System.IniFiles, IdCharsets, IdGlobal,
  IdIOHandler, TableDraw;

type
  {
  LR_ID	int	Unchecked
  LR_AppName	varchar(100)	Checked
  LR_UserName	varchar(100)	Checked
  LR_MachineName	varchar(100)	Checked
  LR_LastRun	datetime	Checked
  LR_AppVersion	varchar(100)	Checked
  }

  TTableData<T> = class(TList<T>)
   private
    FTable:TTableEx;
    FUpdateCount:Integer;
   public
    constructor Create(AOwner: TTableEx); virtual;
    function Add(Value:T):Integer; virtual;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear; virtual;
    procedure Delete(Index:Integer); virtual;
    procedure UpdateTable; virtual;
    property Table:TTableEx read FTable;
  end;

  TIni = record
   private
    function GetAppFile: string;
    procedure SetAppFile(const Value: string);
    function GetAppCrit: string;
    function GetAppDesc: string;
    function GetAppLink: string;
    function GetAppName: string;
    function GetAppVers: string;
    procedure SetAppCrit(const Value: string);
    procedure SetAppDesc(const Value: string);
    procedure SetAppLink(const Value: string);
    procedure SetAppName(const Value: string);
    procedure SetAppVers(const Value: string);
   public
    property AppFile:string read GetAppFile write SetAppFile;
    property AppName:string read GetAppName write SetAppName;
    property AppVers:string read GetAppVers write SetAppVers;
    property AppDesc:string read GetAppDesc write SetAppDesc;
    property AppLink:string read GetAppLink write SetAppLink;
    property AppCrit:string read GetAppCrit write SetAppCrit;
  end;

  TLRRecord = record
   private
    FLR_ID: Integer;
    FLR_LastRun: TDateTime;
    FLR_UserName: string;
    FLR_AppVersion: string;
    FLR_AppName: string;
    FLR_MachineName: string;
    procedure SetLR_AppName(const Value: string);
    procedure SetLR_AppVersion(const Value: string);
    procedure SetLR_ID(const Value: Integer);
    procedure SetLR_LastRun(const Value: TDateTime);
    procedure SetLR_MachineName(const Value: string);
    procedure SetLR_UserName(const Value: string);
   public
    property LR_ID:Integer read FLR_ID write SetLR_ID;
    property LR_AppName:string read FLR_AppName write SetLR_AppName;
    property LR_UserName:string read FLR_UserName write SetLR_UserName;
    property LR_MachineName:string read FLR_MachineName write SetLR_MachineName;
    property LR_LastRun:TDateTime read FLR_LastRun write SetLR_LastRun;
    property LR_AppVersion:string read FLR_AppVersion write SetLR_AppVersion;
  end;
  TLastRunList = TTableData<TLRRecord>;

  {
  AW_ID	int	Unchecked
  AW_APP	varchar(50)	Checked
  AW_FROM	varchar(100)	Checked
  AW_FROMGROUP	varchar(100)	Checked
  AW_WISH	varchar(500)	Checked
  AW_DATE	datetime	Checked
  AW_TAKE	int	Checked
  }

  TAWRecord = record
   private
    FAW_FROMGROUP: string;
    FAW_FROM: string;
    FAW_ID: Integer;
    FAW_TAKE: Boolean;
    FAW_WISH: string;
    FAW_APP: string;
    FAW_DATE: TDateTime;
    procedure SetAW_APP(const Value: string);
    procedure SetAW_DATE(const Value: TDateTime);
    procedure SetAW_FROM(const Value: string);
    procedure SetAW_FROMGROUP(const Value: string);
    procedure SetAW_ID(const Value: Integer);
    procedure SetAW_TAKE(const Value: Boolean);
    procedure SetAW_WISH(const Value: string);
   public
    property AW_ID:Integer read FAW_ID write SetAW_ID;
    property AW_APP:string read FAW_APP write SetAW_APP;
    property AW_FROM:string read FAW_FROM write SetAW_FROM;
    property AW_FROMGROUP:string read FAW_FROMGROUP write SetAW_FROMGROUP;
    property AW_WISH:string read FAW_WISH write SetAW_WISH;
    property AW_DATE:TDateTime read FAW_DATE write SetAW_DATE;
    property AW_TAKE:Boolean read FAW_TAKE write SetAW_TAKE;
  end;
  TWishList = TTableData<TAWRecord>;

  TFormLRMon = class(TForm)
    ADOConnection: TADOConnection;
    TimerUpdate: TTimer;
    TrayIcon: TTrayIcon;
    ImageList16: TImageList;
    PanelMenu: TsPanel;
    SpeedButtonMenu: TsSpeedButton;
    SpeedButtonReload: TsSpeedButton;
    SpeedButtonAbout: TsSpeedButton;
    SpeedButtonQuit: TsSpeedButton;
    SpeedButtonSettings: TsSpeedButton;
    SpeedButtonSilence: TsSpeedButton;
    SpeedButtonUsers: TsSpeedButton;
    SpeedButtonLog: TsSpeedButton;
    SpeedButtonSep: TsSpeedButton;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    SpeedButtonWishes: TsSpeedButton;
    ImageList24: TImageList;
    PanelClient: TPanel;
    PageControlMain: TPageControl;
    TabSheetLastRun: TTabSheet;
    Panel3: TPanel;
    Panel4: TPanel;
    ListBoxLog: TListBox;
    TabSheetWish: TTabSheet;
    Panel5: TPanel;
    Panel1: TPanel;
    LabelCount: TLabel;
    Bevel1: TBevel;
    Panel2: TPanel;
    LabelCountWish: TLabel;
    Bevel2: TBevel;
    ButtonCheck: TButton;
    TabSheetNewVer: TTabSheet;
    Panel6: TPanel;
    ImageAppIco: TImage;
    LabelAppName: TLabel;
    LabelAppPath: TLabel;
    Panel7: TPanel;
    SpeedButtonOpen: TsSpeedButton;
    SpeedButtonUpdSave: TsSpeedButton;
    Panel8: TPanel;
    EditAppDBName: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    EditVers: TEdit;
    Label4: TLabel;
    EditAppUpdDesc: TEdit;
    EditAppLink: TEdit;
    Label5: TLabel;
    CheckBoxAppCrit: TCheckBox;
    Panel9: TPanel;
    SpeedButtonGetDBData: TsSpeedButton;
    sSpeedButton3: TsSpeedButton;
    SpeedButtonNew: TsSpeedButton;
    IdHTTP1: TIdHTTP;
    OpenDialogFile: TOpenDialog;
    SpeedButtonCert: TsSpeedButton;
    TableExUsers: TTableEx;
    TableExWishes: TTableEx;
    procedure TimerUpdateTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ButtonCheckClick(Sender: TObject);
    procedure SpeedButtonQuitClick(Sender: TObject);
    procedure SpeedButtonMenuClick(Sender: TObject);
    procedure SpeedButtonSilenceClick(Sender: TObject);
    procedure SpeedButtonUsersClick(Sender: TObject);
    procedure SpeedButtonWishesClick(Sender: TObject);
    procedure SpeedButtonReloadClick(Sender: TObject);
    procedure DrawGridWishesDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure SpeedButtonNewClick(Sender: TObject);
    procedure sSpeedButton3Click(Sender: TObject);
    procedure SpeedButtonOpenClick(Sender: TObject);
    procedure SpeedButtonUpdSaveClick(Sender: TObject);
    procedure SpeedButtonCertClick(Sender: TObject);
    procedure SpeedButtonGetDBDataClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure TableExUsersGetData(FCol, FRow: Integer; var Value: string);
    procedure TableExWishesGetData(FCol, FRow: Integer; var Value: string);
  private
    FSilence: Boolean;
    FLastRunList:TLastRunList;
    FWishList:TWishList;
    procedure SetMenuPanelColor(aColor: TColor);
    procedure SetMenuIconColor(aColor: TColor);
    procedure PanelMenuState(Minimazed: Boolean);
    procedure SetSilence(const Value: Boolean);
    procedure CreateTables;
    { Private declarations }
  public
    Ini:TIni;
    procedure Check;
    procedure Log(Text:string);
    property Silence:Boolean read FSilence write SetSilence;
    property LastRunList:TLastRunList read FLastRunList write FLastRunList;
    property WishList:TWishList read FWishList write FWishList;
  end;

var
  FormLRMon: TFormLRMon;
  CheckIng:Boolean = False;
  OldCount:Integer = -1;
  OldCountWish:Integer = -1;
  TableWishColumns:array[0..5] of string = ('ID', 'Дата записи', 'Отдел', 'От кого', 'Пожелание/Ошибка', 'Отметка');

implementation
 uses Math;

{$R *.dfm}

{ TTableData<T> }

function TTableData<T>.Add(Value: T): Integer;
begin
 Result:=inherited Add(Value);
 UpdateTable;
end;

procedure TTableData<T>.BeginUpdate;
begin
 Inc(FUpdateCount);
 if FUpdateCount <= 0  then FUpdateCount:=1;
end;

procedure TTableData<T>.Clear;
begin
 inherited Clear;
 UpdateTable;
end;

constructor TTableData<T>.Create(AOwner: TTableEx);
begin
 inherited Create;
 FUpdateCount:=0;
 FTable:=AOwner;
end;

procedure TTableData<T>.Delete(Index: Integer);
begin
 inherited Delete(Index);
 UpdateTable;
end;

procedure TTableData<T>.EndUpdate;
begin
 Dec(FUpdateCount);
 if FUpdateCount < 0 then FUpdateCount:=0;
 if FUpdateCount = 0 then UpdateTable;
end;

procedure TTableData<T>.UpdateTable;
begin
 if FUpdateCount > 0 then Exit;
 if not Assigned(FTable) then Exit;
 FTable.ItemCount:=Count;
 FTable.Repaint;
end;

{ TFormMain }

function IniRead(Section, Ident, Default:string):string;
var IniF:TIniFile;
begin
 IniF:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'data.inf');
 Result:=IniF.ReadString(Section, Ident, '');
 IniF.Free;
end;

procedure IniWrite(Section, Ident, Value:string);
var IniF:TIniFile;
begin
 IniF:=TIniFile.Create(ExtractFilePath(Application.ExeName)+'data.inf');
 IniF.WriteString(Section, Ident, Value);
 IniF.Free;
end;

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

procedure TFormLRMon.ButtonCheckClick(Sender: TObject);
var ID:Integer;
    ADOQ:TADOQuery;
begin
 if WishList.Count <= 0 then Exit;
 if not IndexInList(TableExWishes.ItemIndex, TList(WishList)) then Exit;
 ID:=WishList[TableExWishes.ItemIndex].AW_ID;
 ADOQ:=TADOQuery.Create(nil);
 ADOQ.Connection:=ADOConnection;
 ADOQ.ExecuteOptions:=[eoExecuteNoRecords];
 ADOQ.SQL.Text:='UPDATE AppWish SET [AW_TAKE] = 1 WHERE AW_ID = '+QuotedStr(IntToStr(ID));
 try
  ADOQ.ExecSQL();
  Log('Уведомление '+IntToStr(ID)+' - учтено');
  Check;
 except
  ShowMessage('Ошибка!');
 end;
 ADOQ.Free;
end;

procedure TFormLRMon.Check;
var ID:Integer;
    Query:TADOQuery;
    Item:TLRRecord;
    ItemW:TAWRecord;
    RunQuery:Boolean;
begin
 try
  if not ADOConnection.Connected then ADOConnection.Open;
 except
  begin
   Log('Ошибка подключения');
   Exit;
  end;
 end;
 if not ADOConnection.Connected then Exit;

 Query:=TADOQuery.Create(nil);
 Query.Connection:=ADOConnection;
          {

 Query.ExecuteOptions:=[];
 Query.SQL.Text:='SELECT COUNT(LR_ID) FROM AppLR';
 RunQuery:=False;
 try
  Query.Open;
  if Query.RecordCount > 0 then
   if LastRunList.Count <> Query.Fields[0].AsInteger then RunQuery:=True;
  Query.Close;
 except
  begin
   Query.Free;
   ADOConnection.Close;
   Log('Ошибка подключения');
   Exit;
  end;
 end;    }

 //Пользователи
 RunQuery:=True;
 if RunQuery then
  begin
   //Log('Запрос пользователей...');
   Query.ExecuteOptions:=[];
   Query.SQL.Text:=
    'SELECT LR_ID, LR_AppName, LR_UserName, LR_MachineName, LR_LastRun, '+
    ' (CASE WHEN '''+EditVers.Text+''' = LR_AppVersion '+
    ' THEN ''Новая'' ELSE LR_AppVersion END) AS LR_AppVersion FROM AppLR WHERE LR_AppName = ''AsteriskPhone'''+
    ' ORDER BY LR_LastRun';
   try
    Query.Open;
    //if Query.RecordCount <> LastRunList.Count then
     begin
      LastRunList.BeginUpdate;
      LastRunList.Clear;
      while not Query.Eof do
       begin
        Item.LR_ID:=Query.Fields[0].AsInteger;
        Item.LR_AppName:=Query.Fields[1].AsString;
        Item.LR_UserName:=Query.Fields[2].AsString;
        Item.LR_MachineName:=Query.Fields[3].AsString;
        Item.LR_LastRun:=Query.Fields[4].AsDateTime;
        Item.LR_AppVersion:=Query.Fields[5].AsString;
        LastRunList.Add(Item);
        Query.Next;
       end;
      LastRunList.EndUpdate;
      if (OldCount < LastRunList.Count) and (OldCount <> -1) then
       begin
        if not Silence then
         begin
          TrayIcon.BalloonHint:='Пополнение в рядах AsterLine, теперь нас '+IntToStr(LastRunList.Count);
          TrayIcon.BalloonTitle:='У нас новый пользователь';
          TrayIcon.BalloonFlags:=bfInfo;
          TrayIcon.ShowBalloonHint;
         end;
        Log('Новый пользователь, всего: '+IntToStr(OldCount));
       end;
      OldCount:=LastRunList.Count;
      LabelCount.Caption:='Всего: '+IntToStr(OldCount);
     end;
   except
    begin
     Log('Ошибка при запросе пользователей');
     Query.Free;
     ADOConnection.Close;
     Exit;
    end;
   end;
   //Log('Запрос пользователей выполнен');
  end;

 //Пожелания/Ошибки
 Query.ExecuteOptions:=[];
 Query.SQL.Text:='SELECT COUNT(AW_ID) FROM AppWish';
 RunQuery:=True;
 if RunQuery then
  begin
   Log('Запрос пожеланий...');
   Query.ExecuteOptions:=[];
   Query.SQL.Text:=
    'SELECT AW_ID, AW_FROM, AW_FROMGROUP, AW_WISH, AW_DATE, '+
    ' IsNULL(AW_TAKE, 0) AS AW_TAKE, AW_APP FROM AppWish WHERE AW_APP = ''AsteriskPhone'' ORDER BY AW_DATE';
   try
    Query.Open;
   // if Query.RecordCount <> WishList.Count then
     begin
      WishList.BeginUpdate;
      WishList.Clear;
      while not Query.Eof do
       begin
        ItemW.AW_ID:=Query.Fields[0].AsInteger;
        ItemW.AW_FROM:=Query.Fields[1].AsString;
        ItemW.AW_FROMGROUP:=Query.Fields[2].AsString;
        ItemW.AW_WISH:=Query.Fields[3].AsString;
        ItemW.AW_DATE:=Query.Fields[4].AsDateTime;
        ItemW.AW_TAKE:=Boolean(Query.Fields[5].AsInteger);
        ItemW.AW_APP:=Query.Fields[5].AsString;
        WishList.Add(ItemW);
        Query.Next;
       end;
      WishList.EndUpdate;
      if (OldCountWish < WishList.Count) and (OldCountWish <> -1) then
       begin
        if not Silence then
         begin
          TrayIcon.BalloonHint:='Новое пожелание или ошибка';
          TrayIcon.BalloonTitle:='Уведомление';
          TrayIcon.BalloonFlags:=bfWarning;
          TrayIcon.ShowBalloonHint;
         end;
        Log('Новое пожелание или найденная ошибка');
       end;
      OldCountWish:=WishList.Count;
      LabelCountWish.Caption:='Всего: '+IntToStr(OldCountWish);
     end;
   except
    begin
     Log('Ошибка при запросе пожеланий');
     Query.Free;
     ADOConnection.Close;
     Exit;
    end;
   end;
   Log('Запрос пожеланий выполнен');
  end;

 Query.Free;
end;

procedure TFormLRMon.DrawGridWishesDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var str:string;
begin
 with (Sender as TDrawGrid).Canvas do
  begin
   if ARow = 0 then
    begin
     str:=TableWishColumns[ACol];
     TextOut(Rect.Left + 3, Rect.Top + (Rect.Height div 2 - TextHeight(str) div 2), str);
     Exit;
    end;
   if ARow-1 > WishList.Count - 1 then Exit;
   case ACol of
    0:str:=IntToStr(WishList[ARow - 1].AW_ID);
    1:str:=FormatDateTime('c', WishList[ARow - 1].AW_DATE);
    2:str:=WishList[ARow - 1].AW_FROMGROUP;
    3:str:=WishList[ARow - 1].AW_FROM;
    4:str:=WishList[ARow - 1].AW_WISH;
    5:if WishList[ARow - 1].AW_TAKE then str:='Учтено' else str:='';
   else str:='';
   end;
   TextOut(Rect.Left + 3, Rect.Top + (Rect.Height div 2 - TextHeight(str) div 2), str);
  end;
end;

procedure TFormLRMon.SetMenuPanelColor(aColor:TColor);
var i:Integer;
begin
 PanelMenu.Color:=aColor;
 for i:=0 to PanelMenu.ControlCount - 1 do
  begin
   if PanelMenu.Controls[i] is TShape then
    begin
     (PanelMenu.Controls[i] as TShape).Pen.Color:=ColorDarker(aColor, 10);
     (PanelMenu.Controls[i] as TShape).Brush.Color:=ColorDarker(aColor, 10);
    end;
   if PanelMenu.Controls[i] is TsSpeedButton then
    begin
     (PanelMenu.Controls[i] as TsSpeedButton).Font.Color:=$00E6E6E6;
    end;
  end;
end;

procedure TFormLRMon.SetSilence(const Value: Boolean);
begin
 FSilence:=Value;
 if FSilence then SpeedButtonSilence.ImageIndex:=15 else SpeedButtonSilence.ImageIndex:=16;
end;

procedure TFormLRMon.SetMenuIconColor(aColor:TColor);
var i:Integer;
begin
 for i:= 0 to ImageList24.Count - 1 do ColorImages(ImageList24, i, aColor);
end;

procedure TFormLRMon.FormClose(Sender: TObject; var Action: TCloseAction);
begin
// SpeedButtonUpdSaveClick(nil);
end;

procedure TFormLRMon.CreateTables;
begin
 //'ID', 'Версия', 'Имя компьютера', 'Пользователь', 'Последняя сессия'
 with TableExUsers do
  begin
   with Columns[0] do
    begin
     Caption:='ID';
     Width:=50;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Версия';
     Width:=80;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Имя компьютера';
     Width:=100;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Пользователь';
     Width:=120;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Последняя сессия';
     Width:=140;
    end;
  end;
 //'ID', 'Дата записи', 'Отдел', 'От кого', 'Пожелание/Ошибка', 'Отметка'
 with TableExWishes do
  begin
   with Columns[0] do
    begin
     Caption:='ID';
     Width:=40;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Отметка';
     Width:=50;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Дата записи';
     Width:=140;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Отдел';
     Width:=100;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='От кого';
     Width:=200;
    end;
   with Columns[AddColumn] do
    begin
     Caption:='Пожелание/Ошибка';
     Width:=200;
    end;
  end;
end;

procedure TFormLRMon.FormCreate(Sender: TObject);
begin
 CreateTables;
 SetMenuPanelColor(ColorDarker(GetAeroColor));
 SetMenuIconColor(ColorLighter(GetAeroColor));
 IdHTTP1.IOHandler:=TIdIOHandler.MakeDefaultIOHandler(IdHTTP1);
 IdHTTP1.IOHandler.DefStringEncoding:=enUTF8;
 FLastRunList:=TLastRunList.Create(TableExUsers);
 FLastRunList.UpdateTable;
 FWishList:=TWishList.Create(TableExWishes);
 FWishList.UpdateTable;
 Silence:=False;
 SpeedButtonGetDBDataClick(nil);
 TimerUpdateTimer(nil);
 TimerUpdate.Enabled:=True;
end;

procedure TFormLRMon.Log(Text: string);
begin
 ListBoxLog.Items.Insert(0, Text);
 Application.ProcessMessages;
end;

procedure TFormLRMon.PanelMenuState(Minimazed:Boolean);
begin
 if Minimazed then PanelMenu.Width:=40 else PanelMenu.Width:=250;
end;

procedure TFormLRMon.SpeedButtonSilenceClick(Sender: TObject);
begin
 Silence:=not Silence;
end;

procedure TFormLRMon.SpeedButtonMenuClick(Sender: TObject);
begin
 PanelMenuState(PanelMenu.Width >= 250);
end;

procedure TFormLRMon.SpeedButtonNewClick(Sender: TObject);
begin
 PageControlMain.ActivePage:=TabSheetNewVer;
end;

procedure TFormLRMon.SpeedButtonOpenClick(Sender: TObject);
begin
 if OpenDialogFile.Execute(Handle) then LabelAppPath.Caption:=OpenDialogFile.FileName;
end;

procedure TFormLRMon.SpeedButtonQuitClick(Sender: TObject);
begin
 Close;
end;

procedure TFormLRMon.SpeedButtonReloadClick(Sender: TObject);
begin
 Log('Инициация обновления');
 Check;
end;

procedure TFormLRMon.SpeedButtonUsersClick(Sender: TObject);
begin
 PageControlMain.ActivePage:=TabSheetLastRun;
end;

procedure TFormLRMon.SpeedButtonWishesClick(Sender: TObject);
begin
 PageControlMain.ActivePage:=TabSheetWish;
end;

procedure TFormLRMon.SpeedButtonUpdSaveClick(Sender: TObject);
begin
 Ini.AppFile:=LabelAppPath.Caption;
 Ini.AppName:=EditAppDBName.Text;
 Ini.AppVers:=EditVers.Text;
 Ini.AppDesc:=EditAppUpdDesc.Text;
 Ini.AppLink:=EditAppLink.Text;
 Ini.AppCrit:=IntToStr(Ord(CheckBoxAppCrit.Checked));
 Log('Данные о версии сохранены');
end;

procedure TFormLRMon.SpeedButtonCertClick(Sender: TObject);
begin
 WinExec(PAnsiChar(AnsiString(ExtractFilePath(Application.ExeName)+'cert.bat')), SW_NORMAL);
end;

procedure TFormLRMon.SpeedButtonGetDBDataClick(Sender: TObject);
var Stream:TIdMultipartFormDataStream;
    s:string;
    PostData:TStringList;
    IdHTTP:TIdHTTP;
begin
 LabelAppPath.Caption:=Ini.AppFile;
 EditAppDBName.Text:=Ini.AppName;

 Stream:= TIdMultipartFormDataStream.Create;
 IdHTTP:=TIdHTTP.Create(nil);
 IdHTTP.Request.UserAgent:='UPDATESOFTLKDU';
 try
  Stream.AddFormField('Act', 'GetData');
  Stream.AddFormField('FileName', EditAppDBName.Text);
  IdHTTP.HTTPOptions:=IdHTTP.HTTPOptions + [hoNoProtocolErrorException];
  PostData:=TStringList.Create;
  PostData.Text:=IdHTTP.Post('http://soft.comul.int/upload.php', Stream);

  if PostData.Count <= 0 then s:='FAILED' else s:=PostData[0];
  Log('Результат загрузки: "'+s+'"');
  if PostData.Count > 1 then
   begin
    EditVers.Text:=PostData[3];
    EditAppLink.Text:=PostData[4];
    EditAppUpdDesc.Text:=PostData[5];
    CheckBoxAppCrit.Checked:=PostData[6] = '1';
   end;
 finally
  begin
   Stream.Free;
   PostData.Free;
   IdHTTP.Free;
  end;
 end;
end;

procedure TFormLRMon.sSpeedButton3Click(Sender: TObject);
var Stream:TIdMultipartFormDataStream;
    s, fn:string;
    PostData:TStringList;
var Query:TADOQuery;
begin
 fn:=LabelAppPath.Caption;
 if fn.Length > 3 then
  begin
   fn:=Copy(fn, 1, fn.Length-3)+'upd';
  end;
 if not FileExists(fn) then
  begin
   Log('Выберите файл!');
   Exit;
  end;
 Stream:= TIdMultipartFormDataStream.Create;
 if (GetFileSize(fn) / 1024 / 1024) > 20 then
  begin
   Log('Размер файла превышает 20 мб.');
  end;
 try
  Log('Загрузка файла и данных о версии на сервер...');
  Application.ProcessMessages;
  Stream.AddFile('userfile', fn, ''); //http://soft.comul.int/files/AsterLine.exe   //http://192.168.0.206/lkdusoft/files/
  Stream.AddFormField('Act', 'SetData');
  Stream.AddFormField('FileName', EditAppDBName.Text);
  Stream.AddFormField('Version', EditVers.Text);
  //Stream.AddFormField('Desc', EditAppUpdDesc.Text);
  Stream.AddFormField('Desc', UTF8Encode(EditAppUpdDesc.Text), 'utf-8').ContentTransfer:='8bit';
  Stream.AddFormField('Link', EditAppLink.Text);
  Stream.AddFormField('Crit', IntToStr(Ord(CheckBoxAppCrit.Checked)));
  PostData:=TStringList.Create;
  PostData.Text:=IdHTTP1.Post('http://soft.comul.int/upload.php', Stream);
  if PostData.Count <= 0 then s:='FAILED' else s:=PostData[0];
  Log('Результат загрузки: "'+s+'"');
 finally
  begin
   PostData.Free;
   Stream.Free;
  end;
 end;
 if s = 'OK' then
  begin
   Log('Обновление загружено');
   SpeedButtonUpdSaveClick(nil);
  end
 else Log('Обновление НЕ загружено!');
end;

procedure TFormLRMon.TableExUsersGetData(FCol, FRow: Integer; var Value: string);
begin
 Value:='';
 if LastRunList.Count = 0 then
  begin
   Value:='';
   if FCol = 0 then Value:='Пусто';
   Exit;
  end;
 if not IndexInList(FRow, TList(LastRunList)) then Exit;

 case FCol of
  0:Value:=IntToStr(FRow + 1);
  1:Value:=LastRunList[FRow].LR_AppVersion;
  2:Value:=LastRunList[FRow].LR_MachineName;
  3:Value:=LastRunList[FRow].LR_UserName;
  4:begin
      Value:='';
      if DateToStr(Now) = DateToStr(LastRunList[FRow].LR_LastRun) then Value:='Сегодня в '+FormatDateTime('HH:MM', LastRunList[FRow].LR_LastRun)
      else
       if DateToStr(Now-1) = DateToStr(LastRunList[FRow].LR_LastRun) then Value:='Вчера в '+FormatDateTime('HH:MM', LastRunList[FRow].LR_LastRun)
       else
        if DateToStr(Now-2) = DateToStr(LastRunList[FRow].LR_LastRun) then Value:='Позавчера в '+FormatDateTime('HH:MM', LastRunList[FRow].LR_LastRun)
        else Value:=FormatDateTime('DD.MM.YYYY в HH:MM', LastRunList[FRow].LR_LastRun);
     end;
 end;
end;

procedure TFormLRMon.TableExWishesGetData(FCol, FRow: Integer; var Value: string);
begin
 Value:='';
 if LastRunList.Count = 0 then
  begin
   Value:='';
   if FCol = 0 then Value:='Пусто';
   Exit;
  end;
 if not IndexInList(FRow, TList(LastRunList)) then Exit;

 case FCol of
  0:Value:=IntToStr(FRow + 1);
  1:if WishList[FRow].AW_TAKE then Value:='Учтено' else Value:='';
  2:Value:=FormatDateTime('c', WishList[FRow].AW_DATE);
  3:Value:=WishList[FRow].AW_FROMGROUP;
  4:Value:=WishList[FRow].AW_FROM;
  5:Value:=WishList[FRow].AW_WISH;
 end;
end;

procedure TFormLRMon.TimerUpdateTimer(Sender: TObject);
begin
 if CheckIng then Exit;
 CheckIng:=True;
 Check;
 CheckIng:=False;
end;

{ TLRRecord }

procedure TLRRecord.SetLR_AppName(const Value: string);
begin
 FLR_AppName:= Value;
end;

procedure TLRRecord.SetLR_AppVersion(const Value: string);
begin
 FLR_AppVersion:= Value;
end;

procedure TLRRecord.SetLR_ID(const Value: Integer);
begin
 FLR_ID:= Value;
end;

procedure TLRRecord.SetLR_LastRun(const Value: TDateTime);
begin
 FLR_LastRun:= Value;
end;

procedure TLRRecord.SetLR_MachineName(const Value: string);
begin
 FLR_MachineName:= Value;
end;

procedure TLRRecord.SetLR_UserName(const Value: string);
begin
 FLR_UserName:= Value;
end;

{ TAWRecord }

procedure TAWRecord.SetAW_APP(const Value: string);
begin
  FAW_APP := Value;
end;

procedure TAWRecord.SetAW_DATE(const Value: TDateTime);
begin
  FAW_DATE := Value;
end;

procedure TAWRecord.SetAW_FROM(const Value: string);
begin
  FAW_FROM := Value;
end;

procedure TAWRecord.SetAW_FROMGROUP(const Value: string);
begin
  FAW_FROMGROUP := Value;
end;

procedure TAWRecord.SetAW_ID(const Value: Integer);
begin
  FAW_ID := Value;
end;

procedure TAWRecord.SetAW_TAKE(const Value: Boolean);
begin
  FAW_TAKE := Value;
end;

procedure TAWRecord.SetAW_WISH(const Value: string);
begin
  FAW_WISH := Value;
end;

{ TIni }

function TIni.GetAppCrit: string;
begin
 Result:=IniRead('Main', 'AppCrit', '');
end;

function TIni.GetAppDesc: string;
begin
 Result:=IniRead('Main', 'AppDesc', '');
end;

function TIni.GetAppFile: string;
begin
 Result:=IniRead('Main', 'AppFile', '');
end;

function TIni.GetAppLink: string;
begin
 Result:=IniRead('Main', 'AppLink', '');
end;

function TIni.GetAppName: string;
begin
 Result:=IniRead('Main', 'AppName', '');
end;

function TIni.GetAppVers: string;
begin
 Result:=IniRead('Main', 'AppVers', '');
end;

procedure TIni.SetAppCrit(const Value: string);
begin
 IniWrite('Main', 'AppCrit', Value);
end;

procedure TIni.SetAppDesc(const Value: string);
begin
 IniWrite('Main', 'AppDesc', Value);
end;

procedure TIni.SetAppFile(const Value: string);
begin
 IniWrite('Main', 'AppFile', Value);
end;

procedure TIni.SetAppLink(const Value: string);
begin
 IniWrite('Main', 'AppLink', Value);
end;

procedure TIni.SetAppName(const Value: string);
begin
 IniWrite('Main', 'AppName', Value);
end;

procedure TIni.SetAppVers(const Value: string);
begin
 IniWrite('Main', 'AppVers', Value);
end;

end.
