unit Main;

interface

uses
 sButton, IniFiles, Windows, Messages, SysUtils, Variants, Classes, Graphics,
 Controls, Forms, Dialogs, StdCtrls, ScktComp, ComCtrls, Buttons, ADODB, Grids,
 ImgList, ExtCtrls, ShellAPI, System.Generics.Collections, Vcl.Imaging.pngimage,
 Vcl.ActnList, sLabel, Data.DB, Vcl.Imaging.GIFImg, IdHTTP, sPanel, sSpeedButton,
 Vcl.Themes, Vcl.ValEdit, sGauge, Vcl.Menus, acPNG, System.Actions,
 System.ImageList, System.Types, System.UITypes, IdUDPClient, IdComponent,
 IdUDPBase, IdUDPServer, IdGlobal, IdSocketHandle, sRichEdit, MMSystem,
 Vcl.ToolWin, IdBaseComponent, sColorSelect, IdMultipartFormData, Vcl.AppEvnts,
  TableDraw, Vcl.Imaging.jpeg, ES.BaseControls, ES.Images, System.Notification;

type
 //Слой окна (гл. окно, настройки, окно контакта, меню)
 TWindowFrame = (wfMain, wfSettings, wfContact, wfMenu);

 //Режим отображения правой части окна (контакты чата/данные о контакте справочника)
 TLeftSideType = (lsChatContact, lsSubject);

 //Тип звука
 TSoundType = (stChat, stStart, stShutdown);

 //Тип состояния линии
 TGlobalState = (gsIdle {ожидание},
                 gsDial {идёт разговор},
                 gsIncomingCall {входящий звонок},
                 gsDialing {набор номера});

 //Тип записи журнала звонков
 TJournalRecType = (jtMissed   {Пропущенный},
                    jtIncoming {Входящий},
                    jtDialing  {Исходящий},
                    jtRedirect {Перенаправленный});

 //Запись субъекта
 TRecType = (rtNumber, rtBranch, rtOther, rtDepart);

 //Общий тип процедуры с Sender
 TProcedureOfObject = procedure(Sender:TObject) of object;

 //Общий тип процедуры
 TSimpleProcedureOfObject = procedure of object;

 TCEMode = (cemNone, cemEdit, cemAdd, cemShow);

 //Запись адресанта
 TFromColor = record
  Name:string;              //Полное имя
  Num:string;
  Color:TColor;             //Цвет
 end;                       //Список
 TFromColors = TList<TFromColor>;

 //Запись чата
 TChatText = record
  From:string;              //От кого
  SendTo:string;
  FromNum:string;           //
  Text:string;              //Текст
  Date:TDateTime;           //Дата
  Color:TColor;             //Цвет
 end;                       //Список
 TChat = TList<TChatText>;

 //Версия программы
 TAppVerison = record
  private
   function GetVersion: string;
  public
  Major:Integer;
  Minor:Integer;
  property Version:string read GetVersion;
 end;

 //Представление времени в днях, часах...
 TTimeStamp = record
  Days:Word;
  Hours:Byte;
  Minutes:Byte;
  Seconds:Byte;
 end;

 //Запись объекта
 TBranchNumber = record
   Number:string;            //Номер телефона объекта (городской)
   BranchNum:string;         //Номер объекта
   Name:string;              //Название, наименование, имя
   EMail:string;             //Эл. почта
   Address:string;           //Адрес
   FAX:String;               //Сотовый телефон
   PLAT:String;              //ИД объекта в elix
   KodOtd:Integer;           //Код отделения
   NObjParent:string;
   NObj:string;
 end;                       //Список
 TListOfBranch = TList<TBranchNumber>;

 //Запись субъекта
 TNumberRec = record
  FIO:string;               //ФИО
  Position:string;          //Должность
  Address:string;           //Адрес
  EMail:string;             //Почта
  NumLandline:string;       //Городской
  NumCell:string;           //Сотовый
  NumInteranl:string;       //Внутренний
  KodOtd:Integer;           //Код отделения (не у людей)
 end;                       //Список
 TListOfNumber = TList<TNumberRec>;

 //Запись отделения
 TDepartRec = record
  FIO:string;               //ФИО босса
  Position:string;          //Должность босса
  Address:string;           //Адрес отделения
  Name:string;              //Название отделения
  EMail:string;             //Почта
  NumLandline:string;       //Городской
  NumCell:string;           //Сотовый
  NumInteranl:string;       //Внутренний
  KodOtd:Integer;           //Код отделения (не у людей)
  Color:TColor;
 end;                       //Список
 TListOfDepart = TList<TDepartRec>;

 //Запись "Прочее"
 TOtherRec = record
  FIO:string;               //ФИО
  Position:string;          //Должность
  Address:string;           //Адрес
  EMail:string;             //Почта
  NumLandline:string;       //Городской
  NumCell:string;           //Сотовый
  NumInteranl:string;       //Внутренний
  Commnet:string;           //Комментарий
  KodOtd:Integer;           //Код отделения
  nRecCallDop:Integer;      //ИД записи в БД
  xSha:Boolean;             //Флаг "Общий контакт"
  UserID:string;            //Номер того, кто добавил запись
 end;                       //Список
 TListOfOther = TList<TOtherRec>;

 //Запись журнала звонков
 TJournalRec = record
  inSubject:string;         //Имя звонящего
  inNumber:string;          //Номер звонящего
  fromNumber:string;        //Мой номер
  inStart:TDateTime;        //Начало звонка
  inFinish:TDateTime;       //Окончание звонка
  inChannel:string;         //Канал звонка
  inExtenChannel:string;    //Доп. канал (внешний звонок)
  TimeDur:TTimeStamp;       //Время разговора
  ItemType:TJournalRecType; //Тип записи
  EventCount:Integer;       //Кол-во повторений записи
  ItemID:Integer;           //ИД записи в журнале (относительно загрузки в массив)
 end;                       //Список
 TJournal = TList<TJournalRec>;

 //Обобщённая запись номера
 TCommonRec = record
  FIO:string;               //ФИО
  Position:string;          //Должность
  Address:string;           //Адрес
  EMail:string;             //Почта
  NumLandline:string;       //Городской
  NumCell:string;           //Сотовый
  NumInteranl:string;       //Внутренний
  Commnet:string;           //Комментарий
  PLAT:string;              //Рабочее время
  KodOtd:Integer;           //Код отделения
  RecType:TRecType;         //Тип
 end;                       //Список
 TListOfCommon = TList<TCommonRec>;

 //Поток поиска инф. о контакте
 TThreadFindContact = class(TThread)
  private
    FWork:Boolean;
    FWorking:Boolean;
    FStop:Boolean;
    FContact:string;
    FFinded:string;
   protected
    procedure Execute; override;
   public
    DoFind:TSimpleProcedureOfObject;
    procedure Find;
    property Finded:string read FFinded;
    constructor Create(CreateSuspended: Boolean);
  end;

 //Гл. форма
 TFormMain = class(TForm)
    ActionAbout: TAction;
    ActionAddNumToFav: TAction;
    ActionChat: TAction;
    ActionChatAnon: TAction;
    ActionChatClear: TAction;
    ActionChatMute: TAction;
    ActionChatOff: TAction;
    ActionChatWhoThere: TAction;
    ActionEditFavorite: TAction;
    ActionJournal: TAction;
    ActionList: TActionList;
    ActionOtherAdd: TAction;
    ActionQuit: TAction;
    ActionRecon: TAction;
    ActionReload: TAction;
    ActionSearch: TAction;
    ActionSettings: TAction;
    ActionShowWindow: TAction;
    ActionSortOtherASC: TAction;
    ActionSortOtherComment: TAction;
    ActionSortOtherDESC: TAction;
    ActionSortOtherName: TAction;
    ApplicationEvents: TApplicationEvents;
    Bevel5: TBevel;
    Bevel8: TBevel;
    ButtonCallUp: TButton;
    ButtonCEClose: TButton;
    ButtonChangeNumber: TButton;
    ButtonChatHelpClose: TButton;
    ButtonChatSend: TsSpeedButton;
    ButtonChatSendTo: TSpeedButton;
    ButtonColorAero: TButton;
    ButtonColorAeroMenu: TButton;
    ButtonColorReset: TButton;
    ButtonColorResetMenu: TButton;
    ButtonColorSet: TButton;
    ButtonColorSetMenu: TButton;
    ButtonDialCell: TButton;
    ButtonDialGroup: TPanel;
    ButtonDialInternal: TButton;
    ButtonDialLandline: TButton;
    ButtonedEditDepartSearch: TButtonedEdit;
    ButtonedEditOther: TButtonedEdit;
    ButtonedEditSearch: TButtonedEdit;
    ButtonedEditSearchGlobal: TButtonedEdit;
    ButtonEditAdr: TButton;
    ButtonEditPostion: TButton;
    ButtonErase: TButton;
    ButtonJClear: TButton;
    ButtonJCopy: TButton;
    ButtonJDelete: TButton;
    ButtonJDial: TButton;
    ButtonJFReset: TButton;
    ButtonJournalFilterUpdate: TButton;
    ButtonMailTo: TsSpeedButton;
    ButtonOK: TButton;
    ButtonOtherAdd: TButton;
    ButtonOtherDelete: TButton;
    ButtonOtherEdit: TButton;
    ButtonPanelHide: TsSpeedButton;
    ButtonSettingsScaleSet: TButton;
    ButtonSort: TButton;
    ButtonStopUpdate: TsSpeedButton;
    ButtonToFavCell: TsSpeedButton;
    ButtonToFavInternal: TsSpeedButton;
    ButtonToFavLandline: TsSpeedButton;
    CheckBoxAsteriskMute: TCheckBox;
    CheckBoxAutorun: TCheckBox;
    CheckBoxShare: TCheckBox;
    CheckBoxUseAero: TCheckBox;
    ClientSocketAsterisk: TClientSocket;
    ColorSelectMenu: TsColorSelect;
    ColorSelectMenuForMenu: TsColorSelect;
    ComboBoxChatNotify: TComboBox;
    ComboBoxJournalFType: TComboBox;
    DateTimePickerJournalFDateB: TDateTimePicker;
    DateTimePickerJournalFDateE: TDateTimePicker;
    DrawGridBranchs: TDrawGrid;
    DrawGridBuyings: TDrawGrid;
    DrawGridBuyingsS: TDrawGrid;
    DrawGridFavorite: TDrawGrid;
    DrawGridGroup: TDrawGrid;
    DrawGridNumPad: TDrawGrid;
    DrawGridShops: TDrawGrid;
    DrawGridWorkTime: TDrawGrid;
    EditCAddress: TEdit;
    EditCatalogEMail: TEdit;
    EditCatalogFIO: TEdit;
    EditCatalogNumCell: TEdit;
    EditCatalogNumIn: TEdit;
    EditCatalogNumLandline: TEdit;
    EditCCell: TEdit;
    EditCCellIn: TEdit;
    EditCFIO: TEdit;
    EditChatSend: TEdit;
    EditCIn: TEdit;
    EditCInternalIn: TEdit;
    EditCLand: TEdit;
    EditCLandIn: TEdit;
    EditCMail: TEdit;
    EditCPosition: TEdit;
    EditMainNumber: TButtonedEdit;
    EditNumber: TLabeledEdit;
    EditSecret: TLabeledEdit;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    ImageAsteriskMuted: TImage;
    ImageAvailableUpdate: TImage;
    ImageBuyingsHead: TImage;
    ImageBuyingsSHead: TImage;
    ImageChat: TImage;
    ImageChatHelpDownOnChat: TImage;
    ImageChatHelpWinNotify: TImage;
    ImageConState: TImage;
    ImageDialGroup: TImage;
    ImageDialing: TImage;
    ImageIOData: TImage;
    ImageList24: TImageList;
    ImageList: TImageList;
    ImageListDialGroup: TImageList;
    ImageListMans: TImageList;
    ImageListNumbers: TImageList;
    ImageMan: TImage;
    ImageShopHead: TImage;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label1: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label2: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    LabelBuyingsHead: TLabel;
    LabelBuyingsSHead: TLabel;
    LabelChatContact: TLabel;
    LabelChatHelpOnChat: TLabel;
    LabelConData: TLabel;
    LabelDesc: TLabel;
    LabelDownFrom: TLabel;
    LabelDownloading: TLabel;
    LabelDownTo: TLabel;
    LabelHint: TLabel;
    LabelinNumber: TLabel;
    LabelinSubject: TLabel;
    LabelJDate: TLabel;
    LabelNoConenction: TLabel;
    LabelShopHead: TLabel;
    LabelState: TLabel;
    LabelUpdating: TLabel;
    LabelUpState: TLabel;
    LabelVewCell: TLabel;
    LabelViewAddress: TLabel;
    LabelViewEMail: TLabel;
    LabelViewFIO: TLabel;
    LabelVIewInt: TLabel;
    LabelViewLand: TLabel;
    LabelViewPosition: TLabel;
    ListBoxBuyingDepart: TListBox;
    ListBoxChat: TListBox;
    ListBoxChatContact: TListBox;
    ListBoxDeparts: TListBox;
    ListBoxGroups: TListBox;
    ListBoxOther: TListBox;
    ListBoxShops: TListBox;
    MemoCatalogAddress: TMemo;
    MemoCatalogPosition: TMemo;
    MemoCComment: TMemo;
    MemoComment: TMemo;
    MemoLog: TMemo;
    MenuItemAbout1: TMenuItem;
    MenuItemChatCopy: TMenuItem;
    MenuItemChatSay: TMenuItem;
    MenuItemFavChangeIcon: TMenuItem;
    MenuItemFavChangeName: TMenuItem;
    MenuItemFavChangeNumber: TMenuItem;
    MenuItemFavDelete: TMenuItem;
    MenuItemFavLast: TMenuItem;
    MenuItemJClear: TMenuItem;
    MenuItemJCopy: TMenuItem;
    MenuItemJDelete: TMenuItem;
    MenuItemJDial: TMenuItem;
    MenuItemJournal: TMenuItem;
    MenuItemN10: TMenuItem;
    MenuItemN2: TMenuItem;
    MenuItemN3: TMenuItem;
    MenuItemN4: TMenuItem;
    MenuItemN5: TMenuItem;
    MenuItemN6: TMenuItem;
    MenuItemN7: TMenuItem;
    MenuItemN8: TMenuItem;
    MenuItemN9: TMenuItem;
    MenuItemOtherAdd: TMenuItem;
    MenuItemOtherDelete: TMenuItem;
    MenuItemOtherEdit: TMenuItem;
    MenuItemQuit1: TMenuItem;
    MenuItemSearch: TMenuItem;
    MenuItemSettings1: TMenuItem;
    MenuItemShowWindow: TMenuItem;
    MenuItemSort: TMenuItem;
    MenuItemSortOtherASC1: TMenuItem;
    MenuItemSortOtherASC: TMenuItem;
    MenuItemSortOtherComment1: TMenuItem;
    MenuItemSortOtherComment: TMenuItem;
    MenuItemSortOtherDESC1: TMenuItem;
    MenuItemSortOtherDESC: TMenuItem;
    MenuItemSortOtherName1: TMenuItem;
    MenuItemSortOtherName: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    PageControlCatalog: TPageControl;
    PageControlMain: TPageControl;
    PaintBoxMenu: TPaintBox;
    Panel1: TPanel;
    Panel2: TPanel;
    PanelBuyings: TPanel;
    PanelBuyingsS: TPanel;
    PanelCard: TPanel;
    PanelChatContact: TPanel;
    PanelChatHelp: TPanel;
    PanelChatSend: TPanel;
    PanelChatToolBar: TPanel;
    PanelConnectionInfo: TPanel;
    PanelContactEdit: TPanel;
    PanelDepartToolbar: TPanel;
    PanelDialup: TPanel;
    PanelDialupLeft: TPanel;
    PanelDownLHead: TPanel;
    PanelDownloading: TPanel;
    PanelJournalFilter: TPanel;
    PanelJournalLeft: TPanel;
    PanelLearn1: TPanel;
    PanelMenu: TsPanel;
    PanelMenuClick: TPanel;
    PanelMyFav: TsPanel;
    PanelMyFavCom: TPanel;
    PanelMyGroup: TsPanel;
    PanelMyGroupCom: TPanel;
    PanelNumPad: TPanel;
    PanelOtherToolbar: TPanel;
    PanelPhone: TPanel;
    PanelSearchGlobal: TPanel;
    PanelSettings: TPanel;
    PanelShops: TPanel;
    PanelStatusBar: TPanel;
    PanelTutorialHelp: TPanel;
    PopupMenuChatList: TPopupMenu;
    PopupMenuFavorite: TPopupMenu;
    PopupMenuGroup: TPopupMenu;
    PopupMenuJournal: TPopupMenu;
    PopupMenuOther: TPopupMenu;
    PopupMenuSortOther: TPopupMenu;
    PopupMenuTray: TPopupMenu;
    ProgressBarUpdate: TsGauge;
    Shape10: TShape;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    Shape6: TShape;
    Shape7: TShape;
    Shape8: TShape;
    Shape9: TShape;
    ShapeChatSend: TShape;
    SpeedButtonAbout: TsSpeedButton;
    SpeedButtonAddOther: TsSpeedButton;
    SpeedButtonAddOtherMenu: TsSpeedButton;
    SpeedButtonCatalog: TsSpeedButton;
    SpeedButtonCEClose: TsSpeedButton;
    SpeedButtonChat: TsSpeedButton;
    SpeedButtonCopy: TsSpeedButton;
    SpeedButtonFavClear: TsSpeedButton;
    SpeedButtonFavInfo: TsSpeedButton;
    SpeedButtonGroupInfo: TsSpeedButton;
    SpeedButtonHangup: TsSpeedButton;
    SpeedButtonInsertGroups: TsSpeedButton;
    SpeedButtonJournal: TsSpeedButton;
    SpeedButtonKeepClaim: TsSpeedButton;
    SpeedButtonLearn1Ok: TsSpeedButton;
    SpeedButtonLearn2Ok: TsSpeedButton;
    SpeedButtonLog: TsSpeedButton;
    SpeedButtonLogClear: TsSpeedButton;
    SpeedButtonMenu: TsSpeedButton;
    SpeedButtonNumCopyBuf: TsSpeedButton;
    SpeedButtonNumFind: TsSpeedButton;
    SpeedButtonNumToFav: TsSpeedButton;
    SpeedButtonPhone: TsSpeedButton;
    SpeedButtonQuit: TsSpeedButton;
    SpeedButtonReload: TsSpeedButton;
    SpeedButtonSearch: TsSpeedButton;
    SpeedButtonSendLog: TsSpeedButton;
    SpeedButtonSep: TsSpeedButton;
    SpeedButtonSettings: TsSpeedButton;
    SpeedButtonSettingsClose: TsSpeedButton;
    SpeedButtonSwitchSub: TsSpeedButton;
    SpeedButtonWish: TsSpeedButton;
    StringGridGlobal: TStringGrid;
    TableExDepart: TTableEx;
    TableExJournal: TTableEx;
    TableExJournalList: TTableEx;
    TableExOffice: TTableEx;
    TabSheetBranchs: TTabSheet;
    TabSheetBuyings: TTabSheet;
    TabSheetCatalog: TTabSheet;
    TabSheetChat: TTabSheet;
    TabSheetDeparts: TTabSheet;
    TabSheetJournal: TTabSheet;
    TabSheetLog: TTabSheet;
    TabSheetOffice: TTabSheet;
    TabSheetOther: TTabSheet;
    TabSheetPhone: TTabSheet;
    TabSheetSearch: TTabSheet;
    TabSheetShops: TTabSheet;
    TaskDialogQuit: TTaskDialog;
    TimerAutoConnect: TTimer;
    TimerDayChange: TTimer;
    TimerStamp: TTimer;
    TimerUpdates: TTimer;
    ToolBar1: TToolBar;
    ToolBarChat: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton8: TToolButton;
    ToolButtonChatAnon: TToolButton;
    ToolButtonChatMute: TToolButton;
    ToolButtonChatOff: TToolButton;
    ToolButtonChatWhoThere: TToolButton;
    TrackBarScale: TTrackBar;
    TrayIcon: TTrayIcon;
    UDPClientChat: TIdUDPClient;
    UDPServerChat: TIdUDPServer;
    Panel3: TPanel;
    SpeedButtonPageOffice: TsSpeedButton;
    SpeedButtonPageBranchs: TsSpeedButton;
    SpeedButtonPageDeparts: TsSpeedButton;
    SpeedButtonPageShops: TsSpeedButton;
    SpeedButtonPageBuyings: TsSpeedButton;
    SpeedButtonPageSearch: TsSpeedButton;
    SpeedButtonPageOther: TsSpeedButton;
    SpeedButtonPageChat: TsSpeedButton;
    Panel4: TPanel;
    shp1: TShape;
    procedure ActionAboutExecute(Sender: TObject);
    procedure ActionAddNumToFavExecute(Sender: TObject);
    procedure ActionChatAnonExecute(Sender: TObject);
    procedure ActionChatClearExecute(Sender: TObject);
    procedure ActionChatExecute(Sender: TObject);
    procedure ActionChatMuteExecute(Sender: TObject);
    procedure ActionChatOffExecute(Sender: TObject);
    procedure ActionChatWhoThereExecute(Sender: TObject);
    procedure ActionJournalExecute(Sender: TObject);
    procedure ActionOtherAddExecute(Sender: TObject);
    procedure ActionQuitExecute(Sender: TObject);
    procedure ActionReconExecute(Sender: TObject);
    procedure ActionReloadExecute(Sender: TObject);
    procedure ActionSearchExecute(Sender: TObject);
    procedure ActionSettingsExecute(Sender: TObject);
    procedure ActionShowWindowExecute(Sender: TObject);
    procedure ActionSortOtherASCExecute(Sender: TObject);
    procedure ActionSortOtherCommentExecute(Sender: TObject);
    procedure ActionSortOtherDESCExecute(Sender: TObject);
    procedure ActionSortOtherNameExecute(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure ApplicationEventsRestore(Sender: TObject);
    procedure ButtonAddToFavClick(Sender: TObject);
    procedure ButtonCallDownClick(Sender: TObject);
    procedure ButtonCallUpClick(Sender: TObject);
    procedure ButtonCECloseClick(Sender: TObject);
    procedure ButtonChangeNumberClick(Sender: TObject);
    procedure ButtonChatHelpCloseClick(Sender: TObject);
    procedure ButtonChatSendClick(Sender: TObject);
    procedure ButtonChatSendToClick(Sender: TObject);
    procedure ButtonColorAeroClick(Sender: TObject);
    procedure ButtonColorAeroMenuClick(Sender: TObject);
    procedure ButtonColorResetClick(Sender: TObject);
    procedure ButtonColorResetMenuClick(Sender: TObject);
    procedure ButtonColorSetClick(Sender: TObject);
    procedure ButtonColorSetMenuClick(Sender: TObject);
    procedure ButtonDialCellClick(Sender: TObject);
    procedure ButtonDialClick(Sender: TObject);
    procedure ButtonDialInternalClick(Sender: TObject);
    procedure ButtonDialLandlineClick(Sender: TObject);
    procedure ButtonedEditDepartSearchChange(Sender: TObject);
    procedure ButtonedEditOtherRightButtonClick(Sender: TObject);
    procedure ButtonedEditSearchChange(Sender: TObject);
    procedure ButtonedEditSearchGlobalChange(Sender: TObject);
    procedure ButtonedEditSearchKeyPress(Sender: TObject; var Key: Char);
    procedure ButtonEditAdrClick(Sender: TObject);
    procedure ButtonEditPostionClick(Sender: TObject);
    procedure ButtonEraseClick(Sender: TObject);
    procedure ButtonEraseMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonFavMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ButtonJFResetClick(Sender: TObject);
    procedure ButtonJournalFilterClick(Sender: TObject);
    procedure ButtonJournalFilterUpdateClick(Sender: TObject);
    procedure ButtonMailToClick(Sender: TObject);
    procedure ButtonNumberClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonOtherDeleteClick(Sender: TObject);
    procedure ButtonOtherEditClick(Sender: TObject);
    procedure ButtonPanelHideClick(Sender: TObject);
    procedure ButtonSettingsScaleSetClick(Sender: TObject);
    procedure ButtonSortClick(Sender: TObject);
    procedure ButtonStopUpdateClick(Sender: TObject);
    procedure CheckBoxAsteriskMuteClick(Sender: TObject);
    procedure CheckBoxAutorunClick(Sender: TObject);
    procedure CheckBoxUseAeroClick(Sender: TObject);
    procedure ClientSocketAsteriskConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketAsteriskConnecting(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketAsteriskDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketAsteriskError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketAsteriskRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketAsteriskWrite(Sender: TObject; Socket: TCustomWinSocket);
    procedure ComboBoxChatNotifyChange(Sender: TObject);
    procedure DrawGridBranchsDblClick(Sender: TObject);
    procedure DrawGridBranchsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DrawGridBranchsMouseLeave(Sender: TObject);
    procedure DrawGridBranchsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridBranchsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridBranchsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DrawGridBuyingsMouseLeave(Sender: TObject);
    procedure DrawGridBuyingsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridBuyingsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridBuyingsSDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawGridBuyingsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DrawGridBuyingsSMouseLeave(Sender: TObject);
    procedure DrawGridBuyingsSMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridBuyingsSMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridBuyingsSSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DrawGridFavoriteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawGridFavoriteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridFavoriteMouseLeave(Sender: TObject);
    procedure DrawGridFavoriteMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridFavoriteMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridFavoriteMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridFavoriteMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridGroupDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawGridGroupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridGroupMouseLeave(Sender: TObject);
    procedure DrawGridGroupMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridGroupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridGroupMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridGroupMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridNumPadDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure DrawGridNumPadMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridNumPadMouseLeave(Sender: TObject);
    procedure DrawGridNumPadMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridNumPadMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridNumPadMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridNumPadMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure DrawGridShopsMouseLeave(Sender: TObject);
    procedure DrawGridShopsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridShopsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DrawGridShopsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure DrawGridWorkTimeDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure EditCCellInChange(Sender: TObject);
    procedure EditChatSendKeyPress(Sender: TObject; var Key: Char);
    procedure EditCInternalInChange(Sender: TObject);
    procedure EditCLandInChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ImageAsteriskMutedDblClick(Sender: TObject);
    procedure ImageChatClick(Sender: TObject);
    procedure ImageConStateDblClick(Sender: TObject);
    procedure ImageDialGroupClick(Sender: TObject);
    procedure ImageDialGroupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageDialGroupMouseEnter(Sender: TObject);
    procedure ImageDialGroupMouseLeave(Sender: TObject);
    procedure ImageDialGroupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ImageManMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LabelUpdatingMouseEnter(Sender: TObject);
    procedure LabelUpdatingMouseLeave(Sender: TObject);
    procedure ListBoxBuyingDepartClick(Sender: TObject);
    procedure ListBoxBuyingDepartDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxBuyingDepartMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxChatClick(Sender: TObject);
    procedure ListBoxChatContactClick(Sender: TObject);
    procedure ListBoxChatContactDblClick(Sender: TObject);
    procedure ListBoxChatContactDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxChatDblClick(Sender: TObject);
    procedure ListBoxChatDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxChatMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxChatMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxChatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxGroupsClick(Sender: TObject);
    procedure ListBoxGroupsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxGroupsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxOtherClick(Sender: TObject);
    procedure ListBoxOtherDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ListBoxOtherMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxOtherMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListBoxOtherMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure MemoCatalogAddressChange(Sender: TObject);
    procedure MemoCatalogPositionChange(Sender: TObject);
    procedure MenuItemChatCopyClick(Sender: TObject);
    procedure MenuItemFavChangeIconClick(Sender: TObject);
    procedure MenuItemFavChangeNameClick(Sender: TObject);
    procedure MenuItemFavChangeNumberClick(Sender: TObject);
    procedure MenuItemFavDeleteClick(Sender: TObject);
    procedure MenuItemJClearClick(Sender: TObject);
    procedure MenuItemJCopyClick(Sender: TObject);
    procedure MenuItemJDeleteClick(Sender: TObject);
    procedure MenuItemJDialClick(Sender: TObject);
    procedure OnPopupFav(Sender:TObject);
    procedure PageControlMainMouseActivate(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer; var MouseActivate: TMouseActivate);
    procedure PaintBoxMenuClick(Sender: TObject);
    procedure PaintBoxMenuPaint(Sender: TObject);
    procedure SpeedButtonCatalogClick(Sender: TObject);
    procedure SpeedButtonCECloseClick(Sender: TObject);
    procedure SpeedButtonCopyClick(Sender: TObject);
    procedure SpeedButtonFavClearClick(Sender: TObject);
    procedure SpeedButtonInsertGroupsClick(Sender: TObject);
    procedure SpeedButtonJournalClick(Sender: TObject);
    procedure SpeedButtonKeepClaimClick(Sender: TObject);
    procedure SpeedButtonLearn1OkClick(Sender: TObject);
    procedure SpeedButtonLearn2OkClick(Sender: TObject);
    procedure SpeedButtonLogClearClick(Sender: TObject);
    procedure SpeedButtonLogClick(Sender: TObject);
    procedure SpeedButtonMenuClick(Sender: TObject);
    procedure SpeedButtonNumCopyBufClick(Sender: TObject);
    procedure SpeedButtonNumFindClick(Sender: TObject);
    procedure SpeedButtonPhoneClick(Sender: TObject);
    procedure SpeedButtonSendLogClick(Sender: TObject);
    procedure SpeedButtonSettingsCloseClick(Sender: TObject);
    procedure SpeedButtonSwitchSubClick(Sender: TObject);
    procedure SpeedButtonWishClick(Sender: TObject);
    procedure StringGridGlobalSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure StringGridOffice1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure StringGridOffice1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
    procedure TableExDepartGetData(FCol, FRow: Integer; var Value: string);
    procedure TableExDepartItemClick(Sender: TObject; MouseButton: TMouseButton; const Index: Integer);
    procedure TableExJournalDblClick(Sender: TObject);
    procedure TableExJournalDrawCellData(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure TableExJournalListDblClick(Sender: TObject);
    procedure TableExJournalListDrawCellData(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
    procedure TableExJournalListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TableExJournalMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure TableExOfficeGetData(FCol, FRow: Integer; var Value: string);
    procedure TableExOfficeItemClick(Sender: TObject; MouseButton: TMouseButton; const Index: Integer);
    procedure TabSheetBranchsShow(Sender: TObject);
    procedure TabSheetChatShow(Sender: TObject);
    procedure TimerAutoConnectTimer(Sender: TObject);
    procedure TimerDayChangeTimer(Sender: TObject);
    procedure TimerStampTimer(Sender: TObject);
    procedure TimerUpdatesTimer(Sender: TObject);
    procedure TrayIconBalloonClick(Sender: TObject);
    procedure TrayIconDblClick(Sender: TObject);
    procedure UDPServerChatUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
    procedure SpeedButtonPageOfficeClick(Sender: TObject);
    procedure SpeedButtonPageDepartsClick(Sender: TObject);
    procedure SpeedButtonPageBranchsClick(Sender: TObject);
    procedure SpeedButtonPageShopsClick(Sender: TObject);
    procedure SpeedButtonPageBuyingsClick(Sender: TObject);
    procedure SpeedButtonPageSearchClick(Sender: TObject);
    procedure SpeedButtonPageOtherClick(Sender: TObject);
    procedure SpeedButtonPageChatClick(Sender: TObject);
   private
    CordDrawBranchs:TGridCoord;                                                 //Курсор в сетке для ломбардов
    CordDrawBuying:TGridCoord;                                                  //Курсор в сетке для скупок Г
    CordDrawBuyingS:TGridCoord;                                                 //Курсор в сетке для скупок ДР
    CordDrawFavorite:TGridCoord;                                                //Курсор в сетке для избранного
    CordDrawGroup:TGridCoord;                                                   //Курсор в сетке для отдела
    CordDrawNumpad:TGridCoord;                                                  //Курсор в сетке для нумпада
    CordDrawShops:TGridCoord;                                                   //Курсор в сетке для магазинов
    FAlarm:Boolean;                                                             //Флаг отображения звонка
    FAllowMessage:Boolean;                                                      //Доступность нового сообщения
    FAsteriskMute: Boolean;                                                     //Флаг фильтра осн. журнала
    FavoriteDowned:Boolean;                                                     //Нажатость в "Избранное"
    FButtonDialHint:string;                                                     //Подсказка для кнопки "Звонок"
    FButtonsColor:TColor;                                                       //Цвет иконок меню
    FChatAnon:Boolean;                                                          //Чат. анон
    FChatMute:Boolean;                                                          //Чат. без звука
    FChatNotify:Byte;                                                           //Режим уведомлений чата
    FChatOff:Boolean;                                                           //Чат. откл
    FCheckingVersion:Boolean;                                                   //Флаг процесса проверки обновлений
    FCurrentCEEditIndex:Integer;                                                //
    FCurrentCEMode:TCEMode;                                                     //Текущий режим работы панели редактирования контакта
    FCurrentFrame:TWindowFrame;                                                 //
    FDrawWorkTimeList:TStringList;
    FFirstRun:Boolean;
    FGlobalState:TGlobalState;                                                  //Состояние линии
    FJournalFiltred:Boolean;
    FMenuColor:TColor;                                                          //Цвет меню
    FNewVersionAvailable:Boolean;                                               //Флаг доступности новой версии
    FRunDate:TDateTime;
    FShowWarnMissed:Boolean;                                                    //Флаг отображения иконки о пропущенном
    FSortOtherASC:Boolean;                                                      //Тип сортировки
    FSortOtherBy:Byte;                                                          //Сортировка "Прочее" по..
    FThreadFindContact:TThreadFindContact;                                      //Поток для поиска инф. о звонящем
    FTrayIconIndex:Integer;
    FUseAeroColor:Boolean;
    FUseMainSub:Boolean;                                                        //Для режима переключения выбранногго субъекта
    MyGroupDowned:Boolean;                                                      //Нажатость в "Отдел"
    NumPadDowned:Boolean;                                                       //Нажатость в "NumPad"
    SelectedNumber:TCommonRec;                                                  //Отображаемый номер в справочнике
    SelectedNumberExt:TCommonRec;                                               //Отображаемый номер в справочнике (второй)
    ShowChatHelp:Boolean;                                                       //Показать подсказку о чате
    WorkCall:TJournalRec;                                                       //Рабочая запись (заполняется при наборе, звонке и т.д.)
    function CheckConnect:Boolean;                                              //Наличие соединения с проверкой
    function CreateConnection(var ADO:TADOConnection):Boolean;                  //Создать подключение к elix
    function CreateDepartColor(Data: TDepartRec): TColor;
    function GetAutorunState:Boolean;                                           //В автозапуске ли программа
    function GetWorkTimeText(FWorkTimes:TStringList):string;
    function SearchDepart(Text: string): Boolean;
    function SearchOffice(Text:string):Boolean;                                        //
    function SortOtherItem(i1, i2:Integer):Boolean;                             //Сравнить элемент "Прочее"
    procedure CloseContactForm;
    procedure CloseSettings;
    procedure CreateTablesColumns;
    procedure FCheckActualVersion(InfoForNoAvailable:Boolean);                  //Проверить обнолвения (с уведомлением, если нет)
    procedure FilterOffice(Group:string);
    procedure FThreadFindWorkContact;                                           //Найти для рабочей записи контакта в справочнике
    procedure OnHint(Sender: TObject);                                          //Обработка подсказки
    procedure OtherSort;                                                        //Сортировка "Прочее"
    procedure SetAlarm(Value:Boolean);                                          //Установить флаг уведомлений звонка
    procedure SetAllowMessage(Value:Boolean);                                   //Установить наличие нового сообщения
    procedure SetAsteriskMute(const Value: Boolean); //Обработаем завершение работы Windows
    procedure SetAutorunState(Value:Boolean);                                   //Установить автозапуск программы
    procedure SetButtonsColor(Value:TColor);                                    //Установить цвет кнопок меню
    procedure SetChatAnon(Value:Boolean);                                       //Чат. анон
    procedure SetChatMute(Value:Boolean);                                       //Чат. без звука
    procedure SetChatOff(Value:Boolean);                                        //Чат. откл
    procedure SetCheckingVersion(Value:Boolean);                                //Установить флаг процесса проверки обновлений
    procedure SetGlobalState(Value:TGlobalState);                               //Установить состояние линии
    procedure SetMenuColor(Value:TColor);                                       //Установить цвет меню
    procedure SetNewVersionAvailable(Value:Boolean);                            //Установить флаг доступности новой версии
    procedure SetRunDate(Value:TDateTime);                                      //Дата запуска
    procedure SetShowWarnMissed(Value:Boolean);                                 //Установить флаг показа пропущенного
    procedure SetUseAeroColor(Value:Boolean);
    procedure ShowContactForm(Mode:TCEMode);
    procedure UpdateGridFavorite;                                               //Обновить сетку избранного
    procedure UpdateGridGroup;                                                  //Обновить сетку отдела
    procedure UpdateTableDeparts;
    procedure UpdateTableOffice;
    procedure UpdateUnitsGrids;
    procedure WMQueryEndSession(var Message: TWMQueryEndSession); message WM_QUERYENDSESSION;
    procedure WriteLastRun;                                                     //Пометка в БД о версии
   public
    BranchNums:TListOfBranch;                                                   //Номера ломбардов
    BuyingNums:TListOfBranch;                                                   //Номера скупок Г
    BuyingSNums:TListOfBranch;                                                  //Номера скупок ДР
    CallBackNotify:TProcedureOfObject;                                          //Процедура обработки нажания на уведомление
    ChatList:TChat;                                                             //Лист чата
    CID,                                                                        //Ваш номер
    CIDGroup:string;                                                            //Отдел
    CIDName:string;                                                             //Ваше имя
    DepartBuyNums:TListOfDepart;                                                //Доступные отделения скупок
    DepartNums:TListOfDepart;                                                   //Отделения
    FavoriteNums:TListOfCommon;                                                 //Избранное
    FilteredOffice:TListOfNumber;
    FromColor:TFromColors;                                                      //Цвета адресантов
    GroupNums:TListOfNumber;                                                    //Номера моего отдела
    GroupsNums:TListOfNumber;                                                   //Номера отделов
    Journal, JournalFilter:TJournal;                                            //Журнал и журнал с фильтром
    OfficeNums:TListOfNumber;                                                   //Номера офисных работников
    OtherNums:TListOfOther;                                                     //Прочее
    ShopsNums:TListOfBranch;                                                    //Номера магазинов
    function ContactFIO(Number, Default:string):string;                         //Найти имя контакта
    function GetChatStr(ChatFrom, ChatFromName, ChatTo, ChatText:string):string;
    function GetCIDGroup:string;                                                //Полчить отдел текущего номера
    function GetEchoStr(ChatFrom, ChatFromName:string):string;
    function GetFromColor(From, Name:string):TColor;                            //Получить цвет адресанта
    function GetFromName(From:string):string;                                   //Получить имя адресанта
    function GetSendLogStr(ChatTo:string):string;
    function GetWhoThereStr:string;
    procedure ActionHangup(aChannel:string);                                    //Бросить трубку
    procedure AddToFavorite(Num:TCommonRec);                                    //Добавить в избранное номер
    procedure CallToMe(Sender:TObject);
    procedure Chat(CText:string);                                               //Добавить в чат "[От кого] Текст сообщения"
    procedure ChatSend(CText, STo:string);                                      //Написать в чат
    procedure ChatSendEcho;
    procedure ChatWhoThere;
    procedure CheckActualVersion(InfoForNoAvailable:Boolean);                   //Проверить обновления (с уведомлением, если нет)
    procedure ClearSelectedNumber;
    procedure DayChange;
    procedure DefaultHandler(var Msg); override;                                //Обработка некоторых внешних сообщений
    procedure Dial(Number:string);                                              //Набрать номер
    procedure DialupHide(Animate:Boolean = True);
    procedure DialupShow(Animate:Boolean = True);
    procedure EventDialing(aNumber, aSubject, aChannel:string; eventType:TJournalRecType);//Событие - набор номера
    procedure EventDialup(aNumber, aSubject, aChannel:string; eventType:TJournalRecType);//Событие - разговор
    procedure EventIncomingCall(aNumber, aSubject, aChannel:string);            //Событие - входящий звонок
    procedure EventOnHangup(aCause:string; ToJR:Boolean);                       //Событие - сброс трубки
    procedure FindWorkContact;                                                  //Найти имя контакта рабочего звонка (асинх)
    procedure Init;                                                             //Процедура инициализации
    procedure InsertGroupsToFavorite;                                           //Добавить номера отделов в избранное
    procedure InsertNumber(Number:string);                                      //Вставить номер в поле номера
    procedure LeftSideSet(LS:TLeftSideType);
    procedure LoadDataAndSettings;                                              //Загрузка параметров
    procedure Log(Value:string);                                                //Добавить в лог
    procedure MenuItemClickStringRow(Sender: TObject);                          //Процедура обработки нажатия на номер в контекстном меню (мой отдел)
    procedure NewWish;                                                          //Новое пожелание или ошибка
    procedure NotifyForNewVersion(aLink, aDesc:string; aCritical:Boolean; NewVer:TAppVerison);//Уведомить о доступном обновлении
    procedure PanelMenuState(Minimazed:Boolean);                                //Изменить состояние панели меню
    procedure Quit(Accepts:Boolean = True);                                     //Выход из программы (без запроса)
    procedure Redirect(Number: string);                                         //Перевести звонок
    procedure RunUpdate(Save:Boolean);                                          //Выполнить обновление
    procedure SaveDataAndSettings;                                              //Сохранения параметров
    procedure SendLog;
    procedure SendLogProc(MSG:string);
    procedure SetFrame(Frame:TWindowFrame);
    procedure SetMenuIconColor(Color:TColor);                                   //Установить цвет иконок меню
    procedure SetMenuPanelColor(aColor:TColor);
    procedure SetOtherData(Data:TOtherRec);                                     //Установить данные из прочее для отображения
    procedure SetPage(Tab:TTabSheet);                                           //Открыть страницу
    procedure SetCatalog(Tab:TTabSheet);
    procedure SetSelectedData(Data:TCommonRec);                                 //Установить данные номера для отображения
    procedure SetSelectedNumber;                                                //Обновить на форме поля для выбранного номера
    procedure SetSubjectData(Data:TBranchNumber);                               //Установить данные объекта для отображения
    procedure Settings;
    procedure ShowBalloonHintMsg(Title, Text:string; Flag:TBalloonFlags; Callback:TProcedureOfObject);//Показать уведомление
    procedure ShowNumbersForButton(InternalNum:string);                         //Показать контекстное меня для номера
    procedure Sound(What:TSoundType);                                           //Проиграть звук
    procedure StateChange;                                                      //Обновить состояние подключения
    procedure UnselAll;
    procedure UpdateAppCaption;                                                 //Обновить заголовок программы
    procedure UpdateChatSubject(MSG:string);
    procedure UpdateJournal;                                                    //Вывести журнал
    procedure WorkListDaySet;
    procedure WriteFavorits;                                                    //Сохранить избранное
    procedure WriteJournal;                                                     //Сохранить журнал
    property Alarm:Boolean read FAlarm write SetAlarm default True;             //Уведомлять о звонке
    property AllowMessage:Boolean read FAllowMessage write SetAllowMessage;     //Есть новые сообщения в чате
    property AsteriskMute:Boolean read FAsteriskMute write SetAsteriskMute;
    property Autorun:Boolean read GetAutorunState write SetAutorunState;        //Автозапуск при старте ОС
    property ButtonsColor:TColor read FButtonsColor write SetButtonsColor;      //Цвет иконок меню
    property ChatAnon:Boolean read FChatAnon write SetChatAnon;                 //Чат. Анонимность
    property ChatMute:Boolean read FChatMute write SetChatMute;                 //Чат. Без звука
    property ChatOff:Boolean read FChatOff write SetChatOff;                    //Чат. Отключить
    property CheckingVersion:Boolean read FCheckingVersion write SetCheckingVersion default False;//Идёт проверка обновлений
    property GlobalState:TGlobalState read FGlobalState write SetGlobalState;   //Состояние линии
    property MenuColor:TColor read FMenuColor write SetMenuColor;               //Цвет меню
    property NewVersionAvailable:Boolean read FNewVersionAvailable write SetNewVersionAvailable default False;//Доступна новая версия
    property RunDate:TDateTime read FRunDate write SetRunDate;
    property ShowWarnMissed:Boolean read FShowWarnMissed write SetShowWarnMissed default True;
    property TrayIconIndex:Integer read FTrayIconIndex;
    property UseAeroColor:Boolean read FUseAeroColor write SetUseAeroColor;     //Использовать цвета Windows Aero
  end;

const
 ADTable = 'LDAP://dc1.comul.int';//Доменная таблица пользователей
 AnonName = '';                   //Анонимный ник
 AppDesc = 'AsterLine';           //Название программы
 APP_DB_NAME = 'AsteriskPhone';   //Внутреннее имя в БД для обновлений
 APP_OIT_NUMBER = '1210';
 APP_UPDATE_POST = 'http://soft.comul.int/upload.php';
 chatdata = 'chatdata';
 chatecho = 'chatecho';
 chatsendlog = 'chatsendlog';
 chatwhothr = 'chatwhothere';
 ChatXORKey = 'C2E91095-1D0B-4AA2-A53A-7C6009CE661B-B514890B-083F-460C-AF6D-FCF29E2BEEBD';
 cnHost = '192.168.0.111';        //Хост Asterisk
 cnPort = 5038;                   //Порт Asterisk
 ConfigFN = 'config.dat';         //Конфигурационный файл
 ConfName = 'Конференция';
 ConfNumber = '9999';
 Context = 'from-internal';       //Контекст работы с Asterisk
 DefFavoriteWidth = 35;           //Ширина кнопок избранного по умолчанию
 DrawGridFontSize = 10;           //Размер шрифта сеток объектов
 IconIndexMissed = 27;
 InternalExe = 'AsterLine.exe';   //Внутренне имя исполнительного файла
 JournalMaxSize = 500;            //Максимальный размер журнала
 LinkApp = 'AsterLine - телефонный справочник';   //Имя файла для обновления
 LinkDescription = AppDesc+' - Телефонный справочник. Телефон. Журнал звонков. ООО ЛКДУ'; //Описание программы
 NetIPChat = '192.168.0.255';     //Широковещательный адрес чата
 NetPortChat = 21212;             //Порт чата
 QuickButtonCount = 4;            //Кол-во кнопок в ряду избранного
 SendForAll = '*';
 UpdateExe = '$update.update';    //Имя файла для обновления
 UpdateHTTPQuery = 'http://soft.comul.int/files/update.exe';

 ElixConnection = 'Provider=SQLOLEDB.1;'+
                  'Password=123456;'+
                  'Persist Security Info=True;'+
                  'User ID=elix;'+
                  'Initial Catalog=ELIX;'+
                  'Data Source=192.168.0.244';
                                 //Соединение с elix

 ADConnection   = 'Provider=ADsDSOObject;'+
                  'Encrypt Password=False;'+
                  'Integrated Security=SSPI;'+
                  'Data Source=comul.int;'+
                  'Location=dc1;'+
                  'Mode=Read;';  //Соединение с доменом

var
 FormMain:TFormMain;             //Гл. окно
 AnonNum:string;
 AutoConnecting:Boolean = False; //Флаг выполнения автоподключения
 CheckUpdateError:Boolean = True;
 clLISelect:TColor = $008CEAD7;  //Цвет выделения строк
 ColorDial:TColor = $0014C36C;
 ColorHangout:TColor = $001425C8;
 CurColorDial:TColor;
 CurColorDisable:TColor = $004B4B4B;
 CurColorHangout:TColor;
 DataIn:Int64;                   //Данных принято от Asterisk
 DataOut:Int64;                  //Данных передано Asterisk
 FCBMP:TBitmap;
 Initialized:Boolean = False;    //Флаг выполнения инициализации
 ShowErrorConnect:Boolean = True;//Флаг, отвечающий за показ сообщения об ошибке соединения
 Version:TAppVerison;            //Версия программы (задается в program)
///////////////////////////////////Данные новой версии
 NewVerCrit:Boolean;             //Флаг критического обновления
 NewVerDesc:string;              //Описание новой версии программы
 NewVerLink:string;              //Ссылка на новую версию программы
 NewVerVers:TAppVerison;         //Версия новой программы
 NotifyShowed:Boolean = False;   //Флаг, показывающий, показывали ли уведомление о новой версии
 UpdateFile:string;              //Полное имя $update.exe
///////////////////////////////////
 BID:Cardinal = 0;               //Инкремент для уникальных цисел в сессии
 CheckingState:Boolean = False;  //Состояние проверки
 FlagErrConnect:Boolean = False; //Флаг уведомления об ошибке
 FromAutorun:Boolean = False;    //Программа запущена с параметром автозагрузки
 IdSelectedB:Integer = -1;       //Переменная выбранного отделения скупки
 IdSelectedBranch:Integer = -1;  //Переменная выбранного ломбарда
 IdSelectedS:string = '';        //Переменная выбранного магазина
 LogName:string;                 //Текущий лог
 Mutex:THandle;                  //Мьютекс
 RedirectJR:TJournalRec;         //Запись перевода звонка
 RedirectToJR:Boolean = False;   //Флаг перевода звонка
 ShareIco:TIcon;                 //Иконка "Общий контакт"
 ShowInfoTray:Boolean = True;    //Флаг, показывающий, показывали ли уведомление о том, что "Программа ещё работает" в трее
 StartChat:Boolean = False;
 StopUpdate:Boolean = True;      //Флаг прерывания обновления обновления
 TrueConnection:Boolean = False; //Статус соединения
 UpdateState:Integer = 0;        //Состояние обноления (процент загрузки, -1 - нет соединения)
 WindScale:Byte = 100;           //Масштаб окна
 WM_MSGCLOSE:Cardinal;           //Сообщение Win "Закрыть программы"
 WM_MSGSHOW:Cardinal;            //Сообщение Win "Показать окно"
///////////////////////////////////////
 clDefMenu:TColor = $00DBDBDB;       //Цвет иконок меню - по умолчанию
 clDefMenuButtons:TColor = $00333333;//Цвет иконок меню - по умолчанию

 function AppVersion(vMajor, vMinor:Integer):TAppVerison;                       //Конструктор TAppVerison
 function BranchToCommon(SrcRec:TBranchNumber):TCommonRec;                      //Обобщить номер из "Объекта"
 function CheckCurrentPath:Boolean;                                             //Проверка, в нужной ли мы папке запущены (True - если мы перенеслись в другой каталог - нужно закрыться)
 function CreateFIO(F, I, O:string):string;                                     //Малинин Геннадий Александрович -> Малинин Г.А.
 function DepartToCommon(SrcRec:TDepartRec):TCommonRec;                         //Обобщить номер из "Отделения"
 function FieldToNumber(str:string):string;                                     //Отформатировать номер (LL - добавить 343, если не хватает)
 function FInputCloseQueryFav(const Values: array of string):Boolean;           //Обработка закрытия InputQuery
 function GetADNumber:string;                                                   //Получить внутренний номер телефона текущего пользователя в домене
 function GetAppVersionStr:string;                                              //Строковое представление вресии программы (1.3)
 function GetBranchWorkTime(Num:string; VL:TStringGrid):string;                 //Получить из БД график работы объекта
 function GetFIO(StrName:string; var sF, sI, sO:string):Boolean;                //Разделение ФИО
 function GetInetFile(const fileURL, FileName: string):Boolean;                 //Загрузка файла из сети
 function GetLocalFile(const fileFrom, toFileName: string):Boolean;             //Копирование файла из ФС
 function GetNumberOnly(inNum:string):string;                                   //Исключить из номера всё кроме цифр
 function JRItemTypeToStr(Value:TJournalRecType):string;                        //Строковое представление TJournalRecType
 function NumberToCommon(SrcRec:TNumberRec):TCommonRec;                         //Обобщить номер из "Субъекта"
 function OtherToCommon(SrcRec:TOtherRec):TCommonRec;                           //Обобщить номер из "Прочее"
 function SearchOther(LB:TListOfOther; aText:string):integer;                   //Поиск в прочее
 function SecondToTime(const Seconds:Cardinal):TTimeStamp;                      //Секунды в дни часы минуты секунды
 function TimeBetwen(Date1, Date2:TDateTime):TTimeStamp;                        //Разница между датами
 function TimeStampToStr(Value:TTimeStamp; WoS:Boolean = False):string;         //Строковое представление (WoS - Без секунд)
 function TimeStampToStrMini(Value:TTimeStamp):string;                          //Строковое представление (коротк)
 function Truncate(Str:string):string;                                          //Избавить строку от лишних пробелов (вначале, в конце и от двойных)
 procedure CheckActualVersionP;                                                 //Проверка новой версии
 procedure CheckADOConnection;                                                  //Проверка подключения (для потока)
 procedure CreateShortcut(ExeName:string);                                      //Создать ярлык программы на Раб. столе
 procedure GridClear(SG:TStringGrid);                                           //Очистка StringGrid
 procedure ReadFavoritsCSV(FN:TFileName; FieldSeparator:Char; var List:TListOfCommon); //Чтение избранного из CSV
 procedure ReadJournalCSV(FN:TFileName; FieldSeparator:Char; var List:TJournal);//Чтение журнала звонков из CSV
 procedure SearchGrid(SG:TStringGrid; aText:string);                            //Поиск по StringGrid (переход на запись)

 procedure WriteFavoritsCSV(FN:TFileName; FieldSeparator:Char; const List:TListOfCommon); //Запись избранного в CSV
 procedure WriteJournalCSV(FN:TFileName; FieldSeparator:Char; const List:TJournal); //Запись журнала в CSV

implementation
 uses Math, System.DateUtils, DialUp, About, EditMemo,
      System.Win.Registry, Winapi.WinInet, Winapi.ShlObj, Winapi.ActiveX,
      System.Win.ComObj, Vcl.Clipbrd, IcoSelect, Main.CommonFunc, Loading,
      WishForm, Winapi.WinSock, MessageEvent;

{$R *.dfm}
{$R Sound.res}

////////////////////////////////////////////////////////////////////////////////
//TThreadFindContact

procedure TThreadFindContact.Find;
begin
 try
  if FWorking then Terminate;
  FWork:=True;
  if Suspended then Resume;
  if Finished then Start;
 except
  Synchronize(
   procedure
   begin
    FormMain.Log('error TThreadFindContact.Find');
   end);
 end;
end;

constructor TThreadFindContact.Create(CreateSuspended: Boolean);
begin
 inherited;
 FWork:=False;
end;

procedure TThreadFindContact.Execute;
begin
 FContact:='';
 FStop:=False;
 while (not Terminated) and (not Application.Terminated) do
  begin
   try
    if Application.Terminated then Exit;
    if FWork then
     begin
      FStop:=False;
      FWork:=False;
      FWorking:=True;
      if Assigned(DoFind) then DoFind;
      FWorking:=False;
      Self.Suspend;
     end;
    Sleep(300); 
   except

   end;
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//Вспомогательные функции

function CutData(var Data:string):string;
var LPos:Integer;
begin
 if Pos('[', Data) = 1 then
  begin
   LPos:=Pos(']', Data);
   if LPos <> 0 then
    begin
     Result:=Copy(Data, 2, LPos - 2);
     Data:=Copy(Data, LPos + 2, 200);
    end;
  end;
end;

function GetDepartColor(Kod:Integer; List:TListOfDepart; Def:TColor):TColor;
var i:Integer;
begin
 Result:=clNone;
 if List.Count > 0 then
  for i:= 0 to List.Count - 1 do
   if List[i].KodOtd = Kod then Exit(List[i].Color);
end;

procedure CheckADOConnection;

function CreateCon:Boolean;
var ADO:TADOConnection;
begin
 TThread.Synchronize(nil,
  procedure
  begin
   Application.Hint:='Загрузка...';
  end);
 ADO:=TADOConnection.Create(nil);
 ADO.ConnectionTimeout:=5;
 ADO.CommandTimeout:=5;
 ADO.ConnectionString:=ElixConnection;
 try
  ADO.Connected:=True;
 except
  //on E:Exception do FormMain.Log('exception '+E.Message);
 end;
 Result:=ADO.Connected;
 ADO.Free;
 TThread.Synchronize(nil,
  procedure
  begin
   Application.Hint:='';
  end);
end;

begin
 CoInitialize(nil);
 CheckingState:=True;
 try
  TrueConnection:=CreateCon;
 except
  begin
   TrueConnection:=False;
   CheckingState:=False;
  end;
 end;
 CheckingState:=False;
end;

function TimeBetwen(Date1, Date2:TDateTime):TTimeStamp;
begin
 Result:=SecondToTime(SecondsBetween(Date2, Date1));
end;

function SecondToTime(const Seconds:Cardinal):TTimeStamp;
const SecPerDay = 86400; SecPerHour = 3600; SecPerMinute = 60;
begin
 Result.Days:=Seconds div SecPerDay;
 Result.Hours:=(Seconds mod SecPerDay) div SecPerHour;
 Result.Minutes:=((Seconds mod SecPerDay) mod SecPerHour) div SecPerMinute;
 Result.Seconds:=((Seconds mod SecPerDay) mod SecPerHour) mod SecPerMinute;
end;

function Truncate(Str:string):string;
begin
 Result:=Trim(Str);
 Result:=StringReplace(Result, '  ', ' ', [rfReplaceAll, rfIgnoreCase]);
end;

function GetBranchWorkTimeList(Num:string):TStringList;
var ADOConnection:TADOConnection;
    ADOQuery:TADOQuery;
    i:Integer;
    Str:string;

begin
 Result:=TStringList.Create;
 Application.Hint:='Загрузка...';
 Application.ProcessMessages;
 ADOConnection:=TADOConnection.Create(nil);
 ADOConnection.ConnectionTimeout:=20;
 ADOConnection.ConnectionString:=ElixConnection;
 try
  try
   ADOConnection.Connected:=True;
  finally
   Application.Hint:='';
  end;
 except
  begin
   ADOConnection.Free;
   Exit;
  end;
 end;
 ADOQuery:=TADOQuery.Create(nil);
 ADOQuery.Connection:=ADOConnection;
 for i:= 1 to 7 do
  begin
   ADOQuery.SQL.Text:='SELECT dCBDL.dbo.GetBranchWorkTime('+QuotedStr(Num)+', '+QuotedStr(IntToStr(i))+')';
   try
    ADOQuery.Open;
    while not ADOQuery.Eof do
     begin
      Str:=ADOQuery.Fields[0].AsString;
      if Str = '0:00-0:00' then Str:='0';
      Result.Add(Str);
      ADOQuery.Next;
     end;
   except
    FormMain.Log('error '+ADOQuery.SQL.Text);
   end;
  end;
 //Vl.Row:=DayOfTheWeek(Now)-1;
 ADOQuery.Close;
 ADOQuery.Free;
 ADOConnection.Close;
 ADOConnection.Free;
end;

function GetBranchWorkTime(Num:string; VL:TStringGrid):string;
var i:Integer;
    List:TStringList;

function GetStrDayWeek(Day:Integer):string;
begin
 case Day of
  1:Exit('Пн: ');
  2:Exit('Вт: ');
  3:Exit('Ср: ');
  4:Exit('Чт: ');
  5:Exit('Пт: ');
  6:Exit('Сб: ');
  7:Exit('Вс: ');
 end;
end;

begin
 List:=GetBranchWorkTimeList(Num);
 if List = nil then Exit;
 for i:= 0 to List.Count - 1 do
  begin
   VL.Cells[0, i]:=GetStrDayWeek(i+1);
   VL.Cells[1, i]:=List[i];
   if VL.Cells[1, i] = '0' then VL.Cells[1, i]:='Выходной';
   if VL.Cells[1, i] = '' then VL.Cells[1, i]:='Не указано';
  end;
 Result:=List.Text;
 List.Free;
end;

function SearchOther(LB:TListOfOther; aText:string):integer;
var i:Integer;
begin
 Result:=-1;
 if aText = '' then Exit;
 if LB.Count > 0 then
  begin
   for i:=0 to LB.Count - 1 do
    begin
      if (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].FIO)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].Position)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].Address)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].EMail)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].NumLandline)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].NumCell)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].NumInteranl)) or
         (AnsiLowerCase(aText) = AnsiLowerCase(LB[i].Commnet))
      then Exit(i);
    end;
   for i:=0 to LB.Count - 1 do
    begin
      if (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].FIO)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].Position)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].Address)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].EMail)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].NumLandline)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].NumCell)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].NumInteranl)) <> 0) or
         (Pos(AnsiLowerCase(aText), AnsiLowerCase(LB[i].Commnet)) <> 0)
      then Exit(i);
    end;
  end;
end;

procedure SearchGrid(SG:TStringGrid; aText:string);
var i, j:Integer;
begin
 if aText = '' then Exit;
 if SG.RowCount > 0 then
  for i:=0 to SG.RowCount - 1 do
   for j:= 0 to SG.ColCount - 1 do
    if (Pos(AnsiLowerCase(aText), AnsiLowerCase(SG.Cells[j, i])) <> 0) then
     begin
      SG.Row:=i;
      Exit;
     end;
end;

procedure GridClear(SG:TStringGrid);
var i:Integer;
begin
 if SG.RowCount > 0 then
  begin
   for i:= 0 to SG.RowCount - 1 do SG.Rows[i].Clear;
   SG.RowCount:=0;
  end;
end;

function FieldToNumber(str:string):string;
var sNum:string;
begin
 try
  sNum:=GetNumberOnly(str);
  case Length(sNum) of
   7:
    begin  //123-23-23
     sNum:='343'+sNum;
    end;
   10:     //343 123-23-23
    begin
     //ok
    end;
   11:     //1 343 123-23-23
    begin
     if CharInSet(sNum[1], ['7', '8']) then Delete(sNum, 1, 1);
    end;
           //    89530021368
           //    79530021368
  else Exit(str);
  end;
  Result:=Copy(sNum, 1, 3)+' '+Copy(sNum, 4, 3)+'-'+Copy(sNum, 7, 2)+'-'+Copy(sNum, 9, 2);
  if Length(sNum) > 10 then Result:=Result+Copy(sNum, 11, Integer.MaxValue)
  else if Length(sNum) < 11 then Result:='8 '+Result;
 except
  Result:=str;
 end;
end;

function GetFIO(StrName:string; var sF, sI, sO:string):Boolean;
var FIO, UpperStr:string;
    IdOf, i, p:Integer;
    Ok:Boolean;
begin
 Result:=False;
 StrName:=StringReplace(StrName, 'ё', 'е', [rfReplaceAll, rfIgnoreCase]);
 StrName:=StringReplace(StrName, '  ', ' ', [rfReplaceAll, rfIgnoreCase]);
 UpperStr:=Trim(StrName);
 StrName:=AnsiLowerCase(StrName);

 FIO:=Trim(StrName);
 if Length(FIO) <= 3 then  Exit;
 sF:='';
 sI:='';
 sO:='';
 IdOf:=Pos(' ', FIO);
 p:=Pos('.', FIO);
 if p > 0 then
  if IdOf > p then IdOf:=0;
 if IdOf <= 0 then
  //Всё хреново. Нет пробелов вообще, либо пропущен пробел между фамилией и именем. Ищем второй большой исмвол
  begin
   Ok:=False;
   for i:= 2 to p-1 do
    begin
     //Если нашли второй большой символ, то считаем это началом инициалов
     if IsCharUpperW(UpperStr[i]) then
      begin
       sF:=Copy(FIO, 1, i-1);
       Delete(FIO, 1, i-1);
       Ok:=True;
       Break;
      end;
    end;
   if not ok then
    begin
     IdOf:=Pos('.', FIO);
     if IdOf > 0 then
      begin
       sF:=Copy(FIO, 1, IdOf-2);
       Delete(FIO, 1, IdOf-1);
      end
     else Exit;
    end;
  end
 else
  begin
   sF:=Copy(FIO, 1, IdOf-1);
   Delete(FIO, 1, IdOf);
  end;
 if Length(sF) > 0 then sF[1]:=AnsiUpperCase(sF[1])[1];

 if Length(FIO) > 0 then
  begin
   for i:= 1 to Length(FIO) do
    begin
     if ((Ord(FIO[i]) >= 1072) and (Ord(FIO[i]) <= 1103)) then sI:=sI+FIO[i]
     else Break;
    end;
   Delete(FIO, 1, i);
  end;
 if Length(sI) > 0 then sI[1]:=AnsiUpperCase(sI[1])[1];

 if Length(FIO) > 0 then
  for i:= 1 to Length(FIO) do
   begin
    if ((Ord(FIO[i]) >= 1072) and (Ord(FIO[i]) <= 1103)) then sO:=sO+FIO[i]
    else Break;
   end;
 if Length(sO) > 0 then sO[1]:=AnsiUpperCase(sO[1])[1];
 Result:=sF <> '';
end;

function CreateFIO(F, I, O:string):string;
begin
 Result:=F;
 if Length(I) > 0 then
  begin
   Result:=Result + ' ' + I[1]+'.';
   if Length(O) > 0 then Result:=Result + ' ' + O[1] + '.';
  end;
end;

function GetNumberOnly(inNum:string):string;
var i:Integer;
begin
 Result:='';
 if Length(inNum) > 0 then
  for i:= 0 to Length(inNum) do
   if CharInSet(inNum[i], ['0'..'9']) then Result:=Result+inNum[i];
end;

function GetLocalFile(const fileFrom, toFileName: string):Boolean;
begin
 Result:=CopyFile(PChar(fileFrom), PChar(toFileName), True);
end;

function GetInetFile(const fileURL, FileName:string):Boolean;
const BufferSize = 64 * 1024;
var   hSession, hURL:HInternet;
      Buffer: array[1..BufferSize] of Byte;
      BufferLen: DWORD;
      F:File;
      sAppName:string;
      DownPercent:Extended;
      fSize, getSize:Int64;
      HTTP:TidHTTP;
begin
 Result:=False;
 sAppName:=ExtractFileName(Application.ExeName);
 hSession:=InternetOpen(PChar(sAppName), INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
 if Assigned(hSession) then
  begin
   hURL:=InternetOpenURL(hSession, PChar(fileURL), nil, 0, INTERNET_FLAG_RELOAD, 0);
   if Assigned(hURL) then
    begin
     try
      try
       AssignFile(F, FileName);
       Rewrite(F, 1);
       getSize:=0;
       HTTP:=TIdHTTP.Create(nil);
       HTTP.Head(fileURL);
       fSize:=HTTP.Response.ContentLength;
       HTTP.Free;
       repeat
        InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen);
        getSize:=getSize + BufferLen;
        DownPercent:=(getSize * 100) / fSize;
        UpdateState:=Round(DownPercent);
        if Assigned(FormMain) then FormMain.TimerStampTimer(nil);
        if Assigned(FormLoading) then FormLoading.UpdateLoading(UpdateState);
        Application.ProcessMessages;
        if StopUpdate then Break;
        BlockWrite(F, Buffer, BufferLen);
       until BufferLen = 0;
       Result:=(not StopUpdate) and (getSize > 1);
      finally
       CloseFile(F);
      end;
     except
      UpdateState:=-1;
     end;
     InternetCloseHandle(hURL);
    end
   else UpdateState:=-1;
   InternetCloseHandle(hSession);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//Доп. функции

function OtherToCommon(SrcRec:TOtherRec):TCommonRec;
begin
 Result.RecType:=rtOther;
 Result.FIO:=SrcRec.FIO;
 Result.Position:=SrcRec.Position;
 Result.Address:=SrcRec.Address;
 Result.EMail:=SrcRec.EMail;
 Result.NumLandline:=SrcRec.NumLandline;
 Result.NumCell:=SrcRec.NumCell;
 Result.NumInteranl:=SrcRec.NumInteranl;
 Result.Commnet:=SrcRec.Commnet;
 Result.PLAT:='';
end;

function BranchToCommon(SrcRec:TBranchNumber):TCommonRec;
begin
 Result.RecType:=rtBranch;
 Result.FIO:=SrcRec.Name;
 Result.Position:='';
 Result.Address:=SrcRec.Address;
 Result.EMail:=SrcRec.EMail;
 Result.NumLandline:=SrcRec.Number;
 Result.NumCell:=SrcRec.FAX;
 Result.NumInteranl:='';
 Result.Commnet:='';
 Result.PLAT:=SrcRec.PLAT
end;

function DepartToCommon(SrcRec:TDepartRec):TCommonRec;
begin
 Result.RecType:=rtDepart;
 Result.FIO:=SrcRec.FIO;
 Result.Position:=SrcRec.Position + #13#10 + SrcRec.Name + ' отделение';
 Result.Address:=SrcRec.Address;
 Result.EMail:=SrcRec.EMail;
 Result.NumLandline:=SrcRec.NumLandline;
 Result.NumCell:=SrcRec.NumCell;
 Result.NumInteranl:=SrcRec.NumInteranl;
 Result.Commnet:='';
 Result.PLAT:='';
end;

function NumberToCommon(SrcRec:TNumberRec):TCommonRec;
begin
 Result.RecType:=rtNumber;
 Result.FIO:=SrcRec.FIO;
 Result.Position:=SrcRec.Position;
 Result.Address:=SrcRec.Address;
 Result.EMail:=SrcRec.EMail;
 Result.NumLandline:=SrcRec.NumLandline;
 Result.NumCell:=SrcRec.NumCell;
 Result.NumInteranl:=SrcRec.NumInteranl;
 Result.Commnet:='';
 Result.PLAT:='';
end;

function GetADNumber:string;
var ADOQuery:TADOQuery;
begin
 Result:='';
 ADOQuery:=TADOQuery.Create(nil);
 ADOQuery.Connection:=TADOConnection.Create(nil);
 ADOQuery.Connection.LoginPrompt:=False;
 ADOQuery.Connection.ConnectionString:=ADConnection;
 try
  ADOQuery.Connection.Connected:=True;
 except
  begin
   FormMain.Log('except GetADNumber');
   ADOQuery.Close;
   ADOQuery.Connection.Free;
   ADOQuery.Free;
   Exit;
  end;
 end;
 ADOQuery.ExecuteOptions:=[];
 ADOQuery.ParamCheck:=False;
 ADOQuery.SQL.Clear;
 ADOQuery.SQL.Text:='SELECT otherTelephone, telephoneNumber, sAMAccountName, Company, displayname FROM '+QuotedStr(ADTable)+' WHERE sAMAccountName='+QuotedStr(GetUserName)+' AND objectClass = '+QuotedStr('User');
 try
  ADOQuery.Open;
  if ADOQuery.RecordCount > 0 then
   begin
    Result:=ADOQuery.FieldByName('telephoneNumber').AsString;
   end;
 except
 end;
 ADOQuery.Close;
 ADOQuery.Connection.Free;
 ADOQuery.Free;
end;

function GetAppVersionStr:string;
begin
 Result:=IntToStr(Version.Major)+'.'+IntToStr(Version.Minor);
end;

procedure TFormMain.FThreadFindWorkContact;
var buf:string;
begin
 try
  if WorkCall.inNumber = '' then Exit;
  buf:=ContactFIO(WorkCall.inNumber, WorkCall.inSubject);
 except
  Exit;
 end;
 if buf <> '' then
  if buf <> WorkCall.inSubject then WorkCall.inSubject:=buf;
end;

procedure CheckActualVersionP;
begin
 if Assigned(FormMain) then FormMain.CheckActualVersion(False);
end;

procedure CreateShortcut(ExeName:string);
var MyObject:IUnknown;
    MySLink:IShellLink;
    MyPFile:IPersistFile;
    WideFile:WideString;
begin
 MyObject:=CreateComObject(CLSID_ShellLink);
 MySLink:=MyObject as IShellLink;
 MyPFile:=MyObject as IPersistFile;
 with MySLink do
  begin
   SetPath(PChar(ExeName));
   SetWorkingDirectory(PChar(ExtractFilePath(ExeName)));
   SetDescription(PChar(LinkDescription))
  end;
 WideFile:=GetEnvironment(CSIDL_DESKTOP)+'\'+LinkApp+'.lnk';
 MyPFile.Save(PChar(WideFile), False);
end;

function CheckCurrentPath:Boolean;
begin
 Result:=True;
end;

function AppVersion(vMajor, vMinor:Integer):TAppVerison;
begin
 Result.Major:=vMajor;
 Result.Minor:=vMinor;
end;

function FInputCloseQueryFav(const Values: array of string):Boolean;
var i:Integer;
begin
 Result:=False;
 for i:= Low(Values) to High(Values) do if Values[i] = '' then Exit;
 Result:=True;
end;

function JRItemTypeToStr(Value:TJournalRecType):string;
begin
 case Value of
  jtMissed:  Exit('Пропущенный');
  jtIncoming:Exit('Входящий');
  jtDialing: Exit('Исходящий');
  jtRedirect:Exit('Перевод звонка');
 end;
end;

function TimeStampToStr(Value:TTimeStamp; WoS:Boolean = False):string;
begin
 Result:='';
 // 1 с.
 if not WoS then
  if Value.Seconds > 0 then Result:=' '+IntToStr(Value.Seconds)+' с.'+Result;
 // 1 м. 1 с.
 if Value.Minutes > 0 then Result:=' '+IntToStr(Value.Minutes)+' м.'+Result;
 // 1 ч. 1 м. 1 с.
 if Value.Hours > 0 then Result:=' '+IntToStr(Value.Hours)+' ч.'+Result;
 //1 д. 1 ч. 1 м. 1 с.
 if Value.Days > 0 then Result:=' '+IntToStr(Value.Days)+' д.'+Result;
 if Result = '' then Result:=' 0 с.';
 Trim(Result);
end;

function TimeStampToStrMini(Value:TTimeStamp):string;

function ToTwoLetter(str:string):string;
begin
 if Length(str) = 1 then Result:='0'+str else Result:=str;
end;

begin
 Result:=IntToStr(Value.Days)+':'+ToTwoLetter(IntToStr(Value.Hours))+':'+ToTwoLetter(IntToStr(Value.Minutes))+':'+ToTwoLetter(IntToStr(Value.Seconds));
end;

procedure WriteJournalCSV(FN:TFileName; FieldSeparator:Char; const List:TJournal);
var i:integer;
    StrList:TStringList;
    s:string;
begin
 StrList:= TStringList.Create;
 if List.Count > 0 then
  for i:= 0 to List.Count - 1 do
   begin
    s:= '';
    s:=s+List.Items[i].inSubject + FieldSeparator;
    s:=s+List.Items[i].inNumber + FieldSeparator;
    s:=s+List.Items[i].fromNumber + FieldSeparator;
    s:=s+DateTimeToStr(List.Items[i].inStart) + FieldSeparator;
    s:=s+DateTimeToStr(List.Items[i].inFinish) + FieldSeparator;
    s:=s+List.Items[i].inChannel + FieldSeparator;
    s:=s+List.Items[i].inExtenChannel + FieldSeparator;
    s:=s+IntToStr(Ord(List.Items[i].ItemType)) + FieldSeparator;
    s:=s+IntToStr(List.Items[i].EventCount) + FieldSeparator;
    StrList.Add(s);
   end;
 StrList.SaveToFile(FN);
 StrList.Free;
end;

procedure ReadJournalCSV(FN:TFileName; FieldSeparator:Char; var List:TJournal);
var SData, SRow:TStrings;
    i:integer;
    Num:TJournalRec;
    FText:TextFile;
begin
 SData:=TStringList.Create;
 SData.LoadFromFile(FN);
 List.Clear;
 if SData.Count > 0 then
  begin
   SRow:=TStringList.Create;
   SRow.Delimiter:=FieldSeparator;
   SRow.StrictDelimiter:=True;
   for i:= 0 to SData.Count - 1 do
    begin
     if i >= JournalMaxSize then
      begin
       if not FileExists(FN+'.history') then FileClose(FileCreate(FN+'.history'));
       AssignFile(FText, FN+'.history');
       Append(FText);
       writeln(FText, SData[i]);
       CloseFile(FText);
       Continue;
      end;
     SRow.DelimitedText:= SData[i];
     try
      Num.ItemID:=List.Add(Num);
      Num.inSubject:=SRow.Strings[0];
      Num.inNumber:=SRow.Strings[1];
      Num.fromNumber:=SRow.Strings[2];
      Num.inStart:=StrToDateTime(SRow.Strings[3]);
      Num.inFinish:=StrToDateTime(SRow.Strings[4]);
      Num.inChannel:=SRow.Strings[5];
      Num.inExtenChannel:=SRow.Strings[6];
      Num.ItemType:=TJournalRecType(StrToInt(SRow.Strings[7]));
      if SRow.Count > 8 then
       Num.EventCount:=StrToInt(SRow.Strings[8])
      else Num.EventCount:=0;
      Num.TimeDur:=TimeBetwen(Num.inStart, Num.inFinish);
     except
      Continue;
     end;
     List[Num.ItemID]:=Num;
    end;
   SRow.Free;
  end;
 SData.Free;
end;

procedure WriteFavoritsCSV(FN:TFileName; FieldSeparator:Char; const List:TListOfCommon);
var i:integer;
    STrList:TStringList;
    s:string;
begin
 STrList:= TStringList.Create;
 if List.Count > 0 then
  for i:= 0 to List.Count - 1 do
   begin
    s:= '';
    s:=s+List.Items[i].FIO + FieldSeparator;
    s:=s+List.Items[i].Position + FieldSeparator;
    s:=s+List.Items[i].Address + FieldSeparator;
    s:=s+List.Items[i].EMail + FieldSeparator;
    s:=s+List.Items[i].NumLandline + FieldSeparator;
    s:=s+List.Items[i].NumCell + FieldSeparator;
    s:=s+List.Items[i].NumInteranl + FieldSeparator;
    s:=s+IntToStr(List.Items[i].KodOtd) + FieldSeparator;
    STrList.Add(s);
   end;
 STrList.SaveToFile(FN);
 STrList.Free;
end;

procedure ReadFavoritsCSV(FN:TFileName; FieldSeparator:Char; var List:TListOfCommon);
var SData, SRow:TStrings;
    i:integer;
    Num:TCommonRec;
begin
 SData:=TStringList.Create;
 SData.LoadFromFile(FN);
 List.Clear;
 if SData.Count > 0 then
  begin
   SRow:=TStringList.Create;
   SRow.Delimiter:=FieldSeparator;
   SRow.StrictDelimiter:=True;
   for i := 0 to SData.Count - 1 do
    begin
     SRow.DelimitedText:= SData[i];
     try
      Num.FIO:=SRow.Strings[0];
      Num.Position:=SRow.Strings[1];
      Num.Address:=SRow.Strings[2];
      Num.EMail:=SRow.Strings[3];
      Num.NumLandline:=SRow.Strings[4];
      Num.NumCell:=SRow.Strings[5];
      Num.NumInteranl:=SRow.Strings[6];
      try
       Num.KodOtd:=StrToInt(SRow.Strings[7]);
      except
       Num.KodOtd:=-1;
      end;
     except
      FormMain.Log('except ReadFavoritsCSV '+SRow.DelimitedText);
     end;
     List.Add(Num);
    end;
   SRow.Free;
  end;
 SData.Free;
end;

////////////////////////////////////////////////////////////////////////////////
//TFormMain

function TFormMain.CreateConnection(var ADO:TADOConnection):Boolean;
begin
 Result:=False;
 if not CheckConnect then
  begin
   if not FlagErrConnect then
    begin
     FlagErrConnect:=True;
     Log('Нет подключения к серверу. Попробуйте чуть позже.');
     //MessageBox(Application.Handle, 'Нет подключения к серверу. Попробуйте чуть позже нажать кнопку "Обновить"', 'Внимание', MB_ICONWARNING or MB_OK);
    end;
   Exit;
  end;
 ADO:=TADOConnection.Create(nil);
 ADO.ConnectionTimeout:=20;
 ADO.ConnectionString:=ElixConnection;
 try
  ADO.Connected:=True;
 except
  begin
   Log('Нет подключения к серверу. Попробуйте чуть позже.');
   //MessageBox(Application.Handle, 'Нет подключения к серверу. Попробуйте чуть позже.', 'Внимание', MB_ICONWARNING or MB_OK);
   ADO.Free;
   Exit;
  end;
 end;
 Result:=True;
end;

procedure TFormMain.RunUpdate;
var Upd:string;
    TryInc:Integer;
begin
 if NewVerLink = '' then
  begin
   Log('Проблема с URL файла обновлений');
   Exit;
  end;
 Log('RunUpdate NewVerLink = '+NewVerLink);

 if Initialized then
  begin
   if PanelDownloading.Visible then
    begin
     Log('exit PanelDownloading.Visible');
     Exit;
    end;
   //ButtonStopUpdate.Caption:='Отменить';
   LabelDownFrom.Caption:='Из: '+UpdateHTTPQuery;
   LabelDownTo.Caption:='В: '+UpdateFile;
   ProgressBarUpdate.Progress:=0;
   ProgressBarUpdate.ForeColor:=$00E76A1F;
   PanelDownloading.Show;
   PageControlMain.Enabled:=False;
   PanelMenu.Enabled:=False;
   Application.ProcessMessages;
  end
 else
  begin
   SetLoadState('Загрузка обновлений...');
   if Assigned(FormLoading) then FormLoading.ProgressBar.Show;
  end;
 StopUpdate:=False;
 Upd:=ExtractFilePath(Application.ExeName) + 'update.exe';
 TryInc:=1;
 if NewVerCrit then
  begin
   Log('NewVerCrit = DeleteFile '+Upd);
   DeleteFile(Upd);
  end;

 if (not FileExists(Upd)) then
  begin
   while (not Application.Terminated) and (not StopUpdate) and (TryInc < 11) do
    begin
     if not Initialized then SetLoadState('Обновление. Попытка №'+IntToStr(TryInc))
     else LabelDownloading.Caption:='Загрузка обновлений. Попытка №'+IntToStr(TryInc);
     if GetInetFile(UpdateHTTPQuery, Upd) then Break
     else Log('error GetInetFile('+UpdateHTTPQuery+', Upd)');
     Sleep(100);
     if FileExists(Upd) then DeleteFile(Upd);
     Application.ProcessMessages;
     Inc(TryInc);
    end;
  end;
 if StopUpdate then
  begin
   StopUpdate:=True;
   if Initialized then
    begin
     PanelDownloading.Hide;
     PageControlMain.Enabled:=True;
     PanelMenu.Enabled:=True;
    end
   else SetLoadState('Обновление отменено');
   Log('exit StopUpdate');
   Exit;
  end;
 StopUpdate:=True;
 if TryInc > 10 then
  begin
   if Initialized then
    begin
     //PanelDownloading.Hide;
     //ButtonStopUpdate.Caption:='Закрыть';
     ProgressBarUpdate.Progress:=100;
     ProgressBarUpdate.ForeColor:=$000033CC;
     LabelUpState.Caption:='Во время обновления произошла ошибка';
     PageControlMain.Enabled:=True;
     PanelMenu.Enabled:=True;
    end
   else SetLoadState('Ошибка процедуры обновления');
   Log('exit ErrorUpdate');
   Exit;
  end;
 if Application.Terminated then Exit;

 WinExec(PAnsiChar(AnsiString(Upd+' '+NewVerLink)), SW_NORMAL);
 if Save then Quit(False) else Halt(0);
end;

function TFormMain.GetAutorunState:Boolean;
var Roll:TRegIniFile;
begin
 Roll:=TRegIniFile.Create(KEY_READ);
 Roll.RootKey:=HKEY_CURRENT_USER;
 if Roll.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run', False) then Result:=Roll.ValueExists(AppDesc) else Result:=False;
 Roll.Free;
end;

function TFormMain.GetChatStr(ChatFrom, ChatFromName, ChatTo, ChatText:string):string;
begin
 Result:='['+chatdata+'] ['+ChatFrom+'] ['+ChatFromName+'] ['+ChatTo+'] '+ChatText;
end;

function TFormMain.GetCIDGroup:string;
var i:Integer;
begin
 Result:='';
 if Length(CID) < 2 then Exit;
 if GroupsNums.Count > 0 then
  for i:= 0 to GroupsNums.Count - 1 do
   begin
    if Length(GroupsNums[i].NumInteranl) < 2 then Continue;
    if Copy(GroupsNums[i].NumInteranl, 1, 2) = Copy(CID, 1, 2) then Exit(GroupsNums[i].FIO);
   end;
end;

function TFormMain.GetEchoStr(ChatFrom, ChatFromName:string):string;
begin
 Result:='['+chatecho+'] ['+ChatFrom+'] ['+ChatFromName+']';
end;

function TFormMain.GetFromColor(From, Name:string):TColor;
var i:Integer;
    FColor:TFromColor;
begin
 if FromColor.Count > 0 then
  for i:= 0 to FromColor.Count - 1 do
   if FromColor[i].Num = From then Exit(FromColor[i].Color);
 FColor.Num:=From;
 FColor.Name:=Name;
 FColor.Color:=ColorDarker(GetRandomColor, 30);  //ColorDarker(Random(30000000));
 FromColor.Add(FColor);
 ListBoxChatContact.Items.Add('');
 Result:=FColor.Color;
end;

function TFormMain.GetFromName(From:string):string;
var i:Integer;
begin
 Result:='';
 if FromColor.Count > 0 then
  for i:= 0 to FromColor.Count - 1 do
   if FromColor[i].Num = From then Exit(FromColor[i].Name);
end;

function TFormMain.GetSendLogStr(ChatTo:string):string;
begin
 Result:='['+chatsendlog+'] ['+ChatTo+']';
end;

function TFormMain.GetWhoThereStr:string;
begin
 Result:='['+chatwhothr+']';
end;

function TFormMain.GetWorkTimeText(FWorkTimes: TStringList):string;
var i:Integer;
    str:string;
begin
 Result:='';
 if FWorkTimes.Count <= 0 then Exit;
 for i:= 0 to FWorkTimes.Count-1 do
  begin
   str:=FWorkTimes[i];
   if Str = ''  then Str:='не указано';
   if Str = '0' then Str:='Выходной';
   Result:=Result+GetStrDayWeek(i+1)+':'+str+#13#10;
  end;
 Result:=Trim(Result);
end;

procedure TFormMain.WMQueryEndSession(var Message: TWMQueryEndSession);
begin
 inherited;
 Message.Result:=1;
 Quit(False);
end;

procedure TFormMain.WorkListDaySet;
var i:Integer;
begin
 for i:= 0 to DrawGridWorkTime.RowCount-1 do DrawGridWorkTime.RowHeights[i]:=DrawGridWorkTime.DefaultRowHeight;
 DrawGridWorkTime.RowHeights[DayOfTheWeek(Now)-1]:=DrawGridWorkTime.ClientHeight - (DrawGridWorkTime.DefaultRowHeight * (DrawGridWorkTime.RowCount-1));
end;

procedure TFormMain.SetButtonsColor(Value:TColor);
begin
 FButtonsColor:=Value;
 SetMenuIconColor(FButtonsColor);
end;

procedure TFormMain.SetMenuColor(Value:TColor);
begin
 FMenuColor:=Value;
 SetMenuPanelColor(FMenuColor);
end;

procedure TFormMain.SetAllowMessage(Value:Boolean);
begin
 FAllowMessage:=Value;
end;

procedure TFormMain.SetAsteriskMute(const Value:Boolean);
begin
 FAsteriskMute:=Value;
 if Value then if GlobalState <> gsIdle then EventOnHangup('QUIT', True);
 ImageAsteriskMuted.Visible:=FAsteriskMute;
end;

procedure TFormMain.SetAutorunState(Value:Boolean);
var Roll:TRegIniFile;
begin
 Roll:=TRegIniFile.Create(KEY_ALL_ACCESS);
 try
  Roll.RootKey:=HKEY_CURRENT_USER;
  if Roll.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\', False) then
   begin
    if Value then Roll.WriteString('Run', AppDesc, '"'+Application.ExeName+'" /autorun') else Roll.DeleteKey('Run', AppDesc);
   end;
 except
  Log('except write HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Run');
 end;
 Roll.Free;
end;

procedure TFormMain.ShowBalloonHintMsg(Title, Text:string; Flag:TBalloonFlags; Callback:TProcedureOfObject);
begin
 TrayIcon.BalloonHint:=Text;
 TrayIcon.BalloonTitle:=Title;
 TrayIcon.BalloonTimeout:=5000;
 TrayIcon.BalloonFlags:=Flag;
 TrayIcon.OnBalloonClick:=Callback;
 TrayIcon.ShowBalloonHint;
end;

procedure TFormMain.ShowContactForm;
begin
 FCurrentCEMode:=Mode;
 FCBMP.Canvas.CopyRect(Rect(0, 0, FCBMP.Width, FCBMP.Height), Canvas, Rect(0, 0, FCBMP.Width, FCBMP.Height));
 SetFrame(wfContact);
end;

procedure TFormMain.InsertGroupsToFavorite;
var i:Integer;
    Num:TCommonRec;
begin
 Num.FIO:=ConfName;
 Num.NumInteranl:=ConfNumber;
 Num.KodOtd:=-1;
 FavoriteNums.Add(Num);
 if GroupsNums.Count > 1 then
  for i:= 1 to GroupsNums.Count - 1 do
   begin
    Num:=NumberToCommon(GroupsNums[i]);
    Num.KodOtd:=-1;
    FavoriteNums.Add(Num);
   end;
 UpdateGridFavorite;
end;

procedure TFormMain.FilterOffice(Group:string);

procedure RunFilter;
var i:Integer;
begin
 FilteredOffice.Clear;
 if OfficeNums.Count <= 0 then Exit;
 if Group = '00' then
  begin
   FilteredOffice.AddRange(OfficeNums);
   Exit;
  end;

 for i:=0 to OfficeNums.Count-1 do
  begin
   if Group <> Copy(OfficeNums[i].NumInteranl, 1, 2) then Continue;
   FilteredOffice.Add(OfficeNums[i]);
  end;
end;

begin
 RunFilter;
 UpdateTableOffice;
end;

procedure TFormMain.FindWorkContact;
begin
 FThreadFindContact.Find;
end;

function TFormMain.SearchOffice(Text: string):Boolean;
var i:Integer;
begin
 Result:=False;
 if FilteredOffice.Count <= 0 then Exit;
 for i:= Min(Max(0, TableExOffice.ItemIndex+1), TableExOffice.ItemCount-1) to FilteredOffice.Count-1 do
  begin
   if FindText(Text, FilteredOffice[i].FIO) or
      FindText(Text, FilteredOffice[i].Position) or
      FindText(Text, FilteredOffice[i].Address) or
      FindText(Text, FilteredOffice[i].EMail) or
      FindText(Text, FilteredOffice[i].NumLandline) or
      FindText(Text, FilteredOffice[i].NumInteranl) or
      FindText(Text, FilteredOffice[i].NumCell)
   then
    begin
     TableExOffice.ItemIndex:=i;
     Exit(True);
    end;
  end;
 TableExOffice.ItemIndex:=0;
end;

function TFormMain.SearchDepart(Text: string):Boolean;
var i:Integer;
begin
 Result:=False;
 if DepartNums.Count <= 0 then Exit;
 for i:= Min(Max(0, TableExDepart.ItemIndex+1), TableExDepart.ItemCount-1) to DepartNums.Count-1 do
  begin
   if FindText(Text, DepartNums[i].FIO) or
      FindText(Text, DepartNums[i].Position) or
      FindText(Text, DepartNums[i].Address) or
      FindText(Text, DepartNums[i].EMail) or
      FindText(Text, DepartNums[i].NumLandline) or
      FindText(Text, DepartNums[i].NumInteranl) or
      FindText(Text, DepartNums[i].Name) or
      FindText(Text, DepartNums[i].NumCell)
   then
    begin
     TableExDepart.ItemIndex:=i;
     Exit(True);
    end;
  end;
 TableExDepart.ItemIndex:=0;
end;

procedure TFormMain.SendLog;
begin
 //
end;

procedure TFormMain.SendLogProc(MSG: string);
var STo, Head:string;
begin
 Head:=CutData(MSG);
 STo:=CutData(MSG);
 if STo <> CID then Exit;
 {TODO -ohemul -cЧат : Обработка отправки чата}
end;

procedure TFormMain.SetAlarm(Value:Boolean);
begin
 FAlarm:=Value;
 if Alarm then
  begin
   SpeedButtonKeepClaim.ImageIndex:=16;
   if GlobalState <> gsIdle then SetGlobalState(GlobalState);
   FTrayIconIndex:=26;
  end
 else
  begin
   SpeedButtonKeepClaim.ImageIndex:=15;
   FTrayIconIndex:=28;
   ShowBalloonHintMsg(AppDesc+' - Внимание', 'Включен режим "Не беспокоить"', bfWarning, ActionShowWindowExecute);
  end;
 if TrayIcon.IconIndex in [26, 28] then TrayIcon.IconIndex:=FTrayIconIndex;
end;

procedure TFormMain.SetShowWarnMissed(Value: Boolean);
begin
 FShowWarnMissed:=Value;
 if FShowWarnMissed then
      TrayIcon.IconIndex:=IconIndexMissed
 else TrayIcon.IconIndex:=TrayIconIndex;
end;

procedure TFormMain.DayChange;
var Item:TChatText;
begin
 Log('Новый день!!!');
 ActionReloadExecute(nil);
 if UDPServerChat.Active then ActionChatWhoThereExecute(nil);
 Item.FromNum:='$$DATE';
 Item.Date:=Now;
 Item.Color:=clWhite;
 ChatList.Add(Item);
 ListBoxChat.Items.Add('');
 WorkListDaySet;
end;

procedure TFormMain.DefaultHandler(var Msg);
begin
 inherited;
 if TMessage(Msg).Msg = WM_MSGSHOW then
  begin
   //Отобразить окно
   TMessage(Msg).Result:=0;
   ActionShowWindowExecute(nil);
  end;
 if TMessage(Msg).Msg = WM_MSGCLOSE then
  begin
   //Выход без запроса (параметры сохранятся)
   TMessage(Msg).Result:=0;
   Quit(False);
  end;
end;

procedure TFormMain.ImageAsteriskMutedDblClick(Sender: TObject);
begin
 ActionSettingsExecute(nil);
end;

procedure TFormMain.ImageChatClick(Sender: TObject);
begin
 SetCatalog(TabSheetChat);
end;

procedure TFormMain.ImageConStateDblClick(Sender: TObject);
begin
 ActionReconExecute(nil);
end;

procedure TFormMain.ImageDialGroupClick(Sender: TObject);
begin
 if ListBoxGroups.ItemIndex <= 0 then Exit;
 Dial(GroupsNums[ListBoxGroups.ItemIndex].NumInteranl);
end;

procedure TFormMain.ImageDialGroupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ImageListDialGroup.GetIcon(2, ImageDialGroup.Picture.Icon);
end;

procedure TFormMain.ImageDialGroupMouseEnter(Sender: TObject);
begin
 ImageListDialGroup.GetIcon(1, ImageDialGroup.Picture.Icon);
end;

procedure TFormMain.ImageDialGroupMouseLeave(Sender: TObject);
begin
 ImageListDialGroup.GetIcon(0, ImageDialGroup.Picture.Icon);
end;

procedure TFormMain.ImageDialGroupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ImageListDialGroup.GetIcon(1, ImageDialGroup.Picture.Icon);
end;

procedure TFormMain.ImageManMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button = mbRight then FormMain.ShowNumbersForButton(FormMain.CID);
end;

procedure TFormMain.Init;
var II:Integer;
begin
 //Проверка обновления
 SetLoadState('Проверка обновлений...');
 FCheckActualVersion(False);
 //Установка обновления
 if NewVerLink <> '' then RunUpdate(False);
 //Добавим программу в Брандмауэр Windows
 try
  AddFirewallException(AppDesc, Application.ExeName, True);
 except
  Log('except AddFirewallException '+SysErrorMessage(GetLastError));
 end;
 //Загрузка параметров и журналов
 SetLoadState('Чтение настроек пользователя...');
 LoadDataAndSettings;

 //Косметические костыли (после загрузки настроек)
 //Устанавливаем клиентский размер, т.к. ОС может изменить размер окна (размер рамки и т.д.)
 SetLoadState('Построение интерфейса...');
 ClientHeight:=550;
 ClientWidth:=938;

 PanelMenu.Left:=0;
 PanelMenu.Top:=0;
 PanelMenu.Height:=ClientHeight-PanelMenu.Top;
 PanelMenuState(True);
 PanelSettings.Width:=ClientWidth;
 PanelSettings.Left:=0;
 PanelSettings.Top:=0;
 PanelSettings.Height:=ClientHeight;
 PanelSettings.Visible:=False;
 PanelDialup.Width:=460;
 PanelDialup.Left:=478;
 DialupHide(False);
 PanelDownloading.Width:=393;
 PanelDownloading.Left:=ClientWidth div 2 - PanelDownloading.Width div 2;
 PageControlMain.Width:=(ClientWidth - PanelMenu.Width) + 8;
 PageControlMain.Left:=36;
 PanelChatHelp.Height:=460;
 PanelMenuClick.Visible:=False;
 PanelMenuClick.Width:=ClientWidth;
 PanelMenuClick.Height:=ClientHeight;
 PanelMenuClick.Left:=PanelMenu.Width;
 PanelMenuClick.Top:=0;
 PanelContactEdit.Left:=ClientWidth div 2 - PanelContactEdit.Width div 2;

 if WindScale <> 100 then FormMain.ScaleBy(WindScale, 90);
 PixelsPerInch:=96;

 StringGridGlobal.ColWidths[0]:=Round(StringGridGlobal.ClientWidth * (40/100));
 StringGridGlobal.ColWidths[1]:=Round(StringGridGlobal.ClientWidth * (40/100));
 StringGridGlobal.ColWidths[2]:=Round(StringGridGlobal.ClientWidth * (20/100));

 DrawGridWorkTime.ColWidths[0]:=DrawGridWorkTime.ClientWidth;
 DrawGridWorkTime.DefaultRowHeight:=(DrawGridWorkTime.ClientHeight) div DrawGridWorkTime.RowCount;
 WorkListDaySet;

 //Первичные загрузки
 SetLoadState('Загрузка журналов...');
 UpdateGridFavorite;
 UpdateJournal;
 //Сброс
 StateChange;
 GlobalState:=gsIdle;

 //Фильтруем журнал звонков по умолчанию
 ButtonJFResetClick(nil);
 //Загружаем данные из elix
 SetLoadState('Загрузка данных справочника...');
 ActionReloadExecute(nil);
 //Подключаемся к Asterisk
 SetLoadState('Подключение к Asterisk...');
 ActionReconExecute(nil);
 //Вставим отделы в избранное если оно пустое после загрузки
 if FavoriteNums.Count <= 0 then InsertGroupsToFavorite;
 SetLoadState('Почти готово');
 //Очистим эти данные
 SelectedNumber.FIO:='';
 SelectedNumber.Position:='';
 SelectedNumber.Address:='';
 SelectedNumber.EMail:='';
 SelectedNumber.NumLandline:='';
 SelectedNumber.NumCell:='';
 SelectedNumber.NumInteranl:='';
 SelectedNumber.RecType:=rtNumber;

 SelectedNumberExt.FIO:='';
 SelectedNumberExt.Position:='';
 SelectedNumberExt.Address:='';
 SelectedNumberExt.EMail:='';
 SelectedNumberExt.NumLandline:='';
 SelectedNumberExt.NumCell:='';
 SelectedNumberExt.NumInteranl:='';
 SelectedNumberExt.RecType:=rtNumber;

 SetSelectedNumber;
 II:=TrayIcon.IconIndex;
 TrayIcon.IconIndex:=26;
 TrayIcon.Visible:=True;
 TrayIcon.IconIndex:=II;
 ChatOff:=not StartChat;
 ActionChatClearExecute(nil);
 TimerStamp.Enabled:=True;
 TimerAutoConnect.Enabled:=True;
 if not FromAutorun then Sound(stStart);
 if CID = '' then ActionSettingsExecute(nil);
 SetFrame(wfMain);
 Initialized:=True;
end;

procedure TFormMain.EventIncomingCall(aNumber, aSubject, aChannel:string);
begin
 if Length(aNumber) = 10 then WorkCall.inNumber:='8'+aNumber else WorkCall.inNumber:=aNumber;
 if aSubject = aNumber then WorkCall.inSubject:=WorkCall.inNumber else WorkCall.inSubject:=aSubject;
 if WorkCall.inNumber <> '' then FindWorkContact;
 WorkCall.inChannel:=aChannel;
 WorkCall.inStart:=Now;
 WorkCall.inFinish:=Now;
 WorkCall.ItemType:=jtIncoming;
 WorkCall.EventCount:=1;
 GlobalState:=gsIncomingCall;
end;

procedure TFormMain.ActionJournalExecute(Sender: TObject);
begin
 ActionShowWindowExecute(nil);
 SetPage(TabSheetJournal);
 PanelMenuState(True);
end;

procedure TFormMain.UpdateChatSubject(MSG:string);
var From, FromName, F, I, O, Head:string;
begin
 Head:=CutData(MSG);
 From:=CutData(MSG);
 FromName:=CutData(MSG);
 if FromName = '' then FromName:='Аноним';
 if GetFIO(FromName, F, I, O) then FromName:=F+' '+I;
 GetFromColor(From, FromName);
end;

procedure TFormMain.CallToMe;
begin
 if MessageBox(Application.Handle, 'Обязательно помогут!'+#13+#10+'Позвонить программисту прямо сейчас?', 'Вопрос', MB_ICONINFORMATION or MB_YESNO) <> ID_YES then Exit;
 InsertNumber(APP_OIT_NUMBER);
end;

procedure TFormMain.Chat(CText:string);
var From, FromName, STo, F, I, O:string;
    Item:TChatText;
    Head:string;

begin
 Head:=CutData(CText);
 From:=CutData(CText);
 FromName:=CutData(CText);
 if FromName = '' then
  begin
   FromName:='Аноним';
  end;
 
 STo:=CutData(CText);
 if (STo <> '*') and (STo <> CID) and (STo <> AnonNum) and (From <> CID) and (From <> AnonNum) then Exit;

 if CText = '' then Exit;

 if GetFIO(FromName, F, I, O) then FromName:=F+' '+I;
 Item.From:=FromName;
 Item.Text:=CText;
 Item.FromNum:=From;
 Item.SendTo:=STo;
 Item.Date:=Now;
 Item.Color:=GetFromColor(From, FromName);

 ChatList.Add(Item);
 ListBoxChat.Items.Add('');
 ListBoxChat.Perform(WM_VSCROLL, SB_BOTTOM, 0);
 AllowMessage:=not ((PageControlCatalog.ActivePage = TabSheetChat) and (PageControlMain.ActivePage = TabSheetCatalog));
 if not ChatMute then
  begin
   if FChatNotify <> 2 then
    if Item.SendTo <> CID then Exit;
   Sound(stChat);
   if GetForegroundWindow <> Handle then
    begin
     FormMessage.LabelFIO.Caption:=Item.From;
     FormMessage.LabelMessage.Caption:=Item.Text;
     FormMessage.FormUp;
    end;
  end;
end;

procedure TFormMain.ChatSendEcho;
var From, FromName:string;
begin          
 try
  UDPClientChat.Active:=True;
 except
  begin
   Log('except UDPClientChat.Active:=True;');
   Exit;
  end;
 end;
 if (CID = '') then Exit;
 if not ChatAnon then
  begin
   From:=CID;
   FromName:=CIDName;
   if FromName = '' then FromName:=From;
  end
 else
  begin
   From:=AnonNum;
   FromName:=AnonName;
  end;
 UDPClientChat.Broadcast(UTF8EncodeToShortString(XORString(GetEchoStr(From, FromName), ChatXORKey)), NetPortChat, NetIPChat, IndyTextEncoding_UTF8);
 UDPClientChat.Active:=False;
end;

procedure TFormMain.ChatSend(CText, STo:string);
var From, FromName:string;
begin
 try
  UDPClientChat.Active:=True;
 except
  begin
   Chat(GetChatStr('error', 'Ошибка', SendForAll, 'Нет соединения'));
   Exit;
  end;
 end;
 if (CID = '') then
  begin
   Chat(GetChatStr('error', 'Ошибка', SendForAll, 'Номер не привязан'));
   Exit;
  end;
 if not ChatAnon then
  begin
   From:=CID;
   FromName:=CIDName;
   if FromName = '' then FromName:=From;
  end
 else
  begin
   From:=AnonNum;
   FromName:=AnonName;
  end;
 UDPClientChat.Broadcast(UTF8EncodeToShortString(XORString(GetChatStr(From, FromName, STo, CText), ChatXORKey)), NetPortChat, NetIPChat, IndyTextEncoding_UTF8);
 UDPClientChat.Active:=False;
end;

procedure TFormMain.ChatWhoThere;
begin
 try
  UDPClientChat.Active:=True;
 except
  begin
   Log('except UDPClientChat.Active:=True;');
   Exit;
  end;
 end;
 UDPClientChat.Broadcast(UTF8EncodeToShortString(XORString(GetWhoThereStr, ChatXORKey)), NetPortChat, NetIPChat, IndyTextEncoding_UTF8);
 UDPClientChat.Active:=False;
end;

procedure TFormMain.CheckActualVersion(InfoForNoAvailable:Boolean);
begin
 if CheckingVersion then Exit;
 Log('start CheckActualVersion');
 CheckingVersion:=True;
 try
  FCheckActualVersion(InfoForNoAvailable);
 except
  Log('except FCheckActualVersion');
 end;
 CheckingVersion:=False;
 Log('finish CheckActualVersion');
end;

procedure TFormMain.CheckBoxAsteriskMuteClick(Sender: TObject);
begin
 AsteriskMute:=CheckBoxAsteriskMute.Checked;
end;

procedure TFormMain.CheckBoxAutorunClick(Sender: TObject);
begin
 Autorun:=CheckBoxAutorun.Checked;
 CheckBoxAutorun.Checked:=Autorun;
end;

procedure TFormMain.CheckBoxUseAeroClick(Sender: TObject);
begin
 UseAeroColor:=CheckBoxUseAero.Checked;
 ColorSelectMenuForMenu.ColorValue:=MenuColor;
 ColorSelectMenu.ColorValue:=ButtonsColor;
end;

function TFormMain.CheckConnect:Boolean;
var ThreadID:Cardinal;
begin
 CheckingState:=True;
 CreateThread(nil, 0, @CheckADOConnection, nil, 0, ThreadID);
 while CheckingState and (not Application.Terminated) do
  begin
   Sleep(100);
   Application.ProcessMessages;
  end;
 CheckingState:=False;
 TerminateThread(ThreadID, 0);
 if not TrueConnection then Log(SysErrorMessage(GetLastError));
 
 Result:=TrueConnection;
end;

procedure TFormMain.FCheckActualVersion(InfoForNoAvailable:Boolean);
var //Query:TADOQuery;
    NEWVer:TAppVerison;
    nDesc:string;
    nLink:string;
    nCrit:Boolean;
   // ADOConnection:TADOConnection;
var Stream:TIdMultipartFormDataStream;
    s:string;
    PostData:TStringList;
    IdHTTP:TIdHTTP;
begin
 WriteLastRun;

 Stream:= TIdMultipartFormDataStream.Create;
 IdHTTP:=TIdHTTP.Create(nil);
 IdHTTP.Request.UserAgent:='UPDATESOFTLKDU';
 PostData:=TStringList.Create;
 try
  Stream.AddFormField('Act', 'GetData');
  Stream.AddFormField('FileName', APP_DB_NAME);
  IdHTTP.HTTPOptions:=IdHTTP.HTTPOptions + [hoNoProtocolErrorException];
  try
   PostData.Text:=IdHTTP.Post(APP_UPDATE_POST, Stream);
  except
   begin
    Log('except PostData.Text:=IdHTTP.Post('+APP_UPDATE_POST+', Stream);');
    if CheckUpdateError then
     begin
      CheckUpdateError:=False;
      ShowBalloonHintMsg('Внимание', 'Во время проверки обновлений произошла ошибка. Обратитесь в ОИТ!', bfError, CallToMe);
     end;
    Exit;
   end;
  end;

  if PostData.Count <= 0 then s:='FAILED' else s:=PostData[0];
  Log('Результат загрузки: "'+s+'"');
  if PostData.Count > 1 then
   begin
    try
     NEWVer.Major:=StrToInt(Copy(PostData[3], 1, Pos('.', PostData[3])-1));
     NEWVer.Minor:=StrToInt(Copy(PostData[3], Pos('.', PostData[3])+1, 10));
     nDesc:=PostData[5];
     nLink:=PostData[4];
     nCrit:=PostData[6] = '1';
    except
     begin
      Log('except Преобразование данных post-запроса обновлений');
      Exit;
     end;
    end;

    if (NEWVer.Major > Version.Major) or
      ((NEWVer.Major = Version.Major) and
       (NEWVer.Minor > Version.Minor))
    then
     begin
      NewVerLink:=nLink;
      NewVersionAvailable:=True;
      if InfoForNoAvailable then NotifyShowed:=False;
      NotifyForNewVersion(nLink, nDesc, nCrit, NEWVer);
     end;
   end;
 finally
  begin
   Stream.Free;
   PostData.Free;
   IdHTTP.Free;
  end;
 end;
 if (not NewVersionAvailable) and InfoForNoAvailable then
  begin
   MessageBox(Application.Handle, 'Вы используете последнюю версию программы!', '', MB_ICONINFORMATION or MB_OK);
  end;
 if NewVersionAvailable and InfoForNoAvailable then
  begin
   if MessageBox(Application.Handle, 'Доступны новые обновления. Установить сейчас?', 'Внимание', MB_ICONINFORMATION or MB_YESNO) <> ID_YES then Exit;
   if FormAbout.Visible then FormAbout.Close;
   Application.ProcessMessages;
   RunUpdate(True);
  end;
 {Exit;
 //
 if not CreateConnection(ADOConnection) then Exit;
 Log('Проверка обновлений');
 Query:=TADOQuery.Create(nil);
 Query.Connection:=ADOConnection;

 Query.SQL.Text:= 'SELECT TOP 1 [APP_VER_MINOR], [APP_VER_MAJOR], [APP_DESC], [APP_LINK], [APP_CRITICAL] FROM [elix].[dbo].[AppVer] WHERE [APP_NAME] = '+QuotedStr(APP_DB_NAME);
 try
  Query.Open;
  if Query.RecordCount > 0 then
   begin
    NEWVer.Major:=Query.Fields[1].AsInteger;
    NEWVer.Minor:=Query.Fields[0].AsInteger;
    nDesc:=Query.Fields[2].AsString;
    nLink:=Query.Fields[3].AsString;
    nCrit:=Boolean(Query.Fields[4].AsInteger);

    if (NEWVer.Major > Version.Major) or
      ((NEWVer.Major = Version.Major) and
       (NEWVer.Minor > Version.Minor))
    then
     begin
      NewVerLink:=nLink;
      NewVersionAvailable:=True;
      if InfoForNoAvailable then NotifyShowed:=False;
      NotifyForNewVersion(nLink, nDesc, nCrit, NEWVer);
     end;
   end;
 except
  Log('except Получаем версию программы Query.Open;');
 end;
 if (not NewVersionAvailable) and InfoForNoAvailable then
  begin
   MessageBox(Application.Handle, 'Вы используете последнюю версию программы!', '', MB_ICONINFORMATION or MB_OK);
  end;
 Query.Free;
 ADOConnection.Close;
 ADOConnection.Free;
 if NewVersionAvailable and InfoForNoAvailable then
  begin
   if MessageBox(Application.Handle, 'Доступны новые обновления. Установить сейчас?', 'Внимание', MB_ICONINFORMATION or MB_YESNO) <> ID_YES then Exit;
   if FormAbout.Visible then FormAbout.Close;
   Application.ProcessMessages;
   RunUpdate(True);
  end;}
end;

procedure TFormMain.ComboBoxChatNotifyChange(Sender: TObject);
begin
 FChatNotify:=ComboBoxChatNotify.ItemIndex;
 if FChatNotify = 0 then ChatMute:=True else ChatMute:=False;
end;

function TFormMain.ContactFIO(Number, Default:string):string;
var i:Integer;
    aText:string;
begin
 Result:=Default;
 if Length(Number) <= 0 then Exit;
 if Pos('+7', aText) = 1 then Delete(aText, 1, 2);
 aText:=GetNumberOnly(Number);
 if Length(aText) < 2 then Exit;

 if OtherNums.Count > 0 then
  begin
   for i:=0 to OtherNums.Count - 1 do
    begin
     if (GetNumberOnly(OtherNums[i].NumLandline) = aText) or
        (GetNumberOnly(OtherNums[i].NumCell) = aText) or
        (GetNumberOnly(OtherNums[i].NumInteranl) = aText)
     then Exit(OtherNums[i].FIO);
    end;
  end;

 if OfficeNums.Count > 0 then
  begin
   for i:=0 to OfficeNums.Count - 1 do
    begin
     if (GetNumberOnly(OfficeNums[i].NumLandline) = aText) or
        (GetNumberOnly(OfficeNums[i].NumCell) = aText) or
        (GetNumberOnly(OfficeNums[i].NumInteranl) = aText)
     then Exit(OfficeNums[i].FIO);
    end;
  end;

 if DepartNums.Count > 0 then
  begin
   for i:=0 to DepartNums.Count - 1 do
    begin
     if (GetNumberOnly(DepartNums[i].NumLandline) = aText) or
        (GetNumberOnly(DepartNums[i].NumCell) = aText) or
        (GetNumberOnly(DepartNums[i].NumInteranl) = aText)
     then Exit(DepartNums[i].FIO);
    end;
  end;

 if FavoriteNums.Count > 0 then
  begin
   for i:=0 to FavoriteNums.Count - 1 do
    begin
     if (GetNumberOnly(FavoriteNums[i].NumLandline) = aText) or
        (GetNumberOnly(FavoriteNums[i].NumCell) = aText) or
        (GetNumberOnly(FavoriteNums[i].NumInteranl) = aText)
     then Exit(FavoriteNums[i].FIO);
    end;
  end;

 if BranchNums.Count > 0 then
  begin
   for i:=0 to BranchNums.Count - 1 do
    begin
     if (GetNumberOnly(BranchNums[i].Number) = aText) or
        (GetNumberOnly(BranchNums[i].FAX) = aText)
     then Exit(BranchNums[i].Name);
    end;
  end;

 if BuyingNums.Count > 0 then
  begin
   for i:=0 to BuyingNums.Count - 1 do
    begin
     if (GetNumberOnly(BuyingNums[i].Number) = aText) or
        (GetNumberOnly(BuyingNums[i].FAX) = aText)
     then Exit(BuyingNums[i].Name);
    end;
  end;

 if BuyingSNums.Count > 0 then
  begin
   for i:=0 to BuyingSNums.Count - 1 do
    begin
     if (GetNumberOnly(BuyingSNums[i].Number) = aText) or
        (GetNumberOnly(BuyingSNums[i].FAX) = aText)
     then Exit(BuyingSNums[i].Name);
    end;
  end;

 if ShopsNums.Count > 0 then
  begin
   for i:=0 to ShopsNums.Count - 1 do
    begin
     if (GetNumberOnly(ShopsNums[i].Number) = aText) or
        (GetNumberOnly(ShopsNums[i].FAX) = aText)
     then Exit(ShopsNums[i].Name);
    end;
  end;
end;

procedure TFormMain.SetPage(Tab:TTabSheet);
begin
 PageControlMain.ActivePage:=Tab;
 if Tab = TabSheetPhone then ShowWarnMissed:=False; 
end;

procedure TFormMain.SetRunDate(Value: TDateTime);
var LRun:TDateTime;
    Y, M, D, D2:word;
begin
 LRun:=FRunDate;
 FRunDate:=Value;
 if not FFirstRun then
  begin
   DecodeDate(LRun, Y, M, D);
   DecodeDate(FRunDate, Y, M, D2);
   if D <> D2 then DayChange;
  end;
 FFirstRun:=False;
end;

procedure TFormMain.SetCatalog(Tab: TTabSheet);
begin
 PageControlCatalog.ActivePage:=Tab;
 if Tab = TabSheetOffice then SpeedButtonPageOffice.Font.Style:=[fsBold] else SpeedButtonPageOffice.Font.Style:=[];
 if Tab = TabSheetDeparts then SpeedButtonPageDeparts.Font.Style:=[fsBold] else SpeedButtonPageDeparts.Font.Style:=[];
 if Tab = TabSheetBranchs then SpeedButtonPageBranchs.Font.Style:=[fsBold] else SpeedButtonPageBranchs.Font.Style:=[];
 if Tab = TabSheetBuyings then SpeedButtonPageBuyings.Font.Style:=[fsBold] else SpeedButtonPageBuyings.Font.Style:=[];
 if Tab = TabSheetOther then SpeedButtonPageOther.Font.Style:=[fsBold] else SpeedButtonPageOther.Font.Style:=[];
 if Tab = TabSheetShops then SpeedButtonPageShops.Font.Style:=[fsBold] else SpeedButtonPageShops.Font.Style:=[];
 if Tab = TabSheetSearch then SpeedButtonPageSearch.Font.Style:=[fsBold] else SpeedButtonPageSearch.Font.Style:=[];
 if Tab = TabSheetChat then SpeedButtonPageChat.Font.Style:=[fsBold] else SpeedButtonPageChat.Font.Style:=[];
 UnselAll;
end;

procedure TFormMain.SetChatAnon(Value: Boolean);
begin
 FChatAnon:=Value;
 ActionChatAnon.Checked:=FChatAnon;
 case FChatAnon of
  False:
   begin
    ActionChatAnon.Hint:='Включить анонимную отправку сообщений';
   end;
  True:
   begin
    ActionChatAnon.Hint:='Отключить анонимную отправку сообщений';
   end;
 end;
end;

procedure TFormMain.SetChatMute(Value: Boolean);
begin
 FChatMute:=Value;
 ActionChatMute.Checked:=FChatMute;
 case FChatMute of
  True:
   begin
    ActionChatMute.Hint:='Включить уведомления чата';
    ComboBoxChatNotify.ItemIndex:=0;
   end;
  False:
   begin
    ActionChatMute.Hint:='Отключить уведомления чата';
    ComboBoxChatNotify.ItemIndex:=FChatNotify;
   end;
 end;
end;

procedure TFormMain.SetChatOff(Value: Boolean);
begin
 FChatOff:=Value;
 try
  UDPServerChat.Active:=not FChatOff;
  if UDPServerChat.Active then
   begin
    ChatSend('', '');
    ChatWhoThere;
   end;
 except
  begin
   Log('error UDPServerChat.Active');
   FChatOff:=UDPServerChat.Active;
  end;
 end;

 ActionChatOff.Checked:=FChatOff;
 case ActionChatOff.Checked of
  True:
   begin
    ActionChatOff.Caption:='Включить чат';
    ActionChatOff.Hint:='Возобновить работу чата'#13#10+
                        '-'#13#10+
                        'Вы будете видеть сообщения дргуих участников';
   end;
  False:
   begin
    ActionChatOff.Caption:='Отключить чат';
    ActionChatOff.Hint:='Отключить работу чата'#13#10+
                        '-'#13#10+
                        'Сообщения не будут приходить'#13#10+
                        'Отправка сообщений работать не перестанет';
   end;
 end;
end;

procedure TFormMain.SetCheckingVersion(Value:Boolean);
begin
 FCheckingVersion:=Value;
 if FCheckingVersion then
  begin
   LabelUpdating.Caption:='Проверка обновлений...';
   LabelUpdating.Hint:='';
   LabelUpdating.Cursor:=crDefault;
  end
 else
  begin
   if FNewVersionAvailable then
    begin
     LabelUpdating.Caption:='Доступна новая версия!';
     LabelUpdating.Hint:='Щёлкните, чтобы обновить';
     LabelUpdating.Cursor:=crHandPoint;
    end
   else
    begin
     LabelUpdating.Caption:='';
     LabelUpdating.Hint:='';
     LabelUpdating.Cursor:=crDefault;
    end;
  end;
 ImageAvailableUpdate.Visible:=FNewVersionAvailable;
end;

procedure TFormMain.SetFrame(Frame:TWindowFrame);
begin
 FCurrentFrame:=Frame;
 case Frame of
  wfMain:
   begin
    PanelMenuState(True);
    PanelSettings.Hide;

    PanelMenuClick.Left:=PanelMenu.Width;
    PanelMenuClick.Width:=ClientWidth-PanelMenuClick.Left;
    PanelMenuClick.Hide;

    PanelContactEdit.Hide;
   end;
  wfSettings:
   begin
    PanelMenuState(True);
    PanelMenuClick.Left:=PanelMenu.Width;
    PanelMenuClick.Width:=ClientWidth-PanelMenuClick.Left;
    PanelMenuClick.Hide;

    PanelContactEdit.Hide;

    PanelSettings.Show;
    PanelSettings.BringToFront;
    PanelSettings.SetFocus;
   end;
  wfContact:
   begin
    PanelMenuState(True);
    PanelSettings.Hide;

    PanelMenuClick.Left:=0;
    PanelMenuClick.Width:=ClientWidth-PanelMenuClick.Left;
    PanelMenuClick.Show;
    PanelMenuClick.BringToFront;

    PanelContactEdit.Show;
    PanelContactEdit.BringToFront;
    PanelContactEdit.SetFocus;
   end;
  wfMenu:
   begin
    PanelSettings.Hide;

    PanelContactEdit.Hide;

    PanelMenuClick.Left:=PanelMenu.Width;
    PanelMenuClick.Width:=ClientWidth-PanelMenuClick.Left;
    PanelMenuClick.Show;
    PanelMenuClick.BringToFront;

    PanelMenu.BringToFront;
   end;
 end;
end;

procedure TFormMain.SetNewVersionAvailable(Value:Boolean);
begin
 FNewVersionAvailable:=Value;
 SetCheckingVersion(FCheckingVersion);
end;

procedure TFormMain.PanelMenuState(Minimazed:Boolean);
begin
 if Minimazed then
  begin
   PanelMenu.Width:=40;
   PanelMenuClick.Visible:=False;
  end
 else
  begin
   FCBMP.Canvas.CopyRect(Rect(0, 0, FCBMP.Width, FCBMP.Height), Canvas, Rect(0, 0, FCBMP.Width, FCBMP.Height));
   //GBlur(FCBMP, 0.01);
   PanelMenu.Width:=250;
   SetFrame(wfMenu);
  end;
end;

procedure TFormMain.NewWish;
var ADOConnection:TADOConnection;
    Query:TADOQuery;
begin
 if FormWish.Visible then Exit;
 with FormWish do
  begin
   EditFromFIO.Text:=CIDName;
   EditFromGroup.Text:=CIDGroup;
   MemoWish.Clear;
   if ShowModal = mrOK then
    begin
     if not CreateConnection(ADOConnection) then Exit;
     Query:=TADOQuery.Create(nil);
     Query.Connection:=ADOConnection;
     Query.ExecuteOptions:=[eoExecuteNoRecords];
     Query.SQL.Text:='INSERT INTO AppWish ([AW_APP], [AW_FROM], [AW_FROMGROUP], [AW_WISH], [AW_DATE]) VALUES ('+
      QuotedStr(APP_DB_NAME)+', '+
      QuotedStr(EditFromFIO.Text)+', '+
      QuotedStr(EditFromGroup.Text)+', '+
      QuotedStr(MemoWish.Text)+', GETDATE())';
     try
      Query.ExecSQL();
     except
      Log('Ошибка при добавлении пожелания в elix');
     end;
     Query.Free;
     ADOConnection.Free;
    end;
  end;
end;

procedure TFormMain.NotifyForNewVersion(aLink, aDesc:string; aCritical:Boolean; NewVer:TAppVerison);
begin
 NewVerLink:=aLink;
 NewVerVers:=NewVer;
 NewVerDesc:=aDesc;
 NewVerCrit:=aCritical;
 //Покажем BalloonHint =)
 if not NotifyShowed then
  begin
   ShowBalloonHintMsg('Доступно обновление для '+AppDesc, 'Щёлкните, чтобы начать загрузку и установку обновления', TBalloonFlags(NIIF_NONE), TrayIconBalloonClick);
  end;
end;

procedure TFormMain.EditCCellInChange(Sender: TObject);
begin
 EditCCell.Text:=FieldToNumber(GetNumberOnly(EditCCellIn.Text));
end;

procedure TFormMain.EditChatSendKeyPress(Sender: TObject; var Key: Char);
begin
 if Key = #13 then
  begin
   Key:=#0;
   ButtonChatSendClick(nil);
  end;
 if Key = #8 then
  begin
   if EditChatSend.Text = '' then
    begin
     Key:=#0;
     ButtonChatSendTo.Hide;
    end;
  end;
end;

procedure TFormMain.EditCInternalInChange(Sender: TObject);
begin
 EditCIn.Text:=FieldToNumber(GetNumberOnly(EditCInternalIn.Text));
end;

procedure TFormMain.EditCLandInChange(Sender: TObject);
begin
 EditCLand.Text:=FieldToNumber(GetNumberOnly(EditCLandIn.Text));
end;

procedure TFormMain.EventDialing(aNumber, aSubject, aChannel:string; eventType:TJournalRecType);
begin
 if GlobalState = gsDialing then
  begin
   Log('ActionDialing GlobalState = gsDialing');
  end;

 if Length(aNumber) = 10 then WorkCall.inNumber:='8'+aNumber else WorkCall.inNumber:=aNumber;
 if aSubject = aNumber then WorkCall.inSubject:=WorkCall.inNumber else WorkCall.inSubject:=aSubject;
 if WorkCall.inNumber <> '' then FindWorkContact;
 WorkCall.inChannel:=aChannel;
 WorkCall.inStart:=Now;
 WorkCall.inFinish:=Now;
 WorkCall.ItemType:=eventType;
 WorkCall.EventCount:=1;
 GlobalState:=gsDialing;
end;

procedure TFormMain.ActionAboutExecute(Sender: TObject);
begin
 if FormAbout.Visible then Exit;
 FormAbout.Show;
end;

procedure TFormMain.ActionAddNumToFavExecute(Sender: TObject);
var Num:TCommonRec;
begin
 if EditMainNumber.Text <> '' then
  begin
   Num.NumInteranl:=FieldToNumber(EditMainNumber.Text);
   Num.FIO:=InputBox('Введите имя для избранной записи', 'Имя:', '');
   if Num.FIO <> '' then AddToFavorite(Num);
  end;
end;

procedure TFormMain.ActionChatAnonExecute(Sender: TObject);
begin
 ChatAnon:=not ChatAnon;
end;

procedure TFormMain.ActionChatClearExecute(Sender: TObject);
var i:Integer;
begin
 ChatList.Clear;
 ListBoxChat.Items.BeginUpdate;
 ListBoxChat.Items.Clear;
 ListBoxChat.Items.Add('');
 for i:= 0 to ChatList.Count - 2 do ListBoxChat.Items.Add('');
 ListBoxChat.Items.EndUpdate;
end;

procedure TFormMain.ActionChatExecute(Sender: TObject);
begin
 ActionShowWindowExecute(nil);
 SetPage(TabSheetCatalog);
 SetCatalog(TabSheetChat);
 PanelMenuState(True);
end;

procedure TFormMain.ActionChatMuteExecute(Sender: TObject);
begin
 ChatMute:=not ChatMute;
end;

procedure TFormMain.ActionChatOffExecute(Sender: TObject);
begin
 PanelChatHelp.Hide;
 ChatOff:=not ChatOff;
end;

procedure TFormMain.ActionChatWhoThereExecute(Sender: TObject);
begin
 if UDPServerChat.Active then
  begin
   ListBoxChatContact.Clear;
   FromColor.Clear;
   ChatWhoThere;
  end
 else MessageBox(Application.Handle, 'Чат выключен!', 'Внимание', MB_ICONINFORMATION or MB_OK);
end;

procedure TFormMain.EventDialup(aNumber, aSubject, aChannel:string; eventType:TJournalRecType);
begin
 if GlobalState = gsDial then
  begin
   Log('ActionDial exit GlobalState = gsDial');
   Exit;
  end;

 if Length(aNumber) = 10 then WorkCall.inNumber:='8'+aNumber else WorkCall.inNumber:=aNumber;
 if aSubject = aNumber then WorkCall.inSubject:=WorkCall.inNumber else WorkCall.inSubject:=aSubject;
 if WorkCall.inNumber <> '' then FindWorkContact;
 WorkCall.inChannel:=aChannel;
 WorkCall.inStart:=Now;
 WorkCall.inFinish:=WorkCall.inStart;
 WorkCall.ItemType:=eventType;
 WorkCall.EventCount:=1;
 GlobalState:=gsDial;
end;

procedure TFormMain.EventOnHangup(aCause:string; ToJR:Boolean);
var Skip:Boolean;
begin
 if GlobalState = gsIdle then
  begin
   Log('ActionOnHangup exit GlobalState = gsIdle');
   Exit;
  end;

 if WorkCall.fromNumber <> CID then
   begin
    if ToJR then
     begin
      Skip:=False;
      WorkCall.inFinish:=Now;
      if (GlobalState = gsIncomingCall) then
       begin
        WorkCall.ItemType:=jtMissed;
        if Journal.Count > 0 then
         begin
          if (Journal[0].inNumber = WorkCall.inNumber) and
             (Journal[0].fromNumber = WorkCall.fromNumber) and
             (Journal[0].ItemType = WorkCall.ItemType)
          then
           begin
            Skip:=True;
            WorkCall.EventCount:=Journal[0].EventCount + 1;
            WorkCall.inFinish:=Journal[0].inFinish;
           end;
         end;
       end;
      WorkCall.TimeDur:=TimeBetwen(WorkCall.inStart, WorkCall.inFinish);
      if not Skip then Journal.Insert(0, WorkCall)
      else Journal[0]:=WorkCall;


      if RedirectToJR then
       begin
        RedirectToJR:=False;
        Journal.Insert(0, RedirectJR);
       end;

      UpdateJournal;
     end;

    if (WorkCall.ItemType = jtMissed) and Alarm then
     begin
      ShowBalloonHintMsg(AppDesc+' - пропущенный звонок ('+IntToStr(WorkCall.EventCount)+')', 'Звонил(а) "'+WorkCall.inSubject+'"'#13#10'в '+TimeToStr(WorkCall.inStart), bfNone, ActionShowWindowExecute);
      ShowWarnMissed:=True;
     end;
   end;

 WorkCall.inExtenChannel:='';
 WorkCall.inSubject:='';
 WorkCall.inNumber:='';
 WorkCall.inChannel:='';
 WorkCall.EventCount:=1;
 GlobalState:=gsIdle;
end;

procedure TFormMain.ActionOtherAddExecute(Sender: TObject);
var ADOConnection:TADOConnection;
begin
 EditCFIO.Clear;
 EditCMail.Clear;
 EditCLandIn.Text:=EditMainNumber.Text;
 EditCInternalIn.Clear;
 EditCCellIn.Clear;
 CheckBoxShare.Checked:=True;
 MemoCComment.Clear;
 EditCPosition.Clear;
 EditCAddress.Clear;
 if not CreateConnection(ADOConnection) then
  begin
   MessageBox(Application.Handle, 'Нет соединения. Изменение контакта невозможно.', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 ADOConnection.Free;
 ShowContactForm(cemAdd);
 Exit;
 {if FormOtherEdit.Visible then Exit;
 with FormOtherEdit do
  begin
   EditCatalogFIO.Text:='';
   EditCatalogEMail.Text:='';
   EditCatalogNumLandline.Text:=EditMainNumber.Text;
   EditCatalogNumIn.Text:='';
   EditCatalogNumCell.Text:='';
   CheckBoxShare.Checked:=True;
   MemoComment.Clear;
   EditPosition.Clear;
   EditAddress.Clear;
   if not CreateConnection(ADOConnection) then
    begin
     MessageBox(Application.Handle, 'Нет соединения. Изменение контакта невозможно.', 'Внимание', MB_ICONWARNING or MB_OK);
     Exit;
    end;
   if ShowModal = mrOK then
    begin
     Query:=TADOQuery.Create(nil);
     Query.Connection:=ADOConnection;
     Query.ExecuteOptions:=[];
     Query.SQL.Text:='INSERT INTO sCallDop ([UserId], [NamePl], [Dolj], [Adr], [mail], [Tel1], [Tel2], [IPtel], [Comment], [xSha]) VALUES ('+
      QuotedStr(CID)+', '+
      QuotedStr(EditCatalogFIO.Text)+', '+
      QuotedStr(EditPosition.Text)+', '+
      QuotedStr(EditAddress.Text)+', '+
      QuotedStr(GetNumberOnly(EditCatalogEMail.Text))+', '+
      QuotedStr(GetNumberOnly(EditCatalogNumLandline.Text))+', '+
      QuotedStr(GetNumberOnly(EditCatalogNumCell.Text))+', '+
      QuotedStr(EditCatalogNumIn.Text)+', '+
      QuotedStr(MemoComment.Text)+', '+
      QuotedStr(IntToStr(Ord(not CheckBoxShare.Checked)-1))+')';
     Query.SQL.Add('SELECT @@IDENTITY');
     try
      Query.Open;
      ORec.nRecCallDop:=Query.Fields[0].AsInteger;
      ORec.UserID:=CID;
      ORec.FIO:=EditCatalogFIO.Text;
      ORec.Position:=EditPosition.Text;
      ORec.Address:=EditAddress.Text;
      ORec.EMail:=EditCatalogEMail.Text;
      ORec.NumLandline:=EditCatalogNumLandline.Text;
      ORec.NumCell:=EditCatalogNumCell.Text;
      ORec.NumInteranl:=EditCatalogNumIn.Text;
      ORec.Commnet:=MemoComment.Text;
      ORec.xSha:=CheckBoxShare.Checked;
      OtherNums.Add(ORec);
      ListBoxOther.Items.Add('');
     except
      Log('Ошибка при добавлении контакта в elix');
     end;
     Query.Free;
     ADOConnection.Free;
    end;
  end;   }
end;

procedure TFormMain.ActionHangup(aChannel:string);
begin
 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Hangup'+#13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Channel: '+aChannel+#13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Cause: 16'+#13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Priority: 1'+#13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Async: yes'+#13#10+#13#10));
end;

procedure TFormMain.UDPServerChatUDPRead(AThread: TIdUDPListenerThread; const AData: TIdBytes; ABinding: TIdSocketHandle);
var MSG:string;
begin
 DataIn:=DataIn+SizeOf(AData);
 MSG:=XORString(UTF8ToString(BytesToString(AData, IndyTextEncoding_UTF8)), ChatXORKey);
 if Pos(chatdata, MSG) <> 0 then
  begin
   Chat(MSG);
   Exit;
  end;
 if Pos(chatsendlog, MSG) <> 0 then
  begin
   SendLogProc(MSG);
   Exit;
  end;
 if Pos(chatecho, MSG) <> 0 then
  begin   
   UpdateChatSubject(MSG);
   Exit;
  end;              
 if Pos(chatwhothr, MSG) <> 0 then
  begin   
   ChatSendEcho;
   Exit;
  end;   
 Log('UDPServerChatUDPRead - unknown data');
end;

procedure TFormMain.UnselAll;
begin
 TableExOffice.ItemIndex:=-1;
 TableExDepart.ItemIndex:=-1;
 ListBoxDeparts.ItemIndex:=-1;
 ListBoxShops.ItemIndex:=-1;
 ListBoxBuyingDepart.ItemIndex:=-1;
 ListBoxOther.ItemIndex:=-1;
 IdSelectedB:=-1;
 CordDrawBuying.X:=-1;
 CordDrawBuying.Y:=-1;
 CordDrawBuyingS.X:=-1;
 CordDrawBuyingS.Y:=-1;
 IdSelectedBranch:=-1;
 CordDrawBranchs.X:=-1;
 CordDrawBranchs.Y:=-1;
 IdSelectedS:='';
 CordDrawShops.X:=-1;
 CordDrawShops.Y:=-1;

 StringGridGlobal.Selection:=TGridRect(Rect(-1, -1, -1, -1));
 DrawGridBranchs.Selection:=TGridRect(Rect(-1, -1, -1, -1));
 DrawGridBuyings.Selection:=TGridRect(Rect(-1, -1, -1, -1));
 DrawGridBuyingsS.Selection:=TGridRect(Rect(-1, -1, -1, -1));
 DrawGridShops.Selection:=TGridRect(Rect(-1, -1, -1, -1));
 ClearSelectedNumber;
end;

procedure TFormMain.UpdateAppCaption;
var ads:string;
begin
 ads:='';
 if CID <> '' then
  begin
   ads:=' - '+CID;
   if CIDName <> '' then ads:=' - '+CIDName+' - '+CID;
  end
 else ads:=' - Номер не установлен';
 Self.Caption:=AppDesc + ads;
end;

procedure TFormMain.UpdateGridFavorite;
begin
 DrawGridFavorite.RowCount:=(FavoriteNums.Count-1) div (DrawGridFavorite.ColCount) + 1;
 if DrawGridFavorite.RowCount > 13 then
  DrawGridFavorite.DefaultColWidth:=DrawGridFavorite.ClientWidth div (DrawGridFavorite.ColCount)
 else DrawGridFavorite.DefaultColWidth:=113;
end;

procedure TFormMain.UpdateGridGroup;
begin
 DrawGridGroup.RowCount:=GroupNums.Count;
 if DrawGridGroup.RowCount > 13 then
  DrawGridGroup.DefaultColWidth:=DrawGridGroup.ClientWidth
 else DrawGridGroup.DefaultColWidth:=133;
end;

procedure TFormMain.SetSelectedData(Data:TCommonRec);
begin
 if FUseMainSub then SelectedNumber:=Data else SelectedNumberExt:=Data;
 SetSelectedNumber;
end;

procedure TFormMain.SetSubjectData(Data:TBranchNumber);
begin
 if FUseMainSub then SelectedNumber:=BranchToCommon(Data) else SelectedNumberExt:=BranchToCommon(Data);
 SetSelectedNumber;
end;

procedure TFormMain.Settings;
begin
 EditNumber.Text:=CID;
 EditSecret.Text:='я полный идиот';
 TrackBarScale.Position:=WindScale;
 CheckBoxAutorun.Checked:=Autorun;
 CheckBoxAsteriskMute.Checked:=AsteriskMute;
 ColorSelectMenu.ColorValue:=ButtonsColor;
 ColorSelectMenuForMenu.ColorValue:=MenuColor;
 CheckBoxUseAero.Checked:=UseAeroColor;
 SetFrame(wfSettings);
end;

procedure TFormMain.SetUseAeroColor(Value: Boolean);
begin
 FUseAeroColor:=Value;
 case FUseAeroColor of
  True:
   begin
    MenuColor:=ColorDarker(GetAeroColor);
    ButtonsColor:=ColorLighter(GetAeroColor);
   end;
  False:
   begin
    MenuColor:=MenuColor;
    ButtonsColor:=ButtonsColor;
   end;
 end;
end;

procedure TFormMain.SetOtherData(Data:TOtherRec);
begin
 if FUseMainSub then SelectedNumber:=OtherToCommon(Data) else SelectedNumberExt:=OtherToCommon(Data);
 SetSelectedNumber;
end;

procedure TFormMain.WriteFavorits;
begin
 try
  WriteFavoritsCSV(ExtractFilePath(Application.ExeName)+'favorites.csv', Char(9), FavoriteNums);
 except
  Log('except WriteFavoritsCSV');
 end;
end;

procedure TFormMain.WriteJournal;
begin
 try
  WriteJournalCSV(ExtractFilePath(Application.ExeName)+'journal.csv', Char(9), Journal);
 except
  Log('except WriteJournalCSV');
 end;
end;

procedure TFormMain.WriteLastRun;
var Query:TADOQuery;
    UserName:string;
    MachineName:string;
    RID:Integer;
    ADOConnection:TADOConnection;
begin
 if not CreateConnection(ADOConnection) then Exit;
 Query:=TADOQuery.Create(nil);
 Query.Connection:=ADOConnection;
 UserName:=GetUserName;
 MachineName:=GetMachineName;
 //Получаем данные ломбардов
 Query.SQL.Text:= 'SELECT TOP 1 LR_ID FROM AppLR WHERE LR_AppName = '+QuotedStr(APP_DB_NAME)+' AND LR_UserName = '+QuotedStr(UserName)+' AND LR_MachineName = '+QuotedStr(MachineName);
 try
  Query.Open;
  if Query.RecordCount > 0 then
   begin
    RID:=Query.Fields[0].AsInteger;
    Query.Close;
    Query.ExecuteOptions:=[eoExecuteNoRecords];
    Query.SQL.Text:='UPDATE AppLR SET '+
                    'LR_LastRun = GETDATE(),'+
                    'LR_AppVersion = '+QuotedStr(GetAppVersionStr)+' '+
                    'WHERE LR_ID = '+QuotedStr(IntToStr(RID));
   end
  else
   begin
    Query.Close;
    Query.ExecuteOptions:=[eoExecuteNoRecords];
    Query.SQL.Text:= 'INSERT INTO AppLR (LR_AppName, LR_UserName, LR_MachineName, LR_LastRun, LR_AppVersion) '+
                     'VALUES ('+QuotedStr(APP_DB_NAME)+','
                               +QuotedStr(UserName)+','
                               +QuotedStr(MachineName)+','
                               +'GETDATE(),'
                               +QuotedStr(GetAppVersionStr)+')';
   end;
  Query.ExecSQL();
 except
  Log('except WriteLastRun');
 end;
 Query.Free;
 ADOConnection.Close;
 ADOConnection.Free;
end;

procedure TFormMain.InsertNumber(Number:string);
begin
 if GlobalState in [gsIncomingCall, gsDialing] then Exit;
 if Number = '' then Exit;
 EditMainNumber.Text:=GetNumberOnly(Number);
 Dial(EditMainNumber.Text);
end;

procedure TFormMain.SetSelectedNumber;
var Sel:TCommonRec;
begin
 if FUseMainSub then Sel:=SelectedNumber else Sel:=SelectedNumberExt;

 EditCatalogFIO.Text:=Sel.FIO;
 EditCatalogNumIn.Text:=Sel.NumInteranl;
 EditCatalogNumLandline.Text:=Sel.NumLandline;
 EditCatalogNumCell.Text:=Sel.NumCell;
 EditCatalogEMail.Text:=Sel.EMail;
 MemoCatalogPosition.Text:=Sel.Position;
 MemoCatalogAddress.Text:=Sel.Address;

 case Sel.RecType of
  rtNumber:
   begin
    if DrawGridWorkTime.Visible then DrawGridWorkTime.Hide;
    if MemoComment.Visible then MemoComment.Hide;
   end;
  rtBranch:
   begin
    FDrawWorkTimeList:=GetBranchWorkTimeList(Sel.PLAT);
    DrawGridWorkTime.Repaint;
    //GetBranchWorkTime(Sel.PLAT, StringGridWorkTime);
    if not DrawGridWorkTime.Visible then DrawGridWorkTime.Show;
    if MemoComment.Visible then MemoComment.Hide;
   end;
  rtOther:
   begin
    MemoComment.Text:=Sel.Commnet;
    if DrawGridWorkTime.Visible then DrawGridWorkTime.Hide;
    if not MemoComment.Visible then MemoComment.Show;
   end;
  rtDepart:
   begin
    if DrawGridWorkTime.Visible then DrawGridWorkTime.Hide;
    if MemoComment.Visible then MemoComment.Hide;
   end;
 end;

 EditCatalogNumLandline.Enabled:=EditCatalogNumLandline.Text <> '';
 ButtonDialLandline.Enabled:=EditCatalogNumLandline.Enabled and (FGlobalState in [gsIdle, gsDial]);
 ButtonToFavLandline.Enabled:=ButtonDialLandline.Enabled;

 EditCatalogNumIn.Enabled:=EditCatalogNumIn.Text <> '';
 ButtonDialInternal.Enabled:=EditCatalogNumIn.Enabled and (FGlobalState in [gsIdle, gsDial]);
 ButtonToFavInternal.Enabled:=ButtonDialInternal.Enabled;

 EditCatalogNumCell.Enabled:=EditCatalogNumCell.Text <> '';
 ButtonDialCell.Enabled:=EditCatalogNumCell.Enabled and (FGlobalState in [gsIdle, gsDial]);
 ButtonToFavCell.Enabled:=ButtonDialCell.Enabled;

 EditCatalogEMail.Enabled:=EditCatalogEMail.Text <> '';
 ButtonMailTo.Enabled:=EditCatalogEMail.Enabled;
end;

procedure TFormMain.AddToFavorite(Num:TCommonRec);
begin
 FavoriteNums.Add(Num);
 UpdateGridFavorite;
end;

procedure TFormMain.ApplicationEventsException(Sender: TObject; E: Exception);
begin
 Log('Упс, ошибка: '+E.Message+' ('+IntToStr(GetLastError)+')');
end;

procedure TFormMain.ApplicationEventsRestore(Sender: TObject);
begin
 ActionShowWindowExecute(nil);
end;

procedure TFormMain.UpdateJournal;
begin
 WriteJournal;
 TableExJournal.ItemCount:=Journal.Count;
 ButtonJournalFilterClick(nil);
end;

procedure TFormMain.UpdateTableOffice;
begin
 TableExOffice.ItemIndex:=-1;
 TableExOffice.ItemCount:=FilteredOffice.Count;
 TableExOffice.Repaint;
end;

procedure TFormMain.UpdateUnitsGrids;
begin
{ if DrawGridBranchs.RowCount > 21 then
  DrawGridBranchs.DefaultColWidth:=DrawGridBranchs.ClientWidth div (DrawGridBranchs.ColCount)
 else
  begin
   DrawGridBranchs.DefaultColWidth:=38;
   DrawGridBranchs.ColWidths[DrawGridBranchs.ColCount-1]:=37;
  end;

 if DrawGridBuyings.RowCount > 21 then
  DrawGridBuyings.DefaultColWidth:=DrawGridBuyings.ClientWidth div (DrawGridBuyings.ColCount)
 else
  begin
   DrawGridBuyings.DefaultColWidth:=38;
   DrawGridBuyings.ColWidths[DrawGridBuyings.ColCount-1]:=37;
  end;
 if DrawGridBuyingsS.RowCount > 21 then
  DrawGridBuyingsS.DefaultColWidth:=DrawGridBuyingsS.ClientWidth div (DrawGridBuyingsS.ColCount)
 else
  begin
   DrawGridBuyingsS.DefaultColWidth:=38;
   DrawGridBuyingsS.ColWidths[DrawGridBuyingsS.ColCount-1]:=37;
  end;

 if DrawGridShops.RowCount > 21 then
  DrawGridShops.DefaultColWidth:=DrawGridShops.ClientWidth div (DrawGridShops.ColCount)
 else
  begin
   DrawGridShops.DefaultColWidth:=38;
   DrawGridShops.ColWidths[DrawGridShops.ColCount-1]:=37;
  end;   }
 with DrawGridBranchs do
  begin
   DefaultColWidth:=ClientWidth div ColCount;
   ColWidths[ColCount-1]:=DefaultColWidth + (ClientWidth mod ColCount);
  end;
 with DrawGridBuyings do
  begin
   DefaultColWidth:=ClientWidth div ColCount;
   ColWidths[ColCount-1]:=DefaultColWidth + (ClientWidth mod ColCount);
  end;
 with DrawGridBuyingsS do
  begin
   DefaultColWidth:=ClientWidth div ColCount;
   ColWidths[ColCount-1]:=DefaultColWidth + (ClientWidth mod ColCount);
  end;
 with DrawGridShops do
  begin
   DefaultColWidth:=ClientWidth div ColCount;
   ColWidths[ColCount-1]:=DefaultColWidth + (ClientWidth mod ColCount);
  end;

 DrawGridBranchs.Repaint;
 DrawGridBuyings.Repaint;
 DrawGridBuyingsS.Repaint;
 DrawGridShops.Repaint;
end;

procedure TFormMain.UpdateTableDeparts;
begin
 TableExDepart.ItemIndex:=-1;
 TableExDepart.ItemCount:=DepartNums.Count;
 TableExDepart.Repaint;
end;

procedure TFormMain.ListBoxGroupsClick(Sender: TObject);
var Gr:string;
begin
 if ListBoxGroups.Count <= 0 then Exit;
 if ListBoxGroups.ItemIndex < 0 then Exit;

 Gr:=GroupsNums[ListBoxGroups.ItemIndex].NumInteranl;
 if Length(Gr) < 2 then Exit;
 Gr:=Copy(Gr, 1, 2);
 FilterOffice(Gr);
 ListBoxGroups.Repaint;
end;

procedure TFormMain.ListBoxGroupsDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var Offset:Integer;
    Sel:Boolean;
begin
 if ((Control as TListBox).ItemIndex = Index) then
  begin
   Sel:=True;                                   //
   (Control as TListBox).Canvas.Brush.Color:=clLISelect;//MixColors((Control as TListBox).Canvas.Brush.Color, clLISelect, 100);
   (Control as TListBox).Canvas.Font.Style:=[fsBold];
   Offset:=ButtonDialGroup.Width + 4;
  end
 else
  begin
   Sel:=False;
   (Control as TListBox).Canvas.Brush.Color:=(Control as TListBox).Color;
   (Control as TListBox).Canvas.Font.Style:=[];
   Offset:=0;
  end;
 (Control as TListBox).Canvas.FillRect(Rect);

 //Наименование
 if Sel then (Control as TListBox).Canvas.Font.Color:=clWhite
 else        (Control as TListBox).Canvas.Font.Color:=$00444444;
 (Control as TListBox).Canvas.TextOut(Rect.Left+6, Rect.Top + 5, GroupsNums[Index].FIO);

 if Index <> 0 then
  begin
   //Номер
   if Sel then (Control as TListBox).Canvas.Font.Color:=clWhite
   else        (Control as TListBox).Canvas.Font.Color:=$00707070;
   (Control as TListBox).Canvas.TextOut(Rect.Width - (Control as TListBox).Canvas.TextWidth(GroupsNums[Index].NumInteranl) - 3 - Offset, Rect.Top + 5, GroupsNums[Index].NumInteranl);
  end;
               {
 //Линия границы
 (Control as TListBox).Canvas.Pen.Color:=MixColors((Control as TListBox).Canvas.Brush.Color, $00CCCCCC, 100);
 (Control as TListBox).Canvas.MoveTo(Rect.Left, Rect.Bottom-1);
 (Control as TListBox).Canvas.LineTo(Rect.Right, Rect.Bottom-1);    }

 ButtonDialGroup.Visible:=PtInRect(ListBoxGroups.ClientRect, ListBoxGroups.ItemRect(ListBoxGroups.ItemIndex).TopLeft) and (ListBoxGroups.ItemIndex <> 0);
 ButtonDialGroup.Height:=ListBoxGroups.ItemHeight-4;
 ButtonDialGroup.Left:=ListBoxGroups.Left+ListBoxGroups.ClientWidth - (ButtonDialGroup.Width + 1);
 ButtonDialGroup.Top:=ListBoxGroups.Top+ListBoxGroups.ItemRect(ListBoxGroups.ItemIndex).Top+1;
 if ListBoxGroups.ItemIndex > 0 then
  ButtonDialGroup.Hint:='Позвонить в "'+GroupsNums[ListBoxGroups.ItemIndex].FIO+'"';
end;

procedure TFormMain.ListBoxGroupsMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 ListBoxGroups.Repaint;
end;

procedure TFormMain.LabelUpdatingMouseEnter(Sender: TObject);
begin
 if NewVersionAvailable then LabelUpdating.Font.Style:=[fsUnderline];
end;

procedure TFormMain.LabelUpdatingMouseLeave(Sender: TObject);
begin
 LabelUpdating.Font.Style:=[];
end;

procedure TFormMain.LeftSideSet(LS:TLeftSideType);
begin
 case LS of
  lsSubject:
   begin
    if not PanelCard.Visible then PanelCard.Visible:=True;
    if PanelChatContact.Visible then PanelChatContact.Visible:=False;
   end;
  lsChatContact: 
   begin
    if not PanelChatContact.Visible then PanelChatContact.Visible:=True;
    if PanelCard.Visible then PanelCard.Visible:=False;
   end;
 end;
end;

procedure TFormMain.ListBoxBuyingDepartClick(Sender: TObject);
begin
 (Sender as TListBox).Repaint;
 if (Sender as TListBox).ItemIndex < 0 then Exit;
 case (Sender as TListBox).Tag of
  1:
   begin
    SetSelectedData(DepartToCommon(DepartBuyNums[(Sender as TListBox).ItemIndex]));
    IdSelectedB:=DepartBuyNums[(Sender as TListBox).ItemIndex].KodOtd;
    GridUnselect(DrawGridBuyings);
    GridUnselect(DrawGridBuyingsS);
    DrawGridBuyings.Repaint;
    DrawGridBuyingsS.Repaint;
   end;
  2:
   begin
    SetSelectedData(DepartToCommon(DepartNums[(Sender as TListBox).ItemIndex]));
    IdSelectedBranch:=DepartNums[(Sender as TListBox).ItemIndex].KodOtd;
    GridUnselect(DrawGridBranchs);
    DrawGridBranchs.Repaint;
   end;
  3:
   begin
    SetSubjectData(ShopsNums[(Sender as TListBox).ItemIndex]);
    IdSelectedS:=ShopsNums[(Sender as TListBox).ItemIndex].BranchNum;
    GridUnselect(DrawGridShops);
    DrawGridShops.Repaint;
   end;
 end;
end;

procedure TFormMain.ListBoxBuyingDepartDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var Sel:Boolean;
begin
 (Control as TListBox).Canvas.Brush.Style:=bsSolid;
 if ((Control as TListBox).ItemIndex = Index) then
  begin
   Sel:=True;
   (Control as TListBox).Canvas.Brush.Color:=clLISelect;//MixColors((Control as TListBox).Canvas.Brush.Color, clLISelect, 100);
   (Control as TListBox).Canvas.Font.Style:=[fsBold];
  end
 else
  begin
   Sel:=False;
   (Control as TListBox).Canvas.Brush.Color:=clWhite;
   (Control as TListBox).Canvas.Font.Style:=[];
  end;
 (Control as TListBox).Canvas.FillRect(Rect);

 if (Control as TListBox).Tag in [1, 2] then
  begin
   if (Control as TListBox).Tag = 1 then (Control as TListBox).Canvas.Brush.Color:=DepartBuyNums[Index].Color
   else
   if (Control as TListBox).Tag = 2 then (Control as TListBox).Canvas.Brush.Color:=DepartNums[Index].Color;

   (Control as TListBox).Canvas.FillRect(Classes.Rect(Rect.Left, Rect.Top, Rect.Left+5, Rect.Bottom));
  end;

 (Control as TListBox).Canvas.Brush.Style:=bsClear;
 //Наименование
 if Sel then (Control as TListBox).Canvas.Font.Color:=clWhite
 else        (Control as TListBox).Canvas.Font.Color:=$00444444;

 case (Control as TListBox).Tag of
  1:(Control as TListBox).Canvas.TextOut(Rect.Left+6, Rect.Top + 5, DepartBuyNums[Index].Name);
  2:(Control as TListBox).Canvas.TextOut(Rect.Left+6, Rect.Top + 5, DepartNums[Index].Name);
  3:(Control as TListBox).Canvas.TextOut(Rect.Left+6, Rect.Top + 5, ShopsNums[Index].Name);
 end;

 //Номер
 if Sel then (Control as TListBox).Canvas.Font.Color:=clWhite
 else        (Control as TListBox).Canvas.Font.Color:=$00969696;
 (Control as TListBox).Canvas.Font.Style:=[];
 case (Control as TListBox).Tag of
  1:(Control as TListBox).Canvas.TextOut(Rect.Width - (Control as TListBox).Canvas.TextWidth(DepartBuyNums[Index].NumLandline) - 3, Rect.Top + 5, DepartBuyNums[Index].NumLandline);
  2:(Control as TListBox).Canvas.TextOut(Rect.Width - (Control as TListBox).Canvas.TextWidth(DepartNums[Index].NumLandline) - 3, Rect.Top + 5, DepartNums[Index].NumLandline);
  3:(Control as TListBox).Canvas.TextOut(Rect.Width - (Control as TListBox).Canvas.TextWidth(ShopsNums[Index].Number) - 3, Rect.Top + 5, ShopsNums[Index].Number);
 end;

 //Линия границы
 (Control as TListBox).Canvas.Pen.Color:=MixColors((Control as TListBox).Canvas.Brush.Color, $00CCCCCC, 100);
 (Control as TListBox).Canvas.MoveTo(Rect.Left, Rect.Bottom-1);
 (Control as TListBox).Canvas.LineTo(Rect.Right, Rect.Bottom-1);
end;

procedure TFormMain.ListBoxBuyingDepartMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var i:Integer;
begin
 i:=(Sender as TListBox).ItemAtPos(Point(X, Y), True);
 if i >= 0 then
  begin
   case (Sender as TListBox).Tag of
    1:(Sender as TListBox).Hint:=DepartBuyNums.Items[i].NumLandline;
    2:(Sender as TListBox).Hint:=DepartNums.Items[i].NumLandline;
    3:(Sender as TListBox).Hint:=ShopsNums.Items[i].Number;
   end;
  end
 else (Sender as TListBox).Hint:='';
 if (ssLeft in Shift) or (ssRight in Shift) then (Sender as TListBox).Repaint;
end;

procedure TFormMain.ListBoxChatClick(Sender: TObject);
begin
 ListBoxChat.Repaint;
end;

procedure TFormMain.ListBoxChatContactClick(Sender: TObject);
begin
 ListBoxChatContact.Repaint;
end;

procedure TFormMain.ListBoxChatContactDblClick(Sender: TObject);
begin
 if ListBoxChatContact.ItemIndex >= 0 then
  begin
   if (FromColor[ListBoxChatContact.ItemIndex].Num = CID) or
      (FromColor[ListBoxChatContact.ItemIndex].Num = '') or
      (FromColor[ListBoxChatContact.ItemIndex].Num = AnonNum)
   then Exit;
   ButtonChatSendTo.Hint:=FromColor[ListBoxChatContact.ItemIndex].Num;
   ButtonChatSendTo.Caption:=FromColor[ListBoxChatContact.ItemIndex].Name+',';
   ButtonChatSendTo.Visible:=True;
   ButtonChatSendTo.Width:=Length(ButtonChatSendTo.Caption) * 8;
   ActiveControl:=EditChatSend;
   EditChatSend.SelStart:=Length(EditChatSend.Text);
  end;
end;

procedure TFormMain.ListBoxChatContactDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var str:string;
    Offset:Integer;
begin
 if (Index > FromColor.Count - 1) or (Index < 0) then Exit;
 with (Control as TListBox).Canvas do
  begin
   Brush.Color:=ColorLighter(clGray, 70);
   if ((Control as TListBox).ItemIndex = Index) then Brush.Color:=MixColors(Brush.Color, $00C6C6C6, 100);
   Pen.Color:=Brush.Color;
   Pen.Style:=psSolid;
   FillRect(Rect);
   Brush.Color:=FromColor[Index].Color;
   FillRect(Classes.Rect(Rect.Left, Rect.Top, 5, Rect.Bottom));
   Brush.Style:=bsClear;
   Offset:=Rect.Left + 6;
   //Имя
   if (FromColor[Index].Num = CID)
   then
    begin
     str:='Вы'
    end
   else
   if (FromColor[Index].Num = AnonNum)
   then str:='Вы (аноним)'
   else str:=FromColor[Index].Name;
   Font.Color:=clBlack;//FromColor[Index].Color;
   Font.Style:=[fsBold];
   TextOut(Offset, Rect.Top + 1, str);

   Font.Color:=ColorLighter(clBlack, 20);
   Font.Style:=[];
   TextOut(Offset, Rect.Top + Rect.Height div 2, FromColor[Index].Num);

   //Линия границы
   Pen.Color:=MixColors(Brush.Color, $00CCCCCC, 100);
   MoveTo(Rect.Left, Rect.Bottom-1);
   LineTo(Rect.Right, Rect.Bottom-1);
  end;
end;

procedure TFormMain.ListBoxChatDblClick(Sender: TObject);
begin
 if ChatList.Count <= 0 then Exit;
 if ListBoxChat.ItemIndex >= 0 then
  begin
   if (ChatList[ListBoxChat.ItemIndex].FromNum = CID) or
      (ChatList[ListBoxChat.ItemIndex].FromNum = '') or
      (ChatList[ListBoxChat.ItemIndex].FromNum = AnonNum)
   then Exit;
   ButtonChatSendTo.Hint:=ChatList[ListBoxChat.ItemIndex].FromNum;
   ButtonChatSendTo.Caption:=ChatList[ListBoxChat.ItemIndex].From+',';
   ButtonChatSendTo.Visible:=True;
   ButtonChatSendTo.Width:=Length(ButtonChatSendTo.Caption) * 8;
   ActiveControl:=EditChatSend;
   EditChatSend.SelStart:=Length(EditChatSend.Text);
  end;
end;

procedure TFormMain.ListBoxChatDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var str:string;
    Offset:Integer;
    ItemColor:TColor;
    FontColor:TColor;
begin
 if ChatList.Count = 0 then
  begin
   with (Control as TListBox).Canvas do
    begin
     Brush.Color:=ColorLighter($00F5FCF9, 70);
     Pen.Color:=Brush.Color;
     Pen.Style:=psSolid;
     FillRect(Rect);

     str:='Чат пуст. Напишите что-нибудь в общий чат или выберите кого-нибудь из списка (Двойной клик)';
     //Дата записи
     Font.Color:=$007A7A7A;
     Font.Style:=[fsItalic];
     TextOut(Rect.Left + (Rect.Width div 2 - TextWidth(Str) div 2), Rect.Top + (Rect.Height div 2 - TextHeight(Str) div 2), str);
     Exit;
    end;
  end;

 if Index > ChatList.Count - 1 then Exit;
 with (Control as TListBox).Canvas do
  begin
   if ChatList[Index].FromNum = '$$DATE' then
    begin
     Brush.Color:=ColorLighter($00F5FCF9, 70);
    // if ((Control as TListBox).ItemIndex = Index) then Brush.Color:=MixColors(Brush.Color, $00C6C6C6, 100);
     Pen.Color:=Brush.Color;
     Pen.Style:=psSolid;
     FillRect(Rect);

     str:='';
     if DateToStr(Now) = DateToStr(ChatList[Index].Date) then str:='Сегодня'
     else
      if DateToStr(Now-1) = DateToStr(ChatList[Index].Date) then str:='Вчера'
      else
       if DateToStr(Now-2) = DateToStr(ChatList[Index].Date) then str:='Позавчера'
       else str:=FormatDateTime('DD MMMM YY', ChatList[Index].Date);
     //Дата записи
     Font.Color:=$007A7A7A;
     Font.Style:=[fsItalic];
     TextOut(Rect.Left + (Rect.Width div 2 - TextWidth(Str) div 2), Rect.Top + (Rect.Height div 2 - TextHeight(Str) div 2), str);
     Exit;
    end;

   if (ChatList[Index].FromNum = CID) or (ChatList[Index].FromNum = AnonNum) then
    begin
     ItemColor:=clWhite;
     FontColor:=$00333333;
    end
   else
    begin
     if ChatList[Index].SendTo <> '*' then
      ItemColor:=ColorLighter(ChatList[Index].Color, 90)
     else ItemColor:=ColorLighter(ChatList[Index].Color, 70);
     FontColor:=ChatList[Index].Color;
    end;
   Brush.Color:=ItemColor;

   if ((Control as TListBox).ItemIndex = Index) then
    Brush.Color:=MixColors(Brush.Color, $00C6C6C6, 100);
   Pen.Color:=Brush.Color;
   Pen.Style:=psSolid;
   FillRect(Rect);


   //Дата записи
   str:='';
   Offset:=Rect.Left + 3;
   if DateToStr(Now) = DateToStr(ChatList[Index].Date) then str:=FormatDateTime('HH:MM', ChatList[Index].Date)
   else
    if DateToStr(Now-1) = DateToStr(ChatList[Index].Date) then str:='Вчера в '+FormatDateTime('HH:MM', ChatList[Index].Date)
    else
     if DateToStr(Now-2) = DateToStr(ChatList[Index].Date) then str:='Позавчера в '+FormatDateTime('HH:MM', ChatList[Index].Date)
     else str:=FormatDateTime('DD.MM.YYYY в HH:MM', ChatList[Index].Date);
   str:=str+' - ';
   //Дата записи
   Font.Color:=$007A7A7A;
   Font.Style:=[fsItalic];
   TextOut(Offset, Rect.Top + 1, str);
   Offset:=TextWidth(str+' ');

   //От кого
   if (ChatList[Index].FromNum = CID) or (ChatList[Index].FromNum = AnonNum) then str:='Вы'
   else str:=ChatList[Index].From;
   if ChatList[Index].SendTo = CID then str:='Лично от '+GetFromName(ChatList[Index].FromNum)
   else
   if ChatList[Index].SendTo <> '*' then str:='Вы, лично для '+GetFromName(ChatList[Index].SendTo);

   Font.Color:=FontColor;
   Font.Style:=[fsBold];
   TextOut(Offset, Rect.Top + 1, str);

   Font.Color:=ColorLighter(clBlack, 20);
   Font.Style:=[];
   TextOut(Rect.Left + 3, Rect.Top + Rect.Height div 2, ChatList[Index].Text);

   //Линия границы
   Pen.Color:=MixColors(Brush.Color, $00CCCCCC, 100);
   MoveTo(Rect.Left, Rect.Bottom-1);
   LineTo(Rect.Right, Rect.Bottom-1);
  end;
end;

procedure TFormMain.ListBoxChatMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 //ListBoxChat.Repaint;
 (Sender as TListBox).ItemIndex:=(Sender as TListBox).ItemAtPos(Point(X, Y), True);
 (Sender as TListBox).OnClick(Sender);
end;

procedure TFormMain.ListBoxChatMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 if (ssLeft in Shift) or (ssRight in Shift) then (Sender as TListBox).Repaint;
end;

procedure TFormMain.ListBoxChatMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if ChatList.Count <= 0 then Exit;
 if ListBoxChat.ItemIndex < 0 then Exit;
 if Button = mbRight then PopupMenuChatList.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.ListBoxOtherClick(Sender: TObject);
begin
 (Sender as TListBox).Repaint;
 if (Sender as TListBox).ItemIndex < 0 then Exit;
 SetOtherData(OtherNums[(Sender as TListBox).ItemIndex]);
end;

procedure TFormMain.ListBoxOtherDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var Sel:Boolean;
begin
 if Index mod 2 = 0 then (Control as TListBox).Canvas.Brush.Color:=clWhite
 else (Control as TListBox).Canvas.Brush.Color:=ColorDarker(clWhite, 3);

 if ((Control as TListBox).ItemIndex = Index) then
  begin
   Sel:=True;
   (Control as TListBox).Canvas.Brush.Color:=clLISelect;//MixColors((Control as TListBox).Canvas.Brush.Color, $00B8F1E5, 100);
   (Control as TListBox).Canvas.Font.Style:=[fsBold];
  end
 else
  begin
   Sel:=False;
   (Control as TListBox).Canvas.Font.Style:=[];
  end;
 (Control as TListBox).Canvas.FillRect(Rect);

 //Наименование
 if Sel then (Control as TListBox).Canvas.Font.Color:=clWhite
 else        (Control as TListBox).Canvas.Font.Color:=$00444444;
 (Control as TListBox).Canvas.TextRect(Classes.Rect(Rect.Left, Rect.Top, Rect.Left+190, Rect.Bottom), Rect.Left+2, Rect.Top + 5, OtherNums[Index].FIO);

 //Коммент
 if Sel then (Control as TListBox).Canvas.Font.Color:=clWhite
 else        (Control as TListBox).Canvas.Font.Color:=$00656565;
 (Control as TListBox).Canvas.TextRect(Classes.Rect(Rect.Left+200, Rect.Top, Rect.Left+565, Rect.Bottom), Rect.Left+200, Rect.Top + 5, OtherNums[Index].Commnet);

 //Видимость записи
 if OtherNums[Index].xSha then (Control as TListBox).Canvas.Draw(Rect.Right-20, Rect.Top+(Rect.Height div 2 - 8), ShareIco);
end;

procedure TFormMain.ListBoxOtherMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 (Sender as TListBox).ItemIndex:=(Sender as TListBox).ItemAtPos(Point(X, Y), True);
 (Sender as TListBox).OnClick(Sender);
end;

procedure TFormMain.ListBoxOtherMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 if (ssLeft in Shift) or (ssRight in Shift) then (Sender as TListBox).Repaint;
end;

procedure TFormMain.ListBoxOtherMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if ListBoxOther.ItemIndex < 0 then Exit;
 if Button = mbRight then PopupMenuOther.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.LoadDataAndSettings;
var Config:TIniFile;
    CIDMD5:string;
begin
 if not FileExists(ExtractFilePath(Application.ExeName) + ConfigFN) then Autorun:=True;
 Config:=TIniFile.Create(ExtractFilePath(Application.ExeName) + ConfigFN);
 try
  try
   CID:=Config.ReadString('GENERAL', 'CID', '');
   {TODO -oMalinin -cGeneral : Проверка MD5 номера}
   {if CID <> '' then
    begin
     CIDMD5:=Config.ReadString('GENERAL', 'Data', '');
     if AnsiUpperCase(MD5(CID)) <> AnsiUpperCase(CIDMD5) then
      begin
       CID:='';
       Log('CCID: '+MD5(CID)+' <> SCID: '+CIDMD5);
      end;
    end;        }
   Alarm:=Config.ReadBool('GENERAL', 'Alarm', True);
   AsteriskMute:=Config.ReadBool('GENERAL', 'AsteriskMute', False);
   FormMain.Left:=Config.ReadInteger('GENERAL', 'Left', Screen.Width div 2 - FormMain.Width div 2);
   FormMain.Top:=Config.ReadInteger('GENERAL', 'Top', Screen.Height div 2 - FormMain.Height div 2);
   WindScale:=Config.ReadInteger('GENERAL', 'WindScale', 100);
   if (WindScale < 80) or (WindScale > 120) then WindScale:=100;
   ButtonsColor:=Config.ReadInteger('GENERAL', 'ButtonsColor', ColorLighter(GetAeroColor));
   MenuColor:=Config.ReadInteger('GENERAL', 'MenuColor', clNone);
   if MenuColor = clNone then
    begin
     ButtonsColor:=clDefMenuButtons;
     MenuColor:=clDefMenu;
    end;
   UseAeroColor:=Config.ReadBool('GENERAL', 'UseAeroColor', True);
   FSortOtherBy:=Config.ReadInteger('GENERAL', 'FSortOtherBy', 0);
   FSortOtherASC:=Config.ReadBool('GENERAL', 'FSortOtherASC', False);

   ActionSortOtherASC.Checked:=FSortOtherASC;
   ActionSortOtherDESC.Checked:=not FSortOtherASC;

   ActionSortOtherName.Checked:= FSortOtherBy = 0;
   ActionSortOtherComment.Checked:= FSortOtherBy <> 0;

   FChatNotify:=Config.ReadInteger('GENERAL', 'ChatNotify', 2);
   ComboBoxChatNotify.ItemIndex:=FChatNotify;
   StartChat:=not Config.ReadBool('GENERAL', 'ChatOff', True);
   ChatMute:=Config.ReadBool('GENERAL', 'ChatMute', False);
   ChatAnon:=Config.ReadBool('GENERAL', 'ChatAnon', False);
   ShowChatHelp:=Config.ReadBool('GENERAL', 'ShowChatHelp', True);
   if Config.ReadBool('GENERAL', 'RemoveUpdate', True) then
    begin
     DeleteFile(ExtractFilePath(Application.ExeName) + 'update.exe');
     Config.WriteBool('GENERAL', 'RemoveUpdate', False);
    end;
   //На страницу
   //PageControlCatalog.ActivePageIndex:=Config.ReadInteger('USER', 'Catalog.ActivePageIndex', 0);
   //PageControlMain.ActivePageIndex:=Config.ReadInteger('USER', 'Main.ActivePageIndex', 1);
   SetPage(TabSheetCatalog);
   SetCatalog(TabSheetOffice);

   PanelLearn1.Visible:=Config.ReadBool('USER', 'Learn1', True);
   PanelTutorialHelp.Visible:=Config.ReadBool('USER', 'Learn2', True);
  finally
   Config.Free;
  end;
 except
  Log('except Config read');
 end;

 try
  if FileExists(ExtractFilePath(Application.ExeName)+'favorites.csv') then
   ReadFavoritsCSV(ExtractFilePath(Application.ExeName)+'favorites.csv', Char(9), FavoriteNums);
 except
  Log('except ReadFavoritsCSV read');
 end;
 try
  if FileExists(ExtractFilePath(Application.ExeName)+'journal.csv') then
   ReadJournalCSV(ExtractFilePath(Application.ExeName)+'journal.csv', Char(9), Journal);
 except
  Log('except ReadJournalCSV read');
 end;

 if CID = '' then
  begin
   CID:=GetADNumber;
   if CID = '' then
    begin
     CID:='';
     CIDMD5:='';
     //ActionSettingsExecute(nil);
    end;
  end;
end;

procedure TFormMain.SaveDataAndSettings;
var Config:TIniFile;
begin
 Log('start SaveDataAndSettings');
 Config:=TIniFile.Create(ExtractFilePath(Application.ExeName) + ConfigFN);
 try
  try
   Config.WriteBool('GENERAL', 'Alarm', Alarm);
   Config.WriteBool('GENERAL', 'AsteriskMute', AsteriskMute);
   Config.WriteBool('GENERAL', 'FSortOtherASC', FSortOtherASC);
   Config.WriteBool('GENERAL', 'ChatOff', ChatOff);
   Config.WriteBool('GENERAL', 'ChatMute', ChatMute);
   Config.WriteBool('GENERAL', 'ChatAnon', ChatAnon);
   Config.WriteBool('GENERAL', 'ShowChatHelp', ShowChatHelp);
   Config.WriteBool('GENERAL', 'UseAeroColor', UseAeroColor);
   Config.WriteString('GENERAL', 'CID', CID);
   Config.WriteString('GENERAL', 'Data', MD5(CID));
   Config.WriteInteger('GENERAL', 'Left', FormMain.Left);
   Config.WriteInteger('GENERAL', 'Top', FormMain.Top);
   Config.WriteInteger('GENERAL', 'WindScale', WindScale);
   Config.WriteInteger('GENERAL', 'ButtonsColor', ButtonsColor);
   Config.WriteInteger('GENERAL', 'MenuColor', MenuColor);
   Config.WriteInteger('GENERAL', 'FSortOtherBy', FSortOtherBy);
   Config.WriteInteger('GENERAL', 'ChatNotify', FChatNotify);
  // Config.WriteInteger('USER', 'Catalog.ActivePageIndex', PageControlCatalog.ActivePageIndex);
  // Config.WriteInteger('USER', 'Main.ActivePageIndex', PageControlMain.ActivePageIndex);
  finally
   Config.Free;
  end;
 except
  Log('except Config write');
 end;
 WriteFavorits;
 WriteJournal;
 Log('finish SaveDataAndSettings');
end;

procedure TFormMain.SetGlobalState(Value:TGlobalState);
var Icon:TIcon;
begin
 FGlobalState:=Value;
 if not Initialized then Exit;
 Icon:=TIcon.Create;
 case WorkCall.ItemType of
  jtMissed:
   begin
    FormDialing.ImageList64.GetIcon(2, Icon);
    FormDialing.Caption:='Пропущенный звонок';
   end;
  jtIncoming:
   begin
    FormDialing.ImageList64.GetIcon(0, Icon);
    FormDialing.Caption:='Входящий звонок';
   end;
  jtDialing:
   begin
    FormDialing.ImageList64.GetIcon(1, Icon);
    FormDialing.Caption:='Исходящий звонок';
   end;
  jtRedirect:
   begin
    FormDialing.ImageList64.GetIcon(1, Icon);
    FormDialing.Caption:='Переведённый звонок';
   end;
 end;
 FormDialing.ImageMan.Picture.Assign(Icon);
 ImageMan.Picture.Assign(Icon);
 Icon.Free;

 case FGlobalState of
  gsIdle:
   begin
    DialUpHide;
    ImageDialing.Hide;
    FormDialing.Close;
    FormDialing.ImageDialing.Hide;
    FButtonDialHint:='Позвонить';
   end;
  gsIncomingCall:
   begin
    if Alarm then
     begin
      LabelinSubject.Caption:=WorkCall.inSubject;
      LabelinNumber.Caption:=FieldToNumber(WorkCall.inNumber);
      ImageDialing.Hide;
      if GetForegroundWindow = Handle then DialupShow;
      FormDialing.ImageDialing.Hide;
      FormDialing.LabelinSubject.Caption:=LabelinSubject.Caption;
      FormDialing.LabelinNumber.Caption:=LabelinNumber.Caption;
      if not PanelDialup.Visible then FormDialing.ShowDial;
     end;
    FButtonDialHint:='Позвонить';
   end;
  gsDial:
   begin
    if Alarm then
     begin
      LabelinSubject.Caption:=WorkCall.inSubject;
      LabelinNumber.Caption:=FieldToNumber(WorkCall.inNumber);
      ImageDialing.Hide;
      if GetForegroundWindow = Handle then DialupShow;
      FormDialing.ImageDialing.Hide;
      FormDialing.LabelinSubject.Caption:=LabelinSubject.Caption;
      FormDialing.LabelinNumber.Caption:=LabelinNumber.Caption;
      if not PanelDialup.Visible then FormDialing.ShowDial;
     end;
    FButtonDialHint:='Перевести';
   end;
  gsDialing:
   begin
    if Alarm then
     begin
      LabelinSubject.Caption:=WorkCall.inSubject;
      LabelinNumber.Caption:=FieldToNumber(WorkCall.inNumber);
      ImageDialing.Show;
      if GetForegroundWindow = Handle then DialupShow;
      FormDialing.ImageDialing.Show;
      FormDialing.LabelinSubject.Caption:=LabelinSubject.Caption;
      FormDialing.LabelinNumber.Caption:=LabelinNumber.Caption;
      if not PanelDialup.Visible then FormDialing.ShowDial;
     end;
    FButtonDialHint:='Позвонить';
   end;
 end;
 if GlobalState = gsIdle then CurColorHangout:=CurColorDisable
 else CurColorHangout:=ColorHangout;
 ColorImages(ImageListNumbers, 12, CurColorHangout);
 ButtonDialLandline.Enabled:=EditCatalogNumLandline.Enabled and (FGlobalState in [gsIdle, gsDial]);
 ButtonDialInternal.Enabled:=EditCatalogNumIn.Enabled and (FGlobalState in [gsIdle, gsDial]);
 ButtonDialCell.Enabled:=EditCatalogNumCell.Enabled and (FGlobalState in [gsIdle, gsDial]);
 DrawGridNumPad.Repaint;
end;

procedure TFormMain.OnHint(Sender: TObject);
begin
 LabelHint.Caption:=Application.Hint;
end;

procedure TFormMain.Log(Value:string);
var i:Integer;
    DT:string;
    VL:TStringList;

function InsError(L:Integer):string;
var i:Integer;
begin
 Result:=#9'(LastError is "'+SysErrorMessage(GetLastError)+'")';
 for i:= 0 to 45 - L do
  Result:=' '+Result;
end;

function Spaces(C:Word):string;
var i:Integer;
begin
 Result:='';
 for i:= 1 to C do Result:=Result+ ' ';
end;

function Lines(C:Word):string;
var i:Integer;
begin
 Result:='';
 for i:= 1 to C do Result:=Result+ '-';
end;

begin
 DT:=DateTimeToStr(Now);
 if Pos(#13, Value) = 0 then
  MemoLog.Lines.Insert(0, Format('%s: %s %s', [DT, Value, InsError(Length(Value))]))
 else
  begin
   VL:=TStringList.Create;
   VL.Text:=Value;
   if VL.Count > 0 then
    begin
     MemoLog.Lines.Insert(0, Lines(100));
     VL[0]:=Format('%s: %s %s', [DT, VL[0], InsError(Length(VL[0]))]);
     for i:= VL.Count - 1 downto 1 do
      MemoLog.Lines.Insert(0, Format('%s  %s', [Spaces(Length(DT)), VL[i]]));
     MemoLog.Lines.Insert(0, VL[0]);
    end;

  end;
 if not DirectoryExists(ExtractFilePath(Application.ExeName)+'Logs') then CreateDir(ExtractFilePath(Application.ExeName)+'Logs');
 if DirectoryExists(ExtractFilePath(Application.ExeName)+'Logs') then
  begin
   try
    MemoLog.Lines.SaveToFile(ExtractFilePath(Application.ExeName)+'Logs\'+LogName);
   except

   end;
  end;
end;

procedure TFormMain.MenuItemFavChangeIconClick(Sender: TObject);
var Num:TCommonRec;
    IID:Integer;
begin
 if PopupMenuFavorite.Tag >= 0 then
  begin
   try
    Num:=FavoriteNums[PopupMenuFavorite.Tag];
   except
    begin
     Log('except Num:=FavoriteNums[PopupMenuFavorite.Tag];');
     Exit;
    end;
   end;
   if SelectIcon(Num.KodOtd, IID) then
    begin
     Num.KodOtd:=IID;
     FavoriteNums[PopupMenuFavorite.Tag]:=Num;
     UpdateGridFavorite;
    end;
  end;
end;

procedure TFormMain.MenuItemFavChangeNameClick(Sender: TObject);
var str:string;
    Num:TCommonRec;
begin
 if PopupMenuFavorite.Tag >= 0 then
  begin
   try
    Num:=FavoriteNums[PopupMenuFavorite.Tag];
   except
    begin
     Log('except Num:=FavoriteNums[PopupMenuFavorite.Tag];');
     Exit;
    end;
   end;
   str:=InputBox('Введите имя для избранного номера', 'Имя:', Num.FIO);
   if str <> '' then
    begin
     Num.FIO:=str;
     FavoriteNums[PopupMenuFavorite.Tag]:=Num;
     UpdateGridFavorite;
    end;
  end;
end;

procedure TFormMain.MenuItemFavChangeNumberClick(Sender: TObject);
var str:string;
    Num:TCommonRec;
begin
 if PopupMenuFavorite.Tag >= 0 then
  begin
   try
    Num:=FavoriteNums[PopupMenuFavorite.Tag];
   except
    begin
     Log('except Num:=FavoriteNums[PopupMenuFavorite.Tag];');
     Exit;
    end;
   end;
   str:=InputBox('Введите номер', 'Номер:', Num.NumInteranl);
   if str <> '' then
    begin
     Num.NumInteranl:=str;
     FavoriteNums[PopupMenuFavorite.Tag]:=Num;
     UpdateGridFavorite;
    end;
  end;
end;

procedure TFormMain.MenuItemFavDeleteClick(Sender: TObject);
begin
 if PopupMenuFavorite.Tag >= 0 then
  begin
   FavoriteNums.Delete(PopupMenuFavorite.Tag);
   UpdateGridFavorite;
  end;
end;

procedure TFormMain.MenuItemJClearClick(Sender: TObject);
begin
 if MessageBox(Application.Handle, 'Вы действительно хотите очистить журнал звонков?', '', MB_ICONASTERISK or MB_YESNO) <> ID_YES then Exit;
 Journal.Clear;
 UpdateJournal;
end;

procedure TFormMain.MenuItemJCopyClick(Sender: TObject);
begin
 if not IndexInList(TableExJournalList.ItemIndex, TList(JournalFilter)) then Exit;
 Clipboard.AsText:=JournalFilter[TableExJournalList.ItemIndex].inNumber;
 ShowBalloonHintMsg(AppDesc, 'Номер скопирован в буфер обмена', TBalloonFlags(NIIF_LARGE_ICON), nil);
end;

procedure TFormMain.MenuItemJDeleteClick(Sender: TObject);
begin
 if not IndexInList(TableExJournalList.ItemIndex, TList(JournalFilter)) then Exit;
 Journal.Delete(JournalFilter[TableExJournalList.ItemIndex].ItemID);
 UpdateJournal;
end;

procedure TFormMain.MenuItemJDialClick(Sender: TObject);
begin
 if not IndexInList(TableExJournalList.ItemIndex, TList(JournalFilter)) then Exit;
 InsertNumber(JournalFilter[TableExJournalList.ItemIndex].inNumber);
end;

procedure TFormMain.Quit(Accepts:Boolean);
begin
 if Accepts then
  begin
   try
    if not TaskDialogQuit.Execute then Exit;
    if TaskDialogQuit.ModalResult <> 100 then Exit;
   except
    if MessageBox(Application.Handle, 'Вы действительно хотите закрыть программу?', 'Выход', MB_ICONWARNING or MB_YESNOCANCEL or MB_DEFBUTTON2) <> ID_YES then Exit;
   end;
   Sound(stShutdown);
  end;
 if GlobalState <> gsIdle then EventOnHangup('QUIT', True);
 SaveDataAndSettings;
 Application.Terminate;
end;

procedure TFormMain.StateChange;
begin
 if ClientSocketAsterisk.Active then
  begin
   ActionRecon.Caption:='Отключиться';
   ActionRecon.ImageIndex:=3;
  end
 else
  begin
   ActionRecon.Caption:='Подключиться';
   ActionRecon.ImageIndex:=4;
  end;

 if Ord(ClientSocketAsterisk.Active) <> ImageConState.Tag then
  begin
   ImageConState.Tag:=Ord(ClientSocketAsterisk.Active);
   case ImageConState.Tag of
    0:
     begin
      ImageList.GetIcon(3, ImageConState.Picture.Icon);
      ImageConState.Hint:='Нет соединения';
      LabelNoConenction.Caption:='Нет соединения';
      LabelNoConenction.Visible:=True;
     end;
    1:
     begin
      ImageList.GetIcon(4, ImageConState.Picture.Icon);
      ImageConState.Hint:='Соединение установлено';
      LabelNoConenction.Caption:='';
      LabelNoConenction.Visible:=False;
     end;
   end;
  end;
end;

procedure TFormMain.DrawGridWorkTimeDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var ID:Integer;
    RText:TRect;
    Str:string;

begin
 with DrawGridWorkTime.Canvas do
  begin
   Brush.Style:=bsSolid;
   Pen.Style:=psSolid;
   Brush.Color:=DrawGridWorkTime.Color;
   Pen.Color:=Brush.Color;
   Rectangle(Rect);
   ID:=ARow;
   if (ID < 0) or (ID > FDrawWorkTimeList.Count-1) then Exit;
   Str:=FDrawWorkTimeList[ID];
   if (ARow mod 2 = 0) then
        Brush.Color:=$00E7E8E8
   else Brush.Color:=$00F1F2F2;
   if Str = '0' then Brush.Color:=$00AFFFC8;

   Font.Size:=9;
   Font.Color:=$00484848;
   Font.Style:=[];
   if Str = '' then
    begin
     Str:='не указано';
     Font.Color:=$00BEBEBE;
    end;
   if Str = '0' then
    begin
     Str:='Выходной';
     Font.Style:=Font.Style + [fsBold];
    end;

   if DayOfTheWeek(Now)-1 = ID then
    begin
     Font.Color:=clWhite;
     Brush.Color:=clLISelect;
    end;

   Pen.Color:=Brush.Color;
   Rectangle(Rect);

   Brush.Style:=bsClear;

   RText:=Rect;
   RText.Left:=RText.Left + 1;
   RText.Top:=RText.Top + 1;
   RText.Right:=RText.Left + 20;
   RText.Bottom:=RText.Bottom - 1;
   DrawTextCentered(DrawGridWorkTime.Canvas, RText, GetStrDayWeek(ID+1));

   RText:=Rect;
   RText.Left:=RText.Left + 20;
   RText.Top:=RText.Top + 1;
   RText.Right:=RText.Right - 1;
   RText.Bottom:=RText.Bottom - 1;
   DrawTextCentered(DrawGridWorkTime.Canvas, RText, Str);
  end;
end;

procedure TFormMain.DrawGridFavoriteDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var ID:Integer;
    RText:TRect;
    BColor:TColor;
    Ico:TIcon;
begin
 with DrawGridFavorite.Canvas do
  begin
   Brush.Style:=bsSolid;
   Pen.Style:=psSolid;
   Brush.Color:=DrawGridFavorite.Color;
   Pen.Color:=Brush.Color;
   Rectangle(Rect);

   ID:=ARow*((Sender as TDrawGrid).ColCount) + ACol;
   if (ID < 0) or (ID > FavoriteNums.Count-1) then Exit;

   if (ACol mod 2 = 0) xor (ARow mod 2 = 0) then
        Brush.Color:=$00E7E8E8
   else Brush.Color:=$00F1F2F2;

   Pen.Color:=Brush.Color;
   Rectangle(Rect);

   if ((CordDrawFavorite.X = ACol) and (CordDrawFavorite.Y = ARow)) then
    begin
     if FavoriteDowned then BColor:=ColorDarker($00DCDCDC, 20) else BColor:=$00DCDCDC;
     Brush.Color:=MixColors(BColor, (Sender as TDrawGrid).Canvas.Brush.Color, 150);
     Pen.Color:=Brush.Color;
     Brush.Style:=bsSolid;
     Pen.Style:=psSolid;
     Rectangle(ScaledRect(Rect, -1));
     Font.Style:=[];
    end;
   RText:=Rect;
   RText.Left:=RText.Left + 1;
   RText.Top:=RText.Top + 1;
   RText.Right:=RText.Right - 1;
   RText.Bottom:=RText.Bottom - 1;

   if FavoriteNums[ID].KodOtd >= 0 then
    begin
     Ico:=TIcon.Create;
     ImageListMans.GetIcon(FavoriteNums[ID].KodOtd, Ico);
     RText.Left:=RText.Left + 18;
     Draw(Rect.Left + 3, (Rect.Top + (Rect.Height div 2) - 8), Ico);
     Ico.Free;
    end;
   Font.Size:=9;
   Brush.Style:=bsClear;
   DrawTextCentered(DrawGridFavorite.Canvas, RText, FavoriteNums[ID].FIO);
  end;
end;

procedure TFormMain.DrawGridFavoriteMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 FavoriteDowned:=True;
 DrawGridFavorite.Repaint;
end;

procedure TFormMain.DrawGridFavoriteMouseLeave(Sender: TObject);
begin
 CordDrawFavorite.X:=-1;
 CordDrawFavorite.Y:=-1;
 FavoriteDowned:=False;
 DrawGridFavorite.Repaint;
end;

procedure TFormMain.DrawGridFavoriteMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var ID:Integer;
begin
 CordDrawFavorite:=DrawGridFavorite.MouseCoord(X, Y);
 ID:=CordDrawFavorite.Y*DrawGridFavorite.ColCount + CordDrawFavorite.X;
 if ((ID >= 0) and (ID <= (FavoriteNums.Count-1))) then
  begin
   if DrawGridFavorite.Hint <> FavoriteNums[ID].NumInteranl then Application.CancelHint;
   DrawGridFavorite.Hint:=FavoriteNums[ID].NumInteranl;
   Application.Hint:=DrawGridFavorite.Hint;
  end
 else DrawGridFavorite.Hint:='';
 DrawGridFavorite.Repaint;
end;

procedure TFormMain.DrawGridFavoriteMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID:Integer;
begin
 ID:=CordDrawFavorite.Y*DrawGridFavorite.ColCount + CordDrawFavorite.X;
 if FavoriteDowned and ((ID >= 0) and (ID <= (FavoriteNums.Count-1))) then
  begin
   if Button = mbRight then
    begin
     PopupMenuFavorite.Tag:=ID;
     PopupMenuFavorite.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    end;
   if Button = mbLeft then InsertNumber(FavoriteNums[ID].NumInteranl);
  end;
 FavoriteDowned:=False;
 DrawGridFavorite.Repaint;
end;

procedure TFormMain.DrawGridFavoriteMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 DrawGridFavorite.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
end;

procedure TFormMain.DrawGridFavoriteMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 DrawGridFavorite.Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TFormMain.DrawGridGroupDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var ID:Integer;
    RText:TRect;
    BColor:TColor;
begin
 with DrawGridGroup.Canvas do
  begin
   Brush.Style:=bsSolid;
   Pen.Style:=psSolid;
   Brush.Color:=clWhite;
   Pen.Color:=clWhite;
   Rectangle(Rect);
   ID:=ARow;
   if (ID < 0) or (ID > GroupNums.Count-1) then Exit;
   if ARow mod 2 = 0 then Brush.Color:=$00E7E8E8 else Brush.Color:=$00F1F2F2;
   Pen.Color:=Brush.Color;
   Rectangle(Rect);
   if ((CordDrawGroup.X = ACol) and (CordDrawGroup.Y = ARow))
   then
    begin
     if MyGroupDowned then BColor:=ColorDarker($00DCDCDC, 20) else BColor:=$00DCDCDC;
     Brush.Color:=MixColors(BColor, Brush.Color, 150);
     Pen.Color:=Brush.Color;
     Brush.Style:=bsSolid;
     Pen.Style:=psSolid;
     Rectangle(Rect);
    end;
   RText:=ScaledRect(Rect, -1);
   Brush.Style:=bsClear;
   Font.Style:=[];
   DrawTextCentered(DrawGridGroup.Canvas, RText, GroupNums[ID].FIO);
  end;
end;

procedure TFormMain.DrawGridGroupMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 MyGroupDowned:=True;
 DrawGridGroup.Repaint;
end;

procedure TFormMain.DrawGridGroupMouseLeave(Sender: TObject);
begin
 CordDrawGroup.X:=-1;
 CordDrawGroup.Y:=-1;
 MyGroupDowned:=False;
 DrawGridGroup.Repaint;
end;

procedure TFormMain.DrawGridGroupMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var ID:Integer;
begin
 CordDrawGroup:=DrawGridGroup.MouseCoord(X, Y);
 ID:=CordDrawGroup.Y;
 if ((ID >= 0) and (ID <= (GroupNums.Count-1))) then
  begin
   if DrawGridGroup.Hint <> GroupNums[ID].NumInteranl then Application.CancelHint;
   DrawGridGroup.Hint:=GroupNums[ID].NumInteranl;
   Application.Hint:=DrawGridGroup.Hint;
  end
 else DrawGridGroup.Hint:='';
 DrawGridGroup.Repaint;
end;

procedure TFormMain.DrawGridGroupMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID:Integer;
begin
 ID:=CordDrawGroup.Y;
 if MyGroupDowned and ((ID >= 0) and (ID <= (GroupNums.Count-1))) then
  begin
   if Button = mbLeft then InsertNumber(GroupNums[ID].NumInteranl);
  end;
 MyGroupDowned:=False;
 DrawGridGroup.Repaint;
end;

procedure TFormMain.DrawGridGroupMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 DrawGridGroup.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
end;

procedure TFormMain.DrawGridGroupMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 DrawGridGroup.Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TFormMain.DrawGridNumPadDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var ID, IcoID:Integer;
    RText:TRect;
    BColor:TColor;
    Ico:TIcon;
    Txt:string;
    ColorBG, ColorBG2, ColorHot, ColorDown:TColor;
begin
 with DrawGridNumPad.Canvas do
  begin
   Brush.Style:=bsSolid;
   Pen.Style:=psSolid;
   Brush.Color:=DrawGridNumPad.Color;
   Pen.Color:=Brush.Color;
   Rectangle(Rect);

   ID:=ARow*((Sender as TDrawGrid).ColCount) + ACol;
   case ID of
    9:
     begin
      ColorBG:=ColorLighter(CurColorDial, 60);
      ColorBG2:=ColorBG;
      ColorHot:=ColorLighter(ColorBG);
      ColorDown:=ColorLighter(ColorBG, 20);
     end;
    11:
     begin
      ColorBG:=ColorLighter(CurColorHangout, 60);
      ColorBG2:=ColorBG;
      ColorHot:=ColorLighter(ColorBG);
      ColorDown:=ColorLighter(ColorBG, 20);
     end;
   else
     begin
      ColorBG:=$00F1F2F2;
      ColorBG2:=$00E7E8E8;
      ColorHot:=$00DCDCDC;
      ColorDown:=ColorDarker($00DCDCDC, 20);
     end;
   end;

   if ARow mod 2 = 0 then
    begin
     if ACol mod 2 = 0 then Brush.Color:=ColorBG
     else Brush.Color:=ColorBG2
    end
   else
    begin
     if ACol mod 2 = 0 then Brush.Color:=ColorBG2
     else Brush.Color:=ColorBG;
    end;

   Pen.Color:=Brush.Color;
   Rectangle(Rect);

   if ((CordDrawNumpad.X = ACol) and (CordDrawNumpad.Y = ARow)) then
    begin
     if NumPadDowned then BColor:=ColorDown else BColor:=ColorHot;
     Brush.Color:=MixColors(BColor, (Sender as TDrawGrid).Canvas.Brush.Color, 150);
     Pen.Color:=Brush.Color;
     Brush.Style:=bsSolid;
     Pen.Style:=psSolid;
     Rectangle(ScaledRect(Rect, 0));
     //Font.Style:=[];
    end;
   RText:=Rect;
   RText.Left:=RText.Left + 1;
   RText.Top:=RText.Top - 4;
   RText.Right:=RText.Right - 1;
   RText.Bottom:=RText.Bottom - 1;
   IcoID:=0;
   Font.Size:=20;
   Font.Name:='Segoe UI Light';
   Font.Color:=$004B4B4B;
   Font.Style:=[fsBold];
   case ID of
    0:
     begin
      Txt:='1';
     end;
    1:
     begin
      Txt:='2';
     end;
    2:
     begin
      Txt:='3';
     end;
    3:
     begin
      Txt:='4';
     end;
    4:
     begin
      Txt:='5';
      Font.Style:=[fsBold, fsUnderline];
     end;
    5:
     begin
      Txt:='6';
     end;
    6:
     begin
      Txt:='7';
     end;
    7:
     begin
      Txt:='8';
     end;
    8:
     begin
      Txt:='9';
     end;
    9:
     begin
      IcoID:=11;
     end;
    10:
     begin
      Txt:='0';
     end;
    11:
     begin
      IcoID:=12;
     end;
   end;

   if IcoID > 0 then
    begin
     Ico:=TIcon.Create;
     ImageListNumbers.GetIcon(IcoID, Ico);
     Draw(Rect.Left + (Rect.Width div 2) - (Ico.Width div 2), (Rect.Top + (Rect.Height div 2) - (Ico.Height div 2)), Ico);
     Ico.Free;
    end
   else
    begin
     Brush.Style:=bsClear;
     DrawTextCentered(DrawGridNumPad.Canvas, RText, Txt);
    end;
  end;
end;

procedure TFormMain.DrawGridNumPadMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button = mbLeft then
  begin
   NumPadDowned:=True;
   DrawGridNumPad.Repaint;
  end;
end;

procedure TFormMain.DrawGridNumPadMouseLeave(Sender: TObject);
begin
 CordDrawNumpad.X:=-1;
 CordDrawNumpad.Y:=-1;
 NumPadDowned:=False;
 DrawGridNumPad.Repaint;
end;

procedure TFormMain.DrawGridNumPadMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var ID:Integer;
    NHint:String;
begin
 CordDrawNumpad:=DrawGridNumPad.MouseCoord(X, Y);
 ID:=CordDrawNumpad.Y*(Sender as TDrawGrid).ColCount + CordDrawNumpad.X;
 case ID of
  9:NHint:=FButtonDialHint;
  11:NHint:='Завершить звонок';
 else
  NHint:='';
 end;
 if DrawGridNumPad.Hint <> NHint then Application.CancelHint;
 DrawGridNumPad.Hint:=NHint;
 Application.Hint:=DrawGridNumPad.Hint;
 DrawGridNumPad.Repaint;
end;

procedure TFormMain.DrawGridNumPadMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID:Integer;
begin
 ID:=CordDrawNumpad.Y*(Sender as TDrawGrid).ColCount + CordDrawNumpad.X;
 if NumPadDowned and ((ID >= 0) and (ID <= (FavoriteNums.Count-1))) then
  begin
   if Button = mbRight then
    begin
     //PopupMenuFavorite.Tag:=ID;
     //PopupMenuFavorite.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    end
   else //InsertNumber(FavoriteNums[ID].NumInteranl);
    begin
     case ID of
      0..8:EditMainNumber.Text:=EditMainNumber.Text+IntToStr(ID+1);
        10:EditMainNumber.Text:=EditMainNumber.Text+'0';
      9: ButtonDialClick(nil);
      11:ButtonCallDownClick(nil);
     end;
    end;
  end;
 NumPadDowned:=False;
 DrawGridNumPad.Repaint;
end;

procedure TFormMain.DrawGridNumPadMouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 DrawGridNumPad.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
end;

procedure TFormMain.DrawGridNumPadMouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 DrawGridNumPad.Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TFormMain.DrawGridBranchsDblClick(Sender: TObject);
var ID, i, j, ARow, ACol:Integer;
    Obj:string;
begin
 DrawGridBranchs.Repaint;
 ARow:=DrawGridBranchs.Row;
 ACol:=DrawGridBranchs.Col;
 ID:=ARow*DrawGridBranchs.ColCount + ACol + 1;
 for i:= 0 to BranchNums.Count - 1 do
  if BranchNums[i].BranchNum = IntToStr(ID) then
   begin
    if BranchNums[i].NObjParent = '' then Exit;
    Obj:=BranchNums[i].NObjParent;
    Break;
   end;

 if Copy(Obj, 1, 2) = 'B1' then
  begin
   for j:= 0 to BuyingNums.Count-1 do
    begin
     if BuyingNums[j].BranchNum = Copy(Obj, 3, 255) then
      begin
       SetSubjectData(BuyingNums[j]);
       Exit;
      end;
    end;
  end;

 if Copy(Obj, 1, 2) = 'B2' then
  begin
   for j:= 0 to BuyingSNums.Count-1 do
    begin
     if BuyingSNums[j].BranchNum = Copy(Obj, 3, 255) then
      begin
       SetSubjectData(BuyingSNums[j]);
       Exit;
      end;
    end;
  end;

 if Copy(Obj, 1, 2) = 'S1' then
  begin
   for j:= 0 to ShopsNums.Count-1 do
    begin
     if ShopsNums[j].BranchNum = Copy(Obj, 3, 255) then
      begin
       SetSubjectData(ShopsNums[j]);
       Exit;
      end;
    end;
  end;
end;

procedure TFormMain.DrawGridBranchsKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 if Assigned((Sender as TDrawGrid).OnMouseUp) then (Sender as TDrawGrid).OnMouseUp(Sender, mbLeft, [], 0, 0);
end;

procedure TFormMain.DrawGridBranchsMouseLeave(Sender: TObject);
begin
 CordDrawBranchs.X:=-1;
 CordDrawBranchs.Y:=-1;
 (Sender as TDrawGrid).Repaint;
end;

procedure TFormMain.DrawGridBranchsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 CordDrawBranchs:=DrawGridBranchs.MouseCoord(X, Y);
 DrawGridBranchs.Repaint;
end;

procedure TFormMain.DrawGridBranchsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID, i, j, ARow, ACol:Integer;
begin
 if Button = mbRight then
  begin
   DrawGridBranchsDblClick(nil);
   Exit;
  end;
 ARow:=DrawGridBranchs.Row;
 ACol:=DrawGridBranchs.Col;
 ID:=ARow*DrawGridBranchs.ColCount + ACol + 1;
 for i:= 0 to BranchNums.Count - 1 do
  if BranchNums[i].BranchNum = IntToStr(ID) then
   begin
    SetSubjectData(BranchNums[i]);
    if DepartNums.Count > 0 then
     for j:= 0 to DepartNums.Count - 1 do
      begin
       if DepartNums[j].KodOtd = BranchNums[i].KodOtd then
        begin
         ListBoxDeparts.ItemIndex:=j;
         ListBoxDeparts.Repaint;
         IdSelectedBranch:=BranchNums[i].KodOtd;
         Break;
        end;
      end;
    Break;
   end;
 DrawGridBranchs.Repaint;
end;

procedure TFormMain.DrawGridBranchsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var ID, i:Integer;
begin
 CanSelect:=False;
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to BranchNums.Count - 1 do
  if BranchNums[i].BranchNum = IntToStr(ID) then
   begin
    CanSelect:=True;
    Break;
   end;
 DrawGridBranchs.Repaint;
end;

procedure TFormMain.DrawGridBuyingsMouseLeave(Sender: TObject);
begin
 CordDrawBuying.X:=-1;
 CordDrawBuying.Y:=-1;
 (Sender as TDrawGrid).Repaint;
end;

procedure TFormMain.DrawGridBuyingsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 CordDrawBuying:=DrawGridBuyings.MouseCoord(X, Y);
 DrawGridBuyings.Repaint;
end;

procedure TFormMain.DrawGridBuyingsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID, i, j, ARow, ACol:Integer;
begin
 ARow:=(Sender as TDrawGrid).Row;
 ACol:=(Sender as TDrawGrid).Col;
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to BuyingNums.Count - 1 do
  if BuyingNums[i].BranchNum = IntToStr(ID) then
   begin
    SetSubjectData(BuyingNums[i]);
    if DepartBuyNums.Count > 0 then
     for j:= 0 to DepartBuyNums.Count - 1 do
      begin
       if DepartBuyNums[j].KodOtd = BuyingNums[i].KodOtd then
        begin
         ListBoxBuyingDepart.ItemIndex:=j;
         ListBoxBuyingDepart.Repaint;
         IdSelectedB:=BuyingNums[i].KodOtd;
         DrawGridBuyingsS.Repaint;
         Break;
        end;
      end;
    Break;
   end;
 DrawGridBuyings.Repaint;
end;

procedure TFormMain.DrawGridBuyingsSDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var ID, i:Integer;
    aText:string;
    aColor, fColor:TColor;
    GCoord:TGridCoord;
    Sel:Boolean;
    Mark:Boolean;
begin                //$00F1B7D7
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 Sel:=False;
 fColor:=clBlack;
 aColor:=MenuColor;
 Mark:=False;
 if Sender = DrawGridBuyingsS then
  begin
   for i:= 0 to BuyingSNums.Count - 1 do
    if BuyingSNums[i].BranchNum = IntToStr(ID) then
     begin
      aText:=BuyingSNums[i].BranchNum;
      if IdSelectedB >= 0 then
       begin
        Sel:=BuyingSNums[i].KodOtd = IdSelectedB;
       end;
      if Sel then fColor:=clWhite else fColor:=clBlack;
      Break;
     end;
   GCoord:=CordDrawBuyingS;
  end;

 if Sender = DrawGridBuyings then
  begin
   for i:= 0 to BuyingNums.Count - 1 do
    if BuyingNums[i].BranchNum = IntToStr(ID) then
     begin
      aText:=BuyingNums[i].BranchNum;
      if IdSelectedB >= 0 then
       begin
        Sel:=BuyingNums[i].KodOtd = IdSelectedB;
       end;
      if Sel then fColor:=clWhite else fColor:=clBlack;
      Break;
     end;
   GCoord:=CordDrawBuying;
  end;

 if Sender = DrawGridBranchs then
  begin
   for i:= 0 to BranchNums.Count - 1 do
    if BranchNums[i].BranchNum = IntToStr(ID) then
     begin
      aText:=BranchNums[i].BranchNum;
      if IdSelectedBranch >= 0 then
       begin
        Sel:=BranchNums[i].KodOtd = IdSelectedBranch;
       end;
      if Sel then fColor:=clWhite else fColor:=clBlack;
      if BranchNums[i].NObjParent <> '' then Mark:=True;
      Break;
     end;
   GCoord:=CordDrawBranchs;
  end;

 if Sender = DrawGridShops then
  begin
   for i:= 0 to ShopsNums.Count - 1 do
    if ShopsNums[i].BranchNum = IntToStr(ID) then
     begin
      aText:=ShopsNums[i].BranchNum;
      if IdSelectedS <> '' then
       begin
        Sel:=ShopsNums[i].BranchNum = IdSelectedS;
       end;
      if Sel then fColor:=clWhite else fColor:=clBlack;
      Break;
     end;
   GCoord:=CordDrawShops;
  end;

 if aText = '' then
  begin
   (Sender as TDrawGrid).Canvas.Brush.Style:=bsSolid;
   (Sender as TDrawGrid).Canvas.Brush.Color:=clWhite;
   (Sender as TDrawGrid).Canvas.FillRect(Rect);
   (Sender as TDrawGrid).Canvas.Brush.Style:=bsClear;
   (Sender as TDrawGrid).Canvas.Font.Style:=[];
   (Sender as TDrawGrid).Canvas.Font.Color:=$00DEDEDE;
   (Sender as TDrawGrid).Canvas.Font.Size:=DrawGridFontSize;
   (Sender as TDrawGrid).Canvas.TextOut(
    Rect.Left + (Rect.Width div 2 - (Sender as TDrawGrid).Canvas.TextWidth(IntToStr(ID)) div 2),
    Rect.Top + (Rect.Height div 2 - (Sender as TDrawGrid).Canvas.TextHeight(IntToStr(ID)) div 2), IntToStr(ID));
   Exit;
  end;
 (Sender as TDrawGrid).Canvas.Font.Style:=[];

 //Если элемент нужно выделить, то рисуем доп. фон
 if Sel then
  begin
   (Sender as TDrawGrid).Canvas.Brush.Color:=aColor;
   (Sender as TDrawGrid).Canvas.Pen.Color:=aColor;
   (Sender as TDrawGrid).Canvas.Brush.Style:=bsSolid;
   (Sender as TDrawGrid).Canvas.Font.Style:=[fsBold];
   (Sender as TDrawGrid).Canvas.FillRect(Rect);
  end
 else //Если нет, то рисуем белый фон
  begin
   (Sender as TDrawGrid).Canvas.Brush.Color:=clWhite;
   (Sender as TDrawGrid).Canvas.Pen.Color:=clWhite;
   (Sender as TDrawGrid).Canvas.Brush.Style:=bsSolid;
   (Sender as TDrawGrid).Canvas.Font.Style:=[];
   (Sender as TDrawGrid).Canvas.FillRect(Rect);
  end;

 //Если элемент по курсором, то выделяем его светлой рамкой
 if ((GCoord.X = ACol) and (GCoord.Y = ARow))
 then
  begin                                              //$00D2F6EB
   (Sender as TDrawGrid).Canvas.Brush.Color:=MixColors(ColorLighter(aColor), (Sender as TDrawGrid).Canvas.Brush.Color, 150);
   (Sender as TDrawGrid).Canvas.Pen.Color:=(Sender as TDrawGrid).Canvas.Brush.Color;    //$006CB6A0
   (Sender as TDrawGrid).Canvas.Brush.Style:=bsSolid;
   (Sender as TDrawGrid).Canvas.Pen.Style:=psSolid;
   (Sender as TDrawGrid).Canvas.Rectangle(Rect);
  end
 else //Если элемент выбран, то выделяем его тёмной рамкой
  if (((Sender as TDrawGrid).Col = ACol) and ((Sender as TDrawGrid).Row = ARow))
  then
   begin                                                    //$008AE9CC
    (Sender as TDrawGrid).Canvas.Brush.Color:=MixColors(ColorLighter(MenuColor, 50), (Sender as TDrawGrid).Canvas.Brush.Color, 150);
    (Sender as TDrawGrid).Canvas.Pen.Color:=(Sender as TDrawGrid).Canvas.Brush.Color;  //$006CB6A0
    (Sender as TDrawGrid).Canvas.Brush.Style:=bsSolid;
    (Sender as TDrawGrid).Canvas.Pen.Style:=psSolid;
    (Sender as TDrawGrid).Canvas.Rectangle(Rect);
   end;

 (Sender as TDrawGrid).Canvas.Font.Color:=fColor;
 (Sender as TDrawGrid).Canvas.Brush.Style:=bsClear;
 (Sender as TDrawGrid).Canvas.Font.Size:=DrawGridFontSize;
 (Sender as TDrawGrid).Canvas.TextOut(
  Rect.Left + (Rect.Width div 2 - (Sender as TDrawGrid).Canvas.TextWidth(aText) div 2),
  Rect.Top + (Rect.Height div 2 - (Sender as TDrawGrid).Canvas.TextHeight(aText) div 2), aText);

 if Mark then
  begin
   (Sender as TDrawGrid).Canvas.Brush.Style:=bsSolid;
   if Sel
   then (Sender as TDrawGrid).Canvas.Brush.Color:=$00E0B0DE
   else (Sender as TDrawGrid).Canvas.Brush.Color:=$009C0096;//MixColors(ColorLighter(clGreen, 50), (Sender as TDrawGrid).Canvas.Brush.Color, 150);
   (Sender as TDrawGrid).Canvas.Pen.Color:=(Sender as TDrawGrid).Canvas.Brush.Color;

   (Sender as TDrawGrid).Canvas.MoveTo(Rect.Right-2, Rect.Top+1);
   (Sender as TDrawGrid).Canvas.LineTo(Rect.Right-6, Rect.Top+1);

   (Sender as TDrawGrid).Canvas.MoveTo(Rect.Right-2, Rect.Top+2);
   (Sender as TDrawGrid).Canvas.LineTo(Rect.Right-5, Rect.Top+2);

   (Sender as TDrawGrid).Canvas.MoveTo(Rect.Right-2, Rect.Top+3);
   (Sender as TDrawGrid).Canvas.LineTo(Rect.Right-4, Rect.Top+3);

   (Sender as TDrawGrid).Canvas.MoveTo(Rect.Right-2, Rect.Top+4);
   (Sender as TDrawGrid).Canvas.LineTo(Rect.Right-3, Rect.Top+4);

   (Sender as TDrawGrid).Canvas.MoveTo(Rect.Right-2, Rect.Top+5);
   (Sender as TDrawGrid).Canvas.LineTo(Rect.Right-2, Rect.Top+5);


   //(Sender as TDrawGrid).Canvas.Ellipse(Rect.Right-5, Rect.Top+1, Rect.Right-1, Rect.Top+5);
  end;
end;

procedure TFormMain.DrawGridBuyingsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var ID, i:Integer;
begin
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to BuyingNums.Count - 1 do
  if BuyingNums[i].BranchNum = IntToStr(ID) then
   begin
    CanSelect:=True;
    Break;
   end;
 DrawGridBuyings.Repaint;
end;

procedure TFormMain.DrawGridBuyingsSMouseLeave(Sender: TObject);
begin
 CordDrawBuyingS.X:=-1;
 CordDrawBuyingS.Y:=-1;
 (Sender as TDrawGrid).Repaint;
end;

procedure TFormMain.DrawGridBuyingsSMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 CordDrawBuyingS:=DrawGridBuyingsS.MouseCoord(X, Y);
 DrawGridBuyingsS.Repaint;
end;

procedure TFormMain.DrawGridBuyingsSMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID, i, j, ARow, ACol:Integer;
begin
 ARow:=(Sender as TDrawGrid).Row;
 ACol:=(Sender as TDrawGrid).Col;
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to BuyingSNums.Count - 1 do
  if BuyingSNums[i].BranchNum = IntToStr(ID) then
   begin
    SetSubjectData(BuyingSNums[i]);
    if DepartBuyNums.Count > 0 then
     for j:= 0 to DepartBuyNums.Count - 1 do
      begin
       if DepartBuyNums[j].KodOtd = BuyingSNums[i].KodOtd then
        begin
         ListBoxBuyingDepart.ItemIndex:=j;
         ListBoxBuyingDepart.Repaint;
         IdSelectedB:=BuyingSNums[i].KodOtd;
         DrawGridBuyings.Repaint;
         Break;
        end;
      end;
    Break;
   end;
 DrawGridBuyingsS.Repaint;
end;

procedure TFormMain.DrawGridBuyingsSSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var ID, i:Integer;
begin
 CanSelect:=False;
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to BuyingSNums.Count - 1 do
  if BuyingSNums[i].BranchNum = IntToStr(ID) then
   begin
    CanSelect:=True;
    Break;
   end;
 DrawGridBuyingsS.Repaint;
end;

procedure TFormMain.DrawGridShopsMouseLeave(Sender: TObject);
begin
 CordDrawShops.X:=-1;
 CordDrawShops.Y:=-1;
 (Sender as TDrawGrid).Repaint;
end;

procedure TFormMain.DrawGridShopsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
 CordDrawShops:=DrawGridShops.MouseCoord(X, Y);
 DrawGridShops.Repaint;
end;

procedure TFormMain.DrawGridShopsMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var ID, i, ARow, ACol:Integer;
begin
 ARow:=(Sender as TDrawGrid).Row;
 ACol:=(Sender as TDrawGrid).Col;
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to ShopsNums.Count - 1 do
  if ShopsNums[i].BranchNum = IntToStr(ID) then
   begin
    SetSubjectData(ShopsNums[i]);
    IdSelectedS:=ShopsNums[i].BranchNum;
    Break;
   end;
 DrawGridShops.Repaint;
 ListBoxShops.ItemIndex:=-1;
end;

procedure TFormMain.DrawGridShopsSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var ID, i:Integer;
begin
 CanSelect:=False;
 ID:=ARow*(Sender as TDrawGrid).ColCount + ACol + 1;
 for i:= 0 to ShopsNums.Count - 1 do
  if ShopsNums[i].BranchNum = IntToStr(ID) then
   begin
    CanSelect:=True;
    Break;
   end;
 DrawGridShops.Repaint;
 ListBoxShops.ItemIndex:=-1;
end;

procedure TFormMain.Redirect(Number: string);
var Exten:string;
    JR:TJournalRec;
begin
 Exten:=GetNumberOnly(Number);
 if Exten = '' then
  begin
   MessageBox(Application.Handle, 'Неправильно набран номер', 'Уведомление', MB_OK or MB_ICONWARNING);
   Exit;
  end;
 //Запоминаем, кого, куда и когда мы переводим
 JR.inSubject:=WorkCall.inSubject;
 JR.inNumber:=FieldToNumber(Exten);
 JR.fromNumber:=WorkCall.inNumber;
 JR.ItemType:=jtRedirect;
 JR.inStart:=Now;
 JR.inFinish:=Now;
 JR.inChannel:=WorkCall.inChannel;
 JR.TimeDur:=TimeBetwen(JR.inStart, JR.inFinish);
 //И ставим флаг о том, что нужно будет добавить запись о переводе звонка в журнал, когда придёт сигнал сброса трубки
 RedirectJR:=JR;
 RedirectToJR:=True;

 Log('Перевод на '+FieldToNumber(Exten));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Redirect' + #13#10));
 if WorkCall.inExtenChannel = '' then
  ClientSocketAsterisk.Socket.SendText(AnsiString('Channel: ' + WorkCall.inChannel + #13#10))
 else
  ClientSocketAsterisk.Socket.SendText(AnsiString('Channel: ' + WorkCall.inExtenChannel + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Exten: ' + Exten + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Context: ' + Context + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Priority: 1' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));
end;

procedure TFormMain.Dial(Number: string);
begin
 ShowErrorConnect:=True;
 if GlobalState in [gsIncomingCall, gsDialing] then Exit;
 if GlobalState in [gsDial] then
  begin
   Redirect(Number);
   Exit;
  end;
 WorkCall.inNumber:=GetNumberOnly(Number);
 if WorkCall.inNumber = '' then
  begin
   MessageBox(Application.Handle, 'Неправильно набран номер', 'Уведомление', MB_OK or MB_ICONWARNING);
   Exit;
  end;
 Log('Набор: '+WorkCall.inNumber);
 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Originate' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Channel: SIP/' + CID + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('CallerID: ' + CID + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Timeout: 15000' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Context: ' + Context + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Exten: ' + WorkCall.inNumber + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Priority: 1' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));
end;

procedure TFormMain.DialupHide;
var Delta, Step:Double;
begin
 if Animate then
  begin
   Delta:=PanelDialup.Top;
   Step:=2.8;
   while PanelDialup.Top <= ClientHeight do
    begin
     Delta:=Delta + Step;
     PanelDialup.Top:=Round(Delta);
     Repaint;
     Sleep(3);
     Step:=Step + 0.4;
    end;
  end;
 PanelDialup.Top:=ClientHeight;
 PanelDialup.Visible:=False;
end;

procedure TFormMain.DialupShow;
var Delta, Step:Double;
begin
 PanelDialup.Visible:=True;
 if Animate then
  begin
   Delta:=PanelDialup.Top;
   Step:=2.8;
   while PanelDialup.Top >= 448 do
    begin
     Delta:=Delta - Step;
     PanelDialup.Top:=Round(Delta);
     Repaint;
     Sleep(3);
     Step:=Step + 0.4;
    end;
  end;
 PanelDialup.Top:=448;
end;

procedure TFormMain.ClearSelectedNumber;
begin
 EditCatalogFIO.Text:='';
 EditCatalogNumIn.Text:='';
 EditCatalogNumLandline.Text:='';
 EditCatalogNumCell.Text:='';
 EditCatalogEMail.Text:='';
 MemoCatalogPosition.Text:='';
 MemoCatalogAddress.Text:='';
 FDrawWorkTimeList.Clear;
 DrawGridWorkTime.Hide;
 MemoComment.Text:='';
 MemoComment.Hide;

 EditCatalogNumLandline.Enabled:=False;
 ButtonDialLandline.Enabled:=False;
 ButtonToFavLandline.Enabled:=False;

 EditCatalogNumIn.Enabled:=False;
 ButtonDialInternal.Enabled:=False;
 ButtonToFavInternal.Enabled:=False;

 EditCatalogNumCell.Enabled:=False;
 ButtonDialCell.Enabled:=False;
 ButtonToFavCell.Enabled:=False;

 EditCatalogEMail.Enabled:=False;
 ButtonMailTo.Enabled:=False;
end;

procedure TFormMain.ClientSocketAsteriskConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 Log('Соединение установлено');
 if Length(CID) < 4 then
  begin
   Log('Авторизация отменена, т.к. номер некорректен');
   StateChange;
   Exit;
  end;
 ShowErrorConnect:=True;
 Log('Авторизация (astmanproxy)...');
 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Login' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Username: astmanproxy' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Secret: telefon8501525' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Events: ON' + #13#10 + #13#10));

 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Events' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('EventMask: call' + #13#10 + #13#10));
 StateChange;
end;

procedure TFormMain.ClientSocketAsteriskConnecting(Sender: TObject; Socket: TCustomWinSocket);
begin
 Log('Соединение... '+Socket.RemoteAddress);
end;

procedure TFormMain.ClientSocketAsteriskDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
 Log('Соединение разорвано');
 StateChange;
end;

procedure TFormMain.ClientSocketAsteriskError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
 case ErrorEvent of
  eeGeneral: Log('eeGeneral');
  eeSend: Log('eeSend');
  eeReceive: Log('eeReceive');
  eeConnect:
   begin
    Log('Ошибка соединения');
    if ShowErrorConnect then
     begin
      ShowErrorConnect:=False;
      ShowBalloonHintMsg(AppDesc, 'Нет соединения', bfError, TimerAutoConnectTimer);
     end;
   end;
  eeDisconnect: Log('eeDisconnect');
  eeAccept: Log('eeAccept');
  eeLookup: Log('eeLookup');
 end;
 ErrorCode:=0;
 StateChange;
end;

procedure TFormMain.ButtonFavMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button <> mbRight then Exit;
 PopupMenuFavorite.Tag:=(Sender as TButton).Tag;
 PopupMenuFavorite.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.ButtonJournalFilterClick(Sender: TObject);
var i:Integer;
    D1, D2, D3:Double;
    Item:TJournalRec;
begin
 JournalFilter.Clear;
 if Journal.Count > 0 then
  for i:= 0 to Journal.Count - 1 do
   begin
    if FJournalFiltred then
     begin
      Item:=Journal[i];
      D1:=Trunc(TDate(Item.inStart));
      D2:=Trunc(TDate(DateTimePickerJournalFDateB.Date));
      D3:=Trunc(TDate(DateTimePickerJournalFDateE.Date));
      if D1 < D2 then Continue;
      if D1 > D3 then Continue;
      if ComboBoxJournalFType.ItemIndex > 0 then
       if Ord(Item.ItemType) <> (ComboBoxJournalFType.ItemIndex-1) then Continue;
     end;
    Item.ItemID:=i; 
    JournalFilter.Add(Item);
   end;
 TableExJournalList.ItemCount:=JournalFilter.Count;  
end;

procedure TFormMain.ButtonJournalFilterUpdateClick(Sender: TObject);
begin
 FJournalFiltred:=True;
 ButtonJournalFilterClick(nil);
end;

procedure TFormMain.ButtonMailToClick(Sender: TObject);
begin
 if EditCatalogEMail.Text <> '' then
  ShellExecute(Application.Handle, nil, PWideChar('mailto:'+EditCatalogEMail.Text), nil, nil, SW_NORMAL);
end;

procedure TFormMain.ButtonEditAdrClick(Sender: TObject);
begin
 FormMemo.SetData(EditCAddress.Text);
 if FormMemo.ShowModal = mrOK then
  begin
   EditCAddress.Text:=FormMemo.GetData;
  end;
end;

procedure TFormMain.ButtonEditPostionClick(Sender: TObject);
begin
 FormMemo.SetData(EditCPosition.Text);
 if FormMemo.ShowModal = mrOK then
  begin
   EditCPosition.Text:=FormMemo.GetData;
  end;
end;

procedure TFormMain.ButtonEraseClick(Sender: TObject);
begin
 if EditMainNumber.Text <> '' then
  EditMainNumber.Text:=Copy(EditMainNumber.Text, 1, Length(EditMainNumber.Text)-1);
end;

procedure TFormMain.ButtonEraseMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 while IsKeyDown(VK_LBUTTON) do
  begin
   ButtonEraseClick(nil);
   Sleep(100);
   Application.ProcessMessages;
  end;
end;

procedure TFormMain.ButtonDialClick(Sender: TObject);
begin
 if EditMainNumber.Text = '' then
  if Journal.Count > 0 then EditMainNumber.Text:=Journal[0].inNumber;
 Dial(EditMainNumber.Text);
end;

procedure TFormMain.ButtonJFResetClick(Sender: TObject);
begin
 FJournalFiltred:=True;
 DateTimePickerJournalFDateB.DateTime:=EncodeDate(CurrentYear, MonthOf(Now), 1);
 DateTimePickerJournalFDateE.DateTime:=EncodeDate(CurrentYear, MonthOf(Now), DaysInMonth(Now));
 ComboBoxJournalFType.ItemIndex:=0;
 ButtonJournalFilterClick(nil);
end;

procedure TFormMain.ButtonChangeNumberClick(Sender: TObject);
begin
 if CID = GetNumberOnly(EditNumber.Text) then
  begin
   Exit;
  end;

 if EditSecret.Text <> '0021' then
  begin
   ShowMessage('Указанный PIN не позволяет сменить номер');
   Exit;
  end;
 if GetNumberOnly(EditNumber.Text) = '' then Exit;
 CID:=GetNumberOnly(EditNumber.Text);
 EditNumber.Text:=CID;
 if Initialized then
  begin
   if ClientSocketAsterisk.Active then
    begin
     ActionReconExecute(nil);
     Sleep(2000);
     Application.ProcessMessages;
    end;
   if not ClientSocketAsterisk.Active then ActionReconExecute(nil);
   ActionReloadExecute(nil);
  end;
 MessageBox(Application.Handle, 'Вы успешно сменили номер!', 'Информация', MB_ICONINFORMATION or MB_OK);
end;

procedure TFormMain.ButtonChatHelpCloseClick(Sender: TObject);
begin
 PanelChatHelp.Hide;
end;

procedure TFormMain.ButtonChatSendClick(Sender: TObject);
begin
 if EditChatSend.Text <> '' then
  begin
   if ButtonChatSendTo.Visible then
    begin
     ChatSend(EditChatSend.Text, ButtonChatSendTo.Hint);
     //ButtonChatSendTo.Hide;
    end
   else ChatSend(EditChatSend.Text, SendForAll);
   EditChatSend.Text:='';
  end;
 ActiveControl:=EditChatSend;
end;

procedure TFormMain.ButtonChatSendToClick(Sender: TObject);
begin
 ButtonChatSendTo.Hide;
end;

procedure TFormMain.ButtonCECloseClick(Sender: TObject);
begin
 CloseContactForm;
end;

procedure TFormMain.ButtonColorAeroClick(Sender: TObject);
begin
 ButtonsColor:=ColorLighter(GetAeroColor);
 ColorSelectMenu.ColorValue:=ButtonsColor;
end;

procedure TFormMain.ButtonColorAeroMenuClick(Sender: TObject);
begin
 MenuColor:=ColorDarker(GetAeroColor);
 ColorSelectMenuForMenu.ColorValue:=MenuColor;
end;

procedure TFormMain.ButtonColorResetClick(Sender: TObject);
begin
 ButtonsColor:=clDefMenuButtons;
 ColorSelectMenu.ColorValue:=ButtonsColor;
end;

procedure TFormMain.ButtonColorResetMenuClick(Sender: TObject);
begin
 MenuColor:=clDefMenu;
 ColorSelectMenuForMenu.ColorValue:=MenuColor;
end;

procedure TFormMain.ButtonColorSetClick(Sender: TObject);
begin
 ButtonsColor:=ColorLighter(ColorSelectMenu.ColorValue);
end;

procedure TFormMain.ButtonColorSetMenuClick(Sender: TObject);
begin
 MenuColor:=ColorDarker(ColorSelectMenuForMenu.ColorValue);
end;

procedure TFormMain.ButtonAddToFavClick(Sender: TObject);
var sF, sI, sO:string;
    AddNum:TCommonRec;
    aF:array[0..0] of string;
begin
 if FUseMainSub then AddNum:=SelectedNumber else AddNum:=SelectedNumberExt;
 if GetFIO(AddNum.FIO, sF, sI, sO) then AddNum.FIO:=CreateFIO(sF, sI, sO);
 case (Sender as TsSpeedButton).Tag of
  1:AddNum.NumInteranl:=AddNum.NumLandline;
  3:AddNum.NumInteranl:=AddNum.NumCell
 end;
 if AddNum.NumInteranl = '' then Exit;
 aF[0]:=AddNum.FIO;
 if not InputQuery('Надпись в списке избранного', ['Текст'], aF, FInputCloseQueryFav) then Exit;
 AddNum.FIO:=aF[0];
 AddToFavorite(AddNum);
end;

procedure TFormMain.ButtonCallDownClick(Sender: TObject);
begin
 if GlobalState <> gsIdle then ActionHangup(WorkCall.inChannel);
end;

procedure TFormMain.ButtonCallUpClick(Sender: TObject);
begin
 Exit;
 //Попытка сделать поднятие трубки из программы
 {
 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: AGI' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Channel: ' + WorkCall.inChannel + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Command: ANSWER' + #13#10));  }

  {
  Action: AGI
ActionID: <value>
Channel: <value>
Command: <value>
CommandID: <value>

Action: Originate
Channel: SIP/104
Application: PickupChan
Data: SIP/104-0000003c
Priority: 1
Callerid: 104
Variable: SIPADDHEADER="Call-Info:\;answer-after=0"

Action: Originate
Channel: SIP/104
Application: PickupChan
Data: SIP/104-0000003b
  }
 ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Originate' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Channel: SIP/' + CID + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Application: PickupChan'+ #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Data: ' + WorkCall.inChannel + #13#10));
 //ClientSocketAsterisk.Socket.SendText(AnsiString('Priority: 1' + #13#10));
 //ClientSocketAsterisk.Socket.SendText(AnsiString('Callerid: ' + CID + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Variable: SIPADDHEADER="Call-Info:\;answer-after=0"' + #13#10));
 ClientSocketAsterisk.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));


end;

procedure TFormMain.ButtonedEditOtherRightButtonClick(Sender: TObject);
begin
 ListBoxOther.ItemIndex:=SearchOther(OtherNums, ButtonedEditOther.Text);
 ListBoxOtherClick(ListBoxOther);
end;

procedure TFormMain.ButtonedEditDepartSearchChange(Sender: TObject);
begin
 if SearchDepart(ButtonedEditDepartSearch.Text) then TableExDepart.DoItemClick;
end;

procedure TFormMain.ButtonedEditSearchChange(Sender: TObject);
begin
 if SearchOffice(ButtonedEditSearch.Text) then TableExOffice.DoItemClick;
end;

procedure TFormMain.ButtonedEditSearchGlobalChange(Sender: TObject);
var i, r:Integer;
    aText:string;
    CS, SA:Boolean;

function GetNumberOEIN(inNum:string):string;
var i:Integer;
begin
 Result:='';
 if Length(inNum) > 0 then
  for i:= 0 to Length(inNum) do
   if CharInSet(inNum[i], ['0'..'9']) then Result:=Result+inNum[i];
 if Result = '' then Result:=inNum;
end;

function IsConNumber(Text:string; Elem:TNumberRec):Boolean;
begin
 Result:=
     ((Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.FIO))         <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Position))    <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumInteranl)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumLandline)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumCell))     <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.EMail))       <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Address))     <> 0));
end;

function IsConDepart(Text:string; Elem:TDepartRec):Boolean;
begin
 Result:=
     ((Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.FIO))         <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Position))    <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Name))        <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumInteranl)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumLandline)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumCell))     <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.EMail))       <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Address))     <> 0));
end;

function IsConCommon(Text:string; Elem:TCommonRec):Boolean;
begin
 Result:=
     ((Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.FIO))         <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Position))    <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumInteranl)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumLandline)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumCell))     <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.EMail))       <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Address))     <> 0));
end;

function IsConOther(Text:string; Elem:TOtherRec):Boolean;
begin
 Result:=
     ((Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.FIO))         <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Position))    <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumInteranl)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumLandline)) <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.NumCell))     <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.EMail))       <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Commnet))     <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Address))     <> 0));
end;

function IsConObject(Text:string; Elem:TBranchNumber):Boolean;
begin
 Result:=
     ((Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Name))        <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.Number))      <> 0) or
      (Pos(GetNumberOEIN(Text), GetNumberOEIN(Elem.FAX))         <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.EMail))       <> 0) or
      (Pos(AnsiLowerCase(Text), AnsiLowerCase(Elem.Address))     <> 0));
end;

procedure InsertNumber(Elem:TNumberRec);
begin
 StringGridGlobal.Cells[0, r]:= Elem.FIO;
 StringGridGlobal.Cells[1, r]:= Elem.Position;

 StringGridGlobal.Cells[3, r]:= Elem.NumInteranl;
 StringGridGlobal.Cells[4, r]:= Elem.NumLandline;
 StringGridGlobal.Cells[5, r]:= Elem.NumCell;
 StringGridGlobal.Cells[6, r]:= Elem.EMail;
 StringGridGlobal.Cells[7, r]:= Elem.Address;
 StringGridGlobal.Cells[8, r]:= '';
 StringGridGlobal.Cells[9, r]:= Elem.Position;

 if Elem.NumInteranl  <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumInteranl
 else
  if Elem.NumLandline <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumLandline
  else
   if Elem.NumCell    <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumCell
   else
                                 StringGridGlobal.Cells[2, r]:= Elem.EMail;

 Inc(r);
 StringGridGlobal.RowCount:=r;
end;

procedure InsertDepart(Elem:TDepartRec);
begin
 StringGridGlobal.Cells[0, r]:= Elem.Name;
 StringGridGlobal.Cells[1, r]:= Elem.FIO;

 StringGridGlobal.Cells[3, r]:= Elem.NumInteranl;
 StringGridGlobal.Cells[4, r]:= Elem.NumLandline;
 StringGridGlobal.Cells[5, r]:= Elem.NumCell;
 StringGridGlobal.Cells[6, r]:= Elem.EMail;
 StringGridGlobal.Cells[7, r]:= Elem.Address;
 StringGridGlobal.Cells[8, r]:= '';
 StringGridGlobal.Cells[9, r]:= Elem.Position;

 if Elem.NumInteranl  <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumInteranl
 else
  if Elem.NumLandline <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumLandline
  else
   if Elem.NumCell    <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumCell
   else
    if Elem.Address   <> '' then StringGridGlobal.Cells[2, r]:= Elem.Address
    else
                                 StringGridGlobal.Cells[2, r]:= Elem.EMail;

 Inc(r);
 StringGridGlobal.RowCount:=r;
end;

procedure InsertCommon(Elem:TCommonRec);
begin
 StringGridGlobal.Cells[0, r]:= Elem.FIO;
 StringGridGlobal.Cells[1, r]:= Elem.Position;

 StringGridGlobal.Cells[3, r]:= Elem.NumInteranl;
 StringGridGlobal.Cells[4, r]:= Elem.NumLandline;
 StringGridGlobal.Cells[5, r]:= Elem.NumCell;
 StringGridGlobal.Cells[6, r]:= Elem.EMail;
 StringGridGlobal.Cells[7, r]:= Elem.Address;
 StringGridGlobal.Cells[8, r]:= '';
 StringGridGlobal.Cells[9, r]:= Elem.Position;

 if Elem.NumInteranl  <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumInteranl
 else
  if Elem.NumLandline <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumLandline
  else
   if Elem.NumCell    <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumCell
   else
                                 StringGridGlobal.Cells[2, r]:= Elem.EMail;

 Inc(r);
 StringGridGlobal.RowCount:=r;
end;

procedure InsertObject(Elem:TBranchNumber);
begin
 StringGridGlobal.Cells[0, r]:= Elem.Name;
 StringGridGlobal.Cells[1, r]:= Elem.Address;

 StringGridGlobal.Cells[3, r]:= '';
 StringGridGlobal.Cells[4, r]:= Elem.Number;
 StringGridGlobal.Cells[5, r]:= Elem.FAX;
 StringGridGlobal.Cells[6, r]:= Elem.EMail;
 StringGridGlobal.Cells[7, r]:= Elem.Address;
 StringGridGlobal.Cells[8, r]:= '';
 StringGridGlobal.Cells[9, r]:= '';

 if Elem.Number  <> '' then StringGridGlobal.Cells[2, r]:= Elem.Number
 else
  if Elem.FAX    <> '' then StringGridGlobal.Cells[2, r]:= Elem.FAX
  else
   if Elem.EMail <> '' then StringGridGlobal.Cells[2, r]:= Elem.EMail;

 Inc(r);
 StringGridGlobal.RowCount:=r;
end;

procedure InsertOther(Elem:TOtherRec);
begin
 StringGridGlobal.Cells[0, r]:= Elem.FIO;
 StringGridGlobal.Cells[1, r]:= Elem.Position;
 if StringGridGlobal.Cells[1, r] = '' then StringGridGlobal.Cells[1, r]:=Elem.Commnet;

 StringGridGlobal.Cells[3, r]:= Elem.NumInteranl;
 StringGridGlobal.Cells[4, r]:= Elem.NumLandline;
 StringGridGlobal.Cells[5, r]:= Elem.NumCell;
 StringGridGlobal.Cells[6, r]:= Elem.EMail;
 StringGridGlobal.Cells[7, r]:= Elem.Address;
 StringGridGlobal.Cells[8, r]:= Elem.Commnet;
 StringGridGlobal.Cells[9, r]:= Elem.Position;

 if Elem.NumInteranl  <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumInteranl
 else
  if Elem.NumLandline <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumLandline
  else
   if Elem.NumCell    <> '' then StringGridGlobal.Cells[2, r]:= Elem.NumCell
   else
                                 StringGridGlobal.Cells[2, r]:= Elem.EMail;

 Inc(r);
 StringGridGlobal.RowCount:=r;
end;

begin
 GridClear(StringGridGlobal);
 aText:=ButtonedEditSearchGlobal.Text;
 if Pos('+7', aText) <> 0 then Delete(aText, 1, 2);
 while Pos('-', aText) <> 0 do Delete(aText, Pos('-', aText), 1);

 if Length(aText) < 2 then Exit;
 SA:=aText = 'Всё';
 r:=0;
 //Поиск в "прочее"
 if OtherNums.Count > 0 then
  for i:=0 to OtherNums.Count - 1 do
   if IsConOther(aText, OtherNums[i]) or SA      then InsertOther(OtherNums[i]);
 //Поиск в офисе
 if OfficeNums.Count > 0 then
  for i:=0 to OfficeNums.Count - 1 do
   if IsConNumber(aText, OfficeNums[i]) or SA    then InsertNumber(OfficeNums[i]);
 //Поиск в отделах
 if DepartNums.Count > 0 then
  for i:=0 to DepartNums.Count - 1 do
   if IsConDepart(aText, DepartNums[i]) or SA    then InsertDepart(DepartNums[i]);
 //Поиск в ломбардах
 if BranchNums.Count > 0 then
  for i:=0 to BranchNums.Count - 1 do
   if IsConObject(aText, BranchNums[i]) or SA    then InsertObject(BranchNums[i]);
 //Поиск в скупке Гранула
 if BuyingNums.Count > 0 then
  for i:=0 to BuyingNums.Count - 1 do
    if IsConObject(aText, BuyingNums[i]) or SA   then InsertObject(BuyingNums[i]);
 //Поиск в скупке ДС
 if BuyingSNums.Count > 0 then
   for i:=0 to BuyingSNums.Count - 1 do
     if IsConObject(aText, BuyingSNums[i]) or SA then InsertObject(BuyingSNums[i]);
 //Поиск в магазинах
 if ShopsNums.Count > 0 then
  for i:=0 to ShopsNums.Count - 1 do
    if IsConObject(aText, ShopsNums[i]) or SA    then InsertObject(ShopsNums[i]);
 //Поиск в избранном
 if FavoriteNums.Count > 0 then
  for i:=0 to FavoriteNums.Count - 1 do
   if IsConCommon(aText, FavoriteNums[i]) or SA  then InsertCommon(FavoriteNums[i]);
 //Поиск завершён
 StringGridGlobal.RowCount:=r;
 StringGridGlobalSelectCell(nil, 0, 0, CS);
end;

procedure TFormMain.ButtonedEditSearchKeyPress(Sender: TObject; var Key: Char);
begin
 if Key = #13 then
  begin
   Key:=#0;
   (Sender as TButtonedEdit).OnRightButtonClick(Sender);
  end;
end;

procedure TFormMain.ButtonNumberClick(Sender: TObject);
begin
 InsertNumber((Sender as TButton).Hint);
end;

procedure TFormMain.ButtonOKClick(Sender: TObject);
var ADOConnection:TADOConnection;
    Query:TADOQuery;
    ORec:TOtherRec;
begin
 if Length(EditCFIO.Text) < 3 then
  begin
   MessageBox(Application.Handle, 'Неверно заполнено поле "Полное имя". Имя должно иметь больше двух символов!', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 if not CreateConnection(ADOConnection) then
  begin
   MessageBox(Application.Handle, 'Нет соединения. Изменение контакта невозможно.', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 case FCurrentCEMode of
  cemNone: ;
  cemEdit:
   begin
    begin
     ORec:=OtherNums[FCurrentCEEditIndex];
     Query:=TADOQuery.Create(nil);
     Query.Connection:=ADOConnection;
     Query.ExecuteOptions:=[eoExecuteNoRecords];
     Query.SQL.Text:='UPDATE sCallDop SET '+
      ' [UserId] = '+QuotedStr(ORec.UserID)+', '+
      ' [NamePl] = '+QuotedStr(EditCFIO.Text)+', '+
      ' [Dolj] = '+QuotedStr(EditCPosition.Text)+', '+
      ' [Adr] = '+QuotedStr(EditCAddress.Text)+', '+
      ' [mail] = '+QuotedStr(EditCMail.Text)+', '+
      ' [Tel1] = '+QuotedStr(EditCLand.Text)+', '+
      ' [Tel2] = '+QuotedStr(EditCCell.Text)+', '+
      ' [IPtel] = '+QuotedStr(EditCIn.Text)+', '+
      ' [Comment] = '+QuotedStr(MemoCComment.Text)+', '+
      ' [xSha] = '+QuotedStr(IntToStr(Ord(not CheckBoxShare.Checked)-1))+' WHERE nRecCallDop = '+QuotedStr(IntToStr(ORec.nRecCallDop));
     try
      Query.ExecSQL();
      ORec.FIO:=EditCFIO.Text;
      ORec.Position:=EditCPosition.Text;
      ORec.Address:=EditCAddress.Text;
      ORec.EMail:=EditCMail.Text;
      ORec.NumLandline:=EditCLand.Text;
      ORec.NumCell:=EditCCell.Text;
      ORec.NumInteranl:=EditCIn.Text;
      ORec.Commnet:=MemoCComment.Text;
      ORec.xSha:=CheckBoxShare.Checked;
      OtherNums[FCurrentCEEditIndex]:=ORec;
      ListBoxOther.Repaint;
      ListBoxOtherClick(ListBoxOther);
     except
      Log('Ошибка при изменении контакта');
     end;
     Query.Free;
     ADOConnection.Free;
    end;
   end;
  cemAdd:
   begin
    begin
     Query:=TADOQuery.Create(nil);
     Query.Connection:=ADOConnection;
     Query.ExecuteOptions:=[];
     Query.SQL.Text:='INSERT INTO sCallDop ([UserId], [NamePl], [Dolj], [Adr], [mail], [Tel1], [Tel2], [IPtel], [Comment], [xSha]) VALUES ('+
      QuotedStr(CID)+', '+
      QuotedStr(EditCFIO.Text)+', '+
      QuotedStr(EditCPosition.Text)+', '+
      QuotedStr(EditCAddress.Text)+', '+
      QuotedStr(GetNumberOnly(EditCMail.Text))+', '+
      QuotedStr(GetNumberOnly(EditCLand.Text))+', '+
      QuotedStr(GetNumberOnly(EditCCell.Text))+', '+
      QuotedStr(EditCIn.Text)+', '+
      QuotedStr(MemoCComment.Text)+', '+
      QuotedStr(IntToStr(Ord(not CheckBoxShare.Checked)-1))+')';
     Query.SQL.Add('SELECT @@IDENTITY');
     try
      Query.Open;
      ORec.nRecCallDop:=Query.Fields[0].AsInteger;
      ORec.UserID:=CID;
      ORec.FIO:=EditCFIO.Text;
      ORec.Position:=EditCPosition.Text;
      ORec.Address:=EditCAddress.Text;
      ORec.EMail:=EditCMail.Text;
      ORec.NumLandline:=EditCLand.Text;
      ORec.NumCell:=EditCCell.Text;
      ORec.NumInteranl:=EditCIn.Text;
      ORec.Commnet:=MemoCComment.Text;
      ORec.xSha:=CheckBoxShare.Checked;
      OtherNums.Add(ORec);
      ListBoxOther.Items.Add('');
     except
      Log('Ошибка при добавлении контакта в elix');
     end;
     Query.Free;
     ADOConnection.Free;
    end;
   end;
  cemShow: ;
 end;
 CloseContactForm;
end;

procedure TFormMain.ButtonOtherDeleteClick(Sender: TObject);
var ADOConnection:TADOConnection;
    Query:TADOQuery;
    ORec:TOtherRec;
    i:Integer;
begin
 if ListBoxOther.ItemIndex < 0 then Exit;
 if Length(CID) < 2 then Exit;
 i:=ListBoxOther.ItemIndex;
 try
  ORec:=OtherNums[i];
 except
  Exit;
 end;
 if not CreateConnection(ADOConnection) then
  begin
   MessageBox(Application.Handle, 'Нет соединения. Изменение контакта невозможно.', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 if ORec.xSha then
  begin
   if MessageBox(Application.Handle, 'Выбранная запись доступна всем, вы действительно хотите её удалить?', '', MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2) <> ID_YES then Exit;
  end
 else
  begin
   if MessageBox(Application.Handle, 'Удалить выбранную запись?', '', MB_ICONWARNING or MB_YESNO or MB_DEFBUTTON2) <> ID_YES then Exit;
  end;

 Query:=TADOQuery.Create(nil);
 Query.Connection:=ADOConnection;
 Query.ExecuteOptions:=[eoExecuteNoRecords];
 Query.SQL.Text:='DELETE FROM [sCallDop] WHERE nRecCallDop = '+QuotedStr(IntToStr(ORec.nRecCallDop));
 try
  Query.ExecSQL();
  OtherNums.Delete(i);
  ListBoxOther.Items.Delete(0);
  ListBoxOther.Repaint;
  ListBoxOtherClick(ListBoxOther);
 except
  begin
   MessageBox(Application.Handle, 'Произошла ошибка во время удаления записи. Попробуйте позже или обратитесь к администратору.', '', MB_ICONERROR or MB_OK);
   Exit;
  end;
 end;
 Query.Free;
 ADOConnection.Free;
end;

procedure TFormMain.ButtonOtherEditClick(Sender: TObject);
var ADOConnection:TADOConnection;
    ORec:TOtherRec;
begin
 if ListBoxOther.ItemIndex < 0 then Exit;
 if Length(CID) < 2 then Exit;
 FCurrentCEEditIndex:=ListBoxOther.ItemIndex;
 try
  ORec:=OtherNums[FCurrentCEEditIndex];
 except
  Exit;
 end;
 EditCFIO.Text:=ORec.FIO;
 EditCMail.Text:=ORec.EMail;
 EditCLandIn.Text:=ORec.NumLandline;
 EditCInternalIn.Text:=ORec.NumInteranl;
 EditCCellIn.Text:=ORec.NumCell;
 CheckBoxShare.Checked:=ORec.xSha;
 MemoCComment.Text:=ORec.Commnet;
 EditCPosition.Text:=ORec.Position;
 EditCAddress.Text:=ORec.Address;
 if not CreateConnection(ADOConnection) then
  begin
   MessageBox(Application.Handle, 'Нет соединения. Изменение контакта невозможно.', 'Внимание', MB_ICONWARNING or MB_OK);
   Exit;
  end;
 ShowContactForm(cemEdit);
 Exit;
 {with FormOtherEdit do
  begin
   EditCatalogFIO.Text:=ORec.FIO;
   EditCatalogEMail.Text:=ORec.EMail;
   EditCatalogNumLandline.Text:=ORec.NumLandline;
   EditCatalogNumIn.Text:=ORec.NumInteranl;
   EditCatalogNumCell.Text:=ORec.NumCell;
   CheckBoxShare.Checked:=ORec.xSha;
   MemoComment.Text:=ORec.Commnet;
   EditPosition.Text:=ORec.Position;
   EditAddress.Text:=ORec.Address;

   if not CreateConnection(ADOConnection) then
    begin
     MessageBox(Application.Handle, 'Нет соединения. Изменение контакта невозможно.', 'Внимание', MB_ICONWARNING or MB_OK);
     Exit;
    end;

   if ShowModal = mrOK then
    begin
     Query:=TADOQuery.Create(nil);
     Query.Connection:=ADOConnection;
     Query.ExecuteOptions:=[eoExecuteNoRecords];
     Query.SQL.Text:='UPDATE sCallDop SET '+
      ' [UserId] = '+QuotedStr(ORec.UserID)+', '+
      ' [NamePl] = '+QuotedStr(EditCatalogFIO.Text)+', '+
      ' [Dolj] = '+QuotedStr(EditPosition.Text)+', '+
      ' [Adr] = '+QuotedStr(EditAddress.Text)+', '+
      ' [mail] = '+QuotedStr(EditCatalogEMail.Text)+', '+
      ' [Tel1] = '+QuotedStr(EditLand.Text)+', '+
      ' [Tel2] = '+QuotedStr(EditCell.Text)+', '+
      ' [IPtel] = '+QuotedStr(EditIn.Text)+', '+
      ' [Comment] = '+QuotedStr(MemoComment.Text)+', '+
      ' [xSha] = '+QuotedStr(IntToStr(Ord(not CheckBoxShare.Checked)-1))+' WHERE nRecCallDop = '+QuotedStr(IntToStr(ORec.nRecCallDop));
     try
      Query.ExecSQL();
      ORec.FIO:=EditCatalogFIO.Text;
      ORec.Position:=EditPosition.Text;
      ORec.Address:=EditAddress.Text;
      ORec.EMail:=EditCatalogEMail.Text;
      ORec.NumLandline:=EditLand.Text;
      ORec.NumCell:=EditCell.Text;
      ORec.NumInteranl:=EditIn.Text;
      ORec.Commnet:=MemoComment.Text;
      ORec.xSha:=CheckBoxShare.Checked;
      OtherNums[i]:=ORec;
      ListBoxOther.Repaint;
      ListBoxOtherClick(ListBoxOther);
     except
      Log('Ошибка при изменении контакта');
     end;
     Query.Free;
     ADOConnection.Free;
    end;
  end;   }
end;

procedure TFormMain.ButtonPanelHideClick(Sender: TObject);
begin
 DialupHide;
 if GlobalState <> gsIdle then FormDialing.ShowDial;
end;

function TFormMain.SortOtherItem(i1, i2:Integer):Boolean;
begin
 Result:=False;
 if not FSortOtherASC then
  case FSortOtherBy of
   0: Result:=AnsiCompareStr(OtherNums[i1].FIO, OtherNums[i2].FIO) > 0;
   1: Result:=AnsiCompareStr(OtherNums[i1].Commnet, OtherNums[i2].Commnet) > 0;
  end
 else
  case FSortOtherBy of
   0: Result:=AnsiCompareStr(OtherNums[i1].FIO, OtherNums[i2].FIO) < 0;
   1: Result:=AnsiCompareStr(OtherNums[i1].Commnet, OtherNums[i2].Commnet) < 0;
  end;
end;

procedure TFormMain.Sound(What: TSoundType);
begin
 case What of
  stChat:     PlaySound('NEWMESSAGE', 0, SND_ASYNC or SND_RESOURCE);
 {$IFNDEF DEBUG}
  stStart:    PlaySound('STARTUP',    0, SND_ASYNC or SND_RESOURCE);
  stShutdown: PlaySound('SHUTDOWN',   0, SND_SYNC  or SND_RESOURCE);
 {$ENDIF}
 end;
end;

procedure TFormMain.ButtonSettingsScaleSetClick(Sender: TObject);
begin
 WindScale:=TrackBarScale.Position;
 MessageBox(Application.Handle, 'Для применения изменений, перезагрузите программу.', '', MB_ICONASTERISK or MB_OK);
end;

procedure TFormMain.ButtonSortClick(Sender: TObject);
begin
 PopupMenuSortOther.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.ButtonStopUpdateClick(Sender: TObject);
begin
 if StopUpdate then
  begin
   PanelDownloading.Hide;
   Exit;
  end;
 if MessageBox(Application.Handle, 'Отменить загрузку обновлений?', '', MB_ICONWARNING or MB_YESNO) <> ID_YES then Exit;
 StopUpdate:=True;
end;

procedure TFormMain.ClientSocketAsteriskRead(Sender: TObject; Socket: TCustomWinSocket);
var MSG, CurEvent:string;
    i:integer;
    ProcData:TStringList;
    MSGData:TStringList;

procedure EventDial(Data:TStringList);
var inNum, inChn, inSubj, Destination, SubEvent:string;
    i:Integer;
    Exten:Boolean;
begin
 Exten:=False;
 if Data.IndexOf('CallerIDNum: '+CID) < 0 then
  begin
   Exten:=True;
   if Data.IndexOf('Channel: '+WorkCall.inChannel) < 0 then Exit;
   Log('Exten:=True; Channel: '+WorkCall.inChannel);
  end;
 for i:=0 to Data.Count - 1 do
  begin
   if Pos('SubEvent: ', Data.Strings[i]) = 1 then
    begin
     SubEvent:=Copy(Data.Strings[i], Length('SubEvent: ')+1, 100);
     if SubEvent <> 'Begin' then Exit;
    end;
  end;
 //Данные звонка
 Log('Звонок'#13#10+Data.Text+#13#10);
 if Exten then
  begin
   for i:=0 to Data.Count - 1 do
    begin
     if Pos('Destination: ', Data.Strings[i]) = 1 then
      Destination:=Copy(Data.Strings[i], Length('Destination: ')+1, 100);
     if Pos('ConnectedLineNum: ', Data.Strings[i]) = 1 then
      inNum:=Copy(Data.Strings[i], Length('ConnectedLineNum: ')+1, 100);
    end;
   EventDialing(inNum, WorkCall.inSubject, Destination, WorkCall.ItemType);
  end
 else
  begin
   for i:=0 to Data.Count - 1 do
    begin
     if Pos('ConnectedLineNum: ', Data.Strings[i]) = 1 then
      inNum:=Copy(Data.Strings[i], Length('ConnectedLineNum: ')+1, 100);
     if Pos('ConnectedLineName: ', Data.Strings[i]) = 1 then
      inSubj:=Copy(Data.Strings[i], Length('ConnectedLineName: ')+1, 100);
     if Pos('Channel: ', Data.Strings[i]) = 1 then
      inChn:=Copy(Data.Strings[i], Length('Channel: ')+1, 100);
     if (inNum <> '') and (inSubj <> '') and (inChn <> '') then Break;
    end;
   EventDialing(inNum, inSubj, inChn, jtDialing);
  end;
end;

procedure EventHangup(Data:TStringList);
var Cause, c1, c2, Channel:string;
   i:Integer;
begin
 if GlobalState = gsIdle then Exit;
 if Data.IndexOf('CallerIDNum: '+CID) < 0 then
  if Data.IndexOf('Channel: '+WorkCall.inChannel) < 0 then
   if Data.IndexOf('Channel: '+WorkCall.inExtenChannel) < 0 then Exit;
 Log('Сброс трубки'#13#10+Data.Text+#13#10);
 for i:=0 to Data.Count - 1 do
  begin
   if Pos('Cause: ', Data.Strings[i]) = 1 then
    Cause:=Copy(Data.Strings[i], Length('Cause: ')+1, 100);
   if Pos('CallerIDNum: ', Data.Strings[i]) = 1 then
    c1:=Copy(Data.Strings[i], Length('CallerIDNum: ')+1, 100);
   if Pos('ConnectedLineNum: ', Data.Strings[i]) = 1 then
    c2:=Copy(Data.Strings[i], Length('ConnectedLineNum: ')+1, 100);
   if Pos('Channel: ', Data.Strings[i]) = 1 then
    Channel:=Copy(Data.Strings[i], Length('Channel: ')+1, 100);
  end;    {
 if GlobalState = gsDial then
  if (Copy(Channel, 1, 3) <> 'SIP') or (Copy(Channel, 1, 5) <> 'DAHDI') then
   begin
    Exit;
   end;   }
 EventOnHangup(Cause, c1 <> c2);
end;

procedure EventBridge(Data:TStringList);
var Bridgestate, Channel1:string;
    i:Integer;
begin
 if Data.IndexOf('CallerID2: '+CID) < 0 then Exit;
 Log('EventBridge'#13#10+Data.Text+#13#10);
 for i:=0 to Data.Count - 1 do
  begin
   if Pos('Bridgestate: ', Data.Strings[i]) = 1 then
    begin
     Bridgestate:=Copy(Data.Strings[i], Length('Bridgestate: ')+1, 100);
     if Bridgestate <> 'Link' then Exit;
    end;
   if Pos('Channel1: ', Data.Strings[i]) = 1 then
    Channel1:=Copy(Data.Strings[i], Length('Channel1: ')+1, 100);
  end;
 //Доп. канал
 WorkCall.inExtenChannel:=Channel1;
end;

procedure EventOriginateResponse(Data:TStringList);
var Channel, Exten, Response:string;
    i:Integer;
begin
 if Data.IndexOf('CallerIDNum: '+CID) < 0 then Exit;
 Log('EventOriginateResponse'#13#10+Data.Text+#13#10);
 for i:=0 to Data.Count - 1 do
  begin
   if Pos('Exten: ', Data.Strings[i]) = 1 then
    Exten:=Copy(Data.Strings[i], Length('Exten: ')+1, 100);
   if Pos('Channel: ', Data.Strings[i]) = 1 then
    Channel:=Copy(Data.Strings[i], Length('Channel: ')+1, 100);
   if Pos('Response: ', Data.Strings[i]) = 1 then
    begin
     Response:=Copy(Data.Strings[i], Length('Response: ')+1, 100);
     if Response <> 'Success' then Exit;
    end;
  end;
 //Набор внешнего номера
 EventDialing(Exten, 'Внешний номер', Channel, jtDialing);
end;

procedure EventNewstate(Data:TStringList);
var ChannelState,
    CallerIDNum,
    CallerIDName,
    ConnectedLineNum,
    ConnectedLineName,
    Channel:string;
    i:Integer;
    Exten:Boolean;
begin
 Exten:=False;
 if Data.IndexOf('CallerIDNum: '+CID) < 0 then
  if Data.IndexOf('ConnectedLineNum: '+CID) < 0 then
   begin
    Exten:=True;
    if Data.IndexOf('Channel: '+WorkCall.inChannel) < 0 then Exit;
   end;
 Log('Изменение канала'#13#10+Data.Text+#13#10);
 ChannelState:='';
 CallerIDNum:='';
 CallerIDName:='';
 ConnectedLineNum:='';
 ConnectedLineName:='';
 Channel:='';

 //Если звоним на внешний номер
 if Exten then
  begin
   //Собираем данные
   for i:=0 to Data.Count - 1 do
    begin
     if Pos('ChannelState: ', Data.Strings[i]) = 1 then
      ChannelState:=Copy(Data.Strings[i], Length('ChannelState: ')+1, 100);
     if Pos('CallerIDNum: ', Data.Strings[i]) = 1 then
      CallerIDNum:=Copy(Data.Strings[i], Length('CallerIDNum: ')+1, 100);
    end;
   if ChannelState = '6' then
    begin
     EventDialup(CallerIDNum, 'Внешний номер ('+CallerIDNum+')', WorkCall.inChannel, WorkCall.ItemType);
    end;
   Exit;
  end;

 //Собираем данные
 for i:=0 to Data.Count - 1 do
  begin
   if Pos('Channel: ', Data.Strings[i]) = 1 then
    Channel:=Copy(Data.Strings[i], Length('Channel: ')+1, 100);
   if Pos('ChannelState: ', Data.Strings[i]) = 1 then
    ChannelState:=Copy(Data.Strings[i], Length('ChannelState: ')+1, 100);
   if Pos('CallerIDNum: ', Data.Strings[i]) = 1 then
    CallerIDNum:=Copy(Data.Strings[i], Length('CallerIDNum: ')+1, 100);
   if Pos('CallerIDName: ', Data.Strings[i]) = 1 then
    CallerIDName:=Copy(Data.Strings[i], Length('CallerIDName: ')+1, 100);
   if Pos('ConnectedLineNum: ', Data.Strings[i]) = 1 then
    ConnectedLineNum:=Copy(Data.Strings[i], Length('ConnectedLineNum: ')+1, 100);
   if Pos('ConnectedLineName: ', Data.Strings[i]) = 1 then
    ConnectedLineName:=Copy(Data.Strings[i], Length('ConnectedLineName: ')+1, 100);
  end;

 //Звоним сами себе 1210 - 1210
 if (CallerIDNum = CID) and (ConnectedLineNum = CID) then
  begin //Идёт звонок (входящий)
   if ChannelState = '5' then EventIncomingCall('Подготовка к вызову', CID, Channel);
  end
 else //Звоним кому-то 1210 - 1209
  if (CallerIDNum = CID) and (ConnectedLineNum <> CID) then
   begin //Исходящий звонок
    if ChannelState = '4' then EventDialup(ConnectedLineNum, ConnectedLineName, Channel, jtDialing)
    else //Входящий звонок
    if ChannelState = '5' then
     begin
      if GlobalState <> gsDial then EventIncomingCall(ConnectedLineNum, ConnectedLineName, Channel);
     end
    else //Поднял трубку (обновляем данные)
    if ChannelState = '6' then EventDialup(ConnectedLineNum, WorkCall.inSubject, Channel, WorkCall.ItemType);
   end
  else //Звонят нам 1209 - 1210
   if (CallerIDNum <> CID) and (ConnectedLineNum = CID) then
    begin
     if ChannelState = '6' then EventDialup(WorkCall.inNumber, WorkCall.inSubject, Channel, WorkCall.ItemType);
    end;
end;

begin
 try
  DataIn:=DataIn+ClientSocketAsterisk.Socket.ReceiveLength;
  MSG:=UTF8ToString(ClientSocketAsterisk.Socket.ReceiveText);
 except
  begin
   Log('except ClientSocketAsteriskRead');
   Exit;
  end;
 end;
 if AsteriskMute then
  begin
   Log('Сообщение от Asterisk проигнорировано (AsteriskMute is True)');
   Exit;
  end;

 {$IFDEF DEBUG}
 Log(MSG);
 {$ENDIF}

 MSGData:=TStringList.Create;
 MSGData.Text:=MSG;

 if MSGData.Count > 0 then
  begin
   ProcData:=TStringList.Create;
   for i:= 0 to MSGData.Count - 1 do
    begin
     if (Pos('Event:', MSGData.Strings[i]) = 1) or (MSGData.Strings[i] = '')
     then
      begin
       //Если не идёт сбор данных
       if CurEvent = '' then
        begin
         CurEvent:=MSGData.Strings[i];
         ProcData.Clear;
        end
       else
        begin
         if CurEvent = 'Event: Dial' then EventDial(ProcData) else
          if CurEvent = 'Event: Newstate' then EventNewstate(ProcData) else
           if CurEvent = 'Event: OriginateResponse' then EventOriginateResponse(ProcData) else
            if CurEvent = 'Event: Bridge' then EventBridge(ProcData) else
             if CurEvent = 'Event: Hangup' then EventHangup(ProcData);
         CurEvent:='';
         ProcData.Clear;
        end;
      end;
     ProcData.Add(MSGData.Strings[i]);
    end;
   ProcData.Free;
  end;
 MSGData.Free;
End;

procedure TFormMain.ClientSocketAsteriskWrite(Sender: TObject; Socket: TCustomWinSocket);
begin
 DataOut:=DataOut+(ClientSocketAsterisk.Socket.ReceiveLength);
end;

procedure TFormMain.CloseContactForm;
begin
 SetFrame(wfMain);
end;

procedure TFormMain.CloseSettings;
begin
 SetFrame(wfMain);
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:=False;
 if ShowInfoTray and (GlobalState = gsIdle) then
  begin
   ShowInfoTray:=False;
   ShowBalloonHintMsg('Программа всё ещё работает', 'Щёлкните по иконке в трее, чтобы снова открыть программу', bfInfo, nil);
  end;
 ButtonPanelHideClick(nil);
 Hide;
end;

procedure TFormMain.SetMenuIconColor(Color:TColor);
var i:Integer;
begin
 for i:= 0 to ImageList24.Count - 1 do ColorImages(ImageList24, i, Color);
end;

procedure TFormMain.SetMenuPanelColor(aColor:TColor);
var i:Integer;
    LC:TColor;
begin
 PanelMenu.Color:=aColor;
 PanelDialup.Color:=aColor;
 PanelDialupLeft.Color:=ColorLighter(aColor, 30);
 ShapeChatSend.Brush.Color:=aColor;
 ShapeChatSend.Pen.Color:=aColor;
 PanelDownloading.Color:=aColor;
 PanelDownLHead.Color:=ColorLighter(aColor, 30);
 ProgressBarUpdate.ForeColor:=ColorLighter(aColor, 20);
 clLISelect:=ColorLighter(PanelMenu.Color, 10);
 ButtonDialGroup.Color:=clLISelect;
 ColorImages(ImageListDialGroup, 0, ColorLighter(aColor, 50));
 ColorImages(ImageListDialGroup, 1, ColorLighter(aColor, 60));
 ColorImages(ImageListDialGroup, 2, ColorLighter(aColor, 40));

 TableExOffice.LineSelColor:=clLISelect;
 TableExOffice.LineColor:=clWhite;
 TableExOffice.LineColorXor:=ColorDarker(clWhite, 2);

 TableExDepart.LineSelColor:=clLISelect;
 TableExDepart.LineColor:=clWhite;
 TableExDepart.LineColorXor:=ColorDarker(clWhite, 2);

 //ListBoxGroups.Color:=ColorLighter(clLISelect, 35);

 ImageListDialGroup.GetIcon(0, ImageDialGroup.Picture.Icon);
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

 PanelStatusBar.Color:=aColor;
 for i:=0 to PanelStatusBar.ControlCount - 1 do
  begin
   if PanelStatusBar.Controls[i] is TShape then
    begin
     (PanelStatusBar.Controls[i] as TShape).Pen.Color:=ColorDarker(aColor, 10);
     (PanelStatusBar.Controls[i] as TShape).Brush.Color:=ColorDarker(aColor, 10);
    end;
  end;

 LC:=ColorLighter(aColor, 20);
 ListBoxGroups.Color:=LC;
 TableExOffice.Color:=LC;
 TableExOffice.LineColor:=LC;
 TableExOffice.LineColorXor:=ColorDarker(LC, 10);

end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
 Log('Версия: '+Version.Version);
 Randomize;
 FCurrentCEMode:=cemNone;
 FDrawWorkTimeList:=TStringList.Create;
 CurColorDial:=$0014C36C;
 FButtonDialHint:='Позвонить';
 ColorImages(ImageListNumbers, 10, $004B4B4B);
 ColorImages(ImageListNumbers, 11, CurColorDial);
 ColorImages(ImageListNumbers, 12, CurColorDisable);
 AnonNum:=IntToStr(RandomRange(99999, 999999999));
 FFirstRun:=True;
 PanelTutorialHelp.Left:=50;
 RunDate:=Now;
 FromColor:=TFromColors.Create;
 ListBoxChatContact.Items.Clear;
 ChatList:=TChat.Create;
 
 FThreadFindContact:=TThreadFindContact.Create(True);
 FThreadFindContact.DoFind:=FThreadFindWorkContact;

 clDefMenuButtons:=ColorLighter(GetAeroColor);
 clDefMenu:=ColorDarker(GetAeroColor);
 ButtonsColor:=clDefMenuButtons;
 MenuColor:=clDefMenu;

 FTrayIconIndex:=26;
 FUseMainSub:=True;
 FJournalFiltred:=True;
 //ButtonHangup.Enabled:=False;
 FGlobalState:=gsIdle;
 NewVersionAvailable:=False;
 TrayIcon.Hint:=AppDesc+' '+GetAppVersionStr;
 WorkCall.inExtenChannel:='';
 WorkCall.EventCount:=1;
 Application.OnHint:=OnHint;
 ShareIco:=TIcon.Create;
 ImageList.GetIcon(14, ShareIco);
 Alarm:=True;
 ShowWarnMissed:=False;
 FCBMP:=TBitmap.Create;
 FCBMP.PixelFormat:=pf24bit;
 FCBMP.Width:=ClientWidth;
 FCBMP.Height:=ClientHeight;

 //Создадим списки номеров, журналов и избранного
 BranchNums:=TListOfBranch.Create;
 BuyingNums:=TListOfBranch.Create;
 BuyingSNums:=TListOfBranch.Create;
 ShopsNums:=TListOfBranch.Create;
 OfficeNums:=TListOfNumber.Create;
 FilteredOffice:=TListOfNumber.Create;
 GroupNums:=TListOfNumber.Create;
 FavoriteNums:=TListOfCommon.Create;
 DepartNums:=TListOfDepart.Create;
 DepartBuyNums:=TListOfDepart.Create;
 Journal:=TJournal.Create;
 JournalFilter:=TJournal.Create;
 GroupsNums:=TListOfNumber.Create;
 OtherNums:=TListOfOther.Create;

 CreateTablesColumns;
 UpdateGridFavorite;
end;

procedure TFormMain.CreateTablesColumns;
begin
 with TableExOffice do
  begin
   AddColumn('ФИО', ClientWidth div 2);
   AddColumn('Должность', 100);
  end;

 with TableExDepart do
  begin
   AddColumn('Отделение', Trunc(ClientWidth * (25/100)));
   AddColumn('ФИО', Trunc(ClientWidth * (55/100)));
   AddColumn('Номер', ClientWidth - (Columns[0].Width+Columns[1].Width));
  end;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
 SetPage(PageControlMain.ActivePage);
 Application.ProcessMessages;
 UpdateGridFavorite;
 UpdateUnitsGrids;
 SetForegroundWindow(Handle);
end;

procedure TFormMain.StringGridOffice1MouseWheelDown(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 (Sender as TDrawGrid).Perform(WM_VSCROLL, SB_LINEDOWN, 0);
 (Sender as TDrawGrid).Perform(WM_VSCROLL, SB_LINEDOWN, 0);
end;

procedure TFormMain.StringGridOffice1MouseWheelUp(Sender: TObject; Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
 Handled:=True;
 (Sender as TDrawGrid).Perform(WM_VSCROLL, SB_LINEUP, 0);
 (Sender as TDrawGrid).Perform(WM_VSCROLL, SB_LINEUP, 0);
end;

procedure TFormMain.OnPopupFav(Sender:TObject);
var InternalNum:string;
    i:Integer;
    Item:TMenuItem;
begin
 while PopupMenuFavorite.Items.Count > PopupMenuFavorite.Items.IndexOf(MenuItemFavLast)+1 do PopupMenuFavorite.Items.Delete(PopupMenuFavorite.Items.IndexOf(MenuItemFavLast)+1);
 try
  InternalNum:=FavoriteNums[PopupMenuFavorite.Tag].NumInteranl;
 except
  InternalNum:='';
 end;
 if Length(InternalNum) >= 2 then
  begin
   InternalNum:=Copy(InternalNum, 1, 2);
   if OfficeNums.Count > 0 then
    for i:= 0 to OfficeNums.Count - 1 do
     begin
      if Copy(OfficeNums[i].NumInteranl, 1, 2) = InternalNum Then
       begin
        Item:=TMenuItem.Create(PopupMenuFavorite);
        Item.Tag:=i;
        Item.Caption:=OfficeNums[i].FIO+' - '+OfficeNums[i].NumInteranl;
        Item.ImageIndex:=15;
        Item.OnClick:=MenuItemClickStringRow;
        PopupMenuFavorite.Items.Add(Item);
       end;
     end;
  end;
end;

procedure TFormMain.PageControlMainMouseActivate(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y, HitTest: Integer; var MouseActivate: TMouseActivate);
begin
 PanelMenuState(True);
end;

procedure TFormMain.PaintBoxMenuClick(Sender: TObject);
begin
 case FCurrentFrame of
  wfMain:
   begin
    PanelMenuClick.Hide;
   end;
  wfMenu:
   begin
    PanelMenuState(True);
   end;
  wfSettings:
   begin
    SpeedButtonSettingsCloseClick(nil);
   end;
  wfContact:
   begin
    ButtonCECloseClick(nil);
   end;
 end;
end;

procedure TFormMain.PaintBoxMenuPaint(Sender: TObject);
begin
 if Assigned(FCBMP) then PaintBoxMenu.Canvas.Draw(-PanelMenuClick.Left, 0, FCBMP, 70);
end;

procedure TFormMain.ShowNumbersForButton(InternalNum:string);
var Item:TMenuItem;
    i:integer;
begin
 PopupMenuGroup.Items.Clear;
 if Length(InternalNum) < 2 then Exit;
 InternalNum:=Copy(InternalNum, 1, 2);
 if OfficeNums.Count <= 0 then Exit;
 for i:= 0 to OfficeNums.Count - 1 do
  begin
   if Copy(OfficeNums[i].NumInteranl, 1, 2) = InternalNum Then
    begin
     Item:=TMenuItem.Create(PopupMenuGroup);
     Item.Tag:=i;
     Item.ImageIndex:=15;
     Item.Caption:=OfficeNums[i].FIO;
     Item.OnClick:=MenuItemClickStringRow;
     PopupMenuGroup.Items.Add(Item);
    end;
  end;
 PopupMenuGroup.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TFormMain.SpeedButtonMenuClick(Sender: TObject);
begin
 PanelMenuState(PanelMenu.Width >= 250);
end;

procedure TFormMain.SpeedButtonNumCopyBufClick(Sender: TObject);
begin
 if Length(EditMainNumber.Text) <= 0 then Exit;
 Clipboard.AsText:=EditMainNumber.Text;
 ShowBalloonHintMsg(AppDesc, 'Номер скопирован в буфер обмена', bfInfo, nil);
end;

procedure TFormMain.SpeedButtonNumFindClick(Sender: TObject);
begin
 ButtonedEditSearchGlobal.Text:=GetNumberOnly(EditMainNumber.Text);
 if ButtonedEditSearchGlobal.Text = '' then Exit;
 SetPage(TabSheetCatalog);
 SetCatalog(TabSheetSearch);
end;

procedure TFormMain.SpeedButtonKeepClaimClick(Sender: TObject);
begin
 Alarm:=not Alarm;
end;

procedure TFormMain.SpeedButtonPageBranchsClick(Sender: TObject);
begin
 SetCatalog(TabSheetBranchs);
end;

procedure TFormMain.SpeedButtonPageBuyingsClick(Sender: TObject);
begin
 SetCatalog(TabSheetBuyings);
end;

procedure TFormMain.SpeedButtonPageChatClick(Sender: TObject);
begin
 SetCatalog(TabSheetChat);
end;

procedure TFormMain.SpeedButtonPageDepartsClick(Sender: TObject);
begin
 SetCatalog(TabSheetDeparts);
end;

procedure TFormMain.SpeedButtonPageOfficeClick(Sender: TObject);
begin
 SetCatalog(TabSheetOffice);
end;

procedure TFormMain.SpeedButtonPageOtherClick(Sender: TObject);
begin
 SetCatalog(TabSheetOther);
end;

procedure TFormMain.SpeedButtonPageSearchClick(Sender: TObject);
begin
 SetCatalog(TabSheetSearch);
end;

procedure TFormMain.SpeedButtonPageShopsClick(Sender: TObject);
begin
 SetCatalog(TabSheetShops);
end;

procedure TFormMain.SpeedButtonPhoneClick(Sender: TObject);
begin
 SetPage(TabSheetPhone);
 PanelMenuState(True);
end;

procedure TFormMain.SpeedButtonSendLogClick(Sender: TObject);
begin
 SendLog;
end;

procedure TFormMain.SpeedButtonSettingsCloseClick(Sender: TObject);
begin
 CloseSettings;
end;

procedure TFormMain.SpeedButtonSwitchSubClick(Sender: TObject);
begin
 FUseMainSub:=not FUseMainSub;
 SetSelectedNumber;
end;

procedure TFormMain.SpeedButtonWishClick(Sender: TObject);
begin
 NewWish;
end;

procedure TFormMain.SpeedButtonLearn2OkClick(Sender: TObject);
var Config:TIniFile;
begin
 try
  Config:=TIniFile.Create(ExtractFilePath(Application.ExeName) + ConfigFN);
  Config.WriteBool('USER', 'Learn2', False);
  Config.Free;
 finally

 end;
 PanelTutorialHelp.Hide;
end;

procedure TFormMain.SpeedButtonCatalogClick(Sender: TObject);
begin
 SetPage(TabSheetCatalog);
 PanelMenuState(True);
end;

procedure TFormMain.SpeedButtonCECloseClick(Sender: TObject);
begin
 CloseContactForm;
end;

procedure TFormMain.SpeedButtonCopyClick(Sender: TObject);
var Info:string;
begin
 Info:='';
 if EditCatalogFIO.Text            <> '' then Info:=Info+EditCatalogFIO.Text;
 if Trim(MemoCatalogPosition.Text) <> '' then Info:=Info+#13#10+Trim(MemoCatalogPosition.Text);
 if Trim(MemoCatalogAddress.Text)  <> '' then Info:=Info+#13#10+Trim(MemoCatalogAddress.Text);
 if EditCatalogEMail.Text          <> '' then Info:=Info+#13#10+EditCatalogEMail.Text;
 if EditCatalogNumLandline.Text    <> '' then Info:=Info+#13#10+EditCatalogNumLandline.Text;
 if EditCatalogNumIn.Text          <> '' then Info:=Info+#13#10+EditCatalogNumIn.Text;
 if EditCatalogNumCell.Text        <> '' then Info:=Info+#13#10+EditCatalogNumCell.Text;
 if MemoComment.Visible                  then Info:=Info+#13#10+MemoComment.Text;
 if DrawGridWorkTime.Visible             then Info:=Info+#13#10+GetWorkTimeText(FDrawWorkTimeList);

 if Info = '' then Exit;
 ShowBalloonHintMsg('Готово', 'Информация успешно скопирована в буфер обмена', bfInfo, nil);
 Clipboard.AsText:=Info;
end;

procedure TFormMain.SpeedButtonFavClearClick(Sender: TObject);
begin
 if MessageBox(Application.Handle, 'Вы действительно хотите очистить список избранного?', '', MB_ICONQUESTION or MB_YESNO) <> ID_YES then Exit;
 FavoriteNums.Clear;
 UpdateGridFavorite;
end;

procedure TFormMain.SpeedButtonInsertGroupsClick(Sender: TObject);
begin
 if MessageBox(Application.Handle, 'Вы действительно хотите добавить номера всех отделов в список избранного?', '', MB_ICONQUESTION or MB_YESNO) <> ID_YES then Exit;
 InsertGroupsToFavorite;
end;

procedure TFormMain.SpeedButtonJournalClick(Sender: TObject);
begin
 SetPage(TabSheetJournal);
 PanelMenuState(True);
end;

procedure TFormMain.SpeedButtonLearn1OkClick(Sender: TObject);
var Config:TIniFile;
begin
 try
  Config:=TIniFile.Create(ExtractFilePath(Application.ExeName) + ConfigFN);
  Config.WriteBool('USER', 'Learn1', False);
  Config.Free;
 finally

 end;
 PanelLearn1.Hide;
end;

procedure TFormMain.SpeedButtonLogClearClick(Sender: TObject);
begin
 MemoLog.Clear;
end;

procedure TFormMain.SpeedButtonLogClick(Sender: TObject);
begin
 SetPage(TabSheetLog);
 PanelMenuState(True);
end;

procedure TFormMain.MemoCatalogAddressChange(Sender: TObject);
begin
 if MemoCatalogAddress.Text <> '' then
  if MemoCatalogAddress.Lines.Count < 3 then MemoCatalogAddress.Lines.Insert(0, '');
end;

procedure TFormMain.MemoCatalogPositionChange(Sender: TObject);
begin
 if MemoCatalogPosition.Text <> '' then
  if MemoCatalogPosition.Lines.Count < 2 then MemoCatalogPosition.Lines.Insert(0, '');
end;

procedure TFormMain.MenuItemChatCopyClick(Sender: TObject);
begin
 if ListBoxChat.ItemIndex < 0 then Exit;
 Clipboard.AsText:=ChatList[ListBoxChat.ItemIndex].Text;
end;

procedure TFormMain.MenuItemClickStringRow(Sender: TObject);
var i:integer;
begin
 if OfficeNums.Count <= 0 then Exit;
 i:=(Sender as TMenuItem).Tag;
 if not((i >= 0) and (i < OfficeNums.Count)) then Exit;
 EditMainNumber.Text:=OfficeNums[i].NumInteranl;
 Dial(EditMainNumber.Text);
end;

procedure TFormMain.ActionQuitExecute(Sender: TObject);
begin
 Quit;
end;

procedure TFormMain.ActionReconExecute(Sender: TObject);
begin
 if ClientSocketAsterisk.Active then
  begin
   ClientSocketAsterisk.Socket.SendText(AnsiString('Action: Logoff' + #13#10#13#10));
   Application.ProcessMessages;
   if ClientSocketAsterisk.Active then ClientSocketAsterisk.Close;
  end
 else
  begin
   Log('Подключение к серверу...');
   ClientSocketAsterisk.Host:=cnHost;
   ClientSocketAsterisk.Port:=cnPort;
   try
    ClientSocketAsterisk.Open;
   except
    Log('Ошибка при установке соединения');
   end;
  end;
end;

function TFormMain.CreateDepartColor(Data:TDepartRec):TColor;

function Summ(s:string): integer;
var i:integer;
begin
 Result:=0;
 for i:=1 to Length(s) do Result:= Result + Round(Ord(s[i]) / i);
end;

begin
 Result:=Summ(Data.Name);
 Result:=Trunc(Sqr(Result) + Sqrt(Result));
end;

procedure TFormMain.ActionReloadExecute(Sender: TObject);
var i: integer;
    Branch:TBranchNumber;
    Number:TNumberRec;
    OtherNum:TOtherRec;
    Depart:TDepartRec;
    MaxNum, MaxNum2:Integer;
    ADOQuery:TADOQuery;
    str, sF, sI, sO:string;
    ADOConnection:TADOConnection;
    DepFind:Boolean;
  j: Integer;
begin
 CIDName:='';
 if not CreateConnection(ADOConnection) then Exit;
 ADOQuery:=TADOQuery.Create(nil);
 ADOQuery.Connection:=ADOConnection;

 //Получаем данные ломбардов
 ADOQuery.SQL.Text:= 'SELECT NamePL, plat, Telef, email, Adres_, FAX, nmgorod, KodOtd, TipNP, Nobj FROM spADR_Ex WHERE (TipAdr IN (''888''))  and PLAT Not Like ''%z%'' and PLAT Not Like ''%x%'' and (DClose IS NULL OR DClose > GETDATE()) ORDER BY Right(''     ''+plat,6)';
 try
  ADOQuery.Open;
  BranchNums.Clear;
  MaxNum:=0;
  while not ADOQuery.Eof do
   begin
    with Branch do
     begin
      Name:=Truncate(ADOQuery.Fields[0].AsString);
      BranchNum:=Truncate(ADOQuery.Fields[1].AsString);
      if GetNumberOnly(BranchNum) <> BranchNum then
       begin
        ADOQuery.Next;
        Continue;
       end;

      PLAT:=Truncate(ADOQuery.Fields[1].AsString);
      Number:=FieldToNumber(Truncate(ADOQuery.Fields[2].AsString));
      EMail:=Truncate(ADOQuery.Fields[3].AsString);
      Address:=Truncate(ADOQuery.Fields[4].AsString);
      if ADOQuery.Fields[6].AsString <> '' then
       Address:=ADOQuery.Fields[6].AsString + ', ' + Address;
      FAX:=FieldToNumber(Truncate(ADOQuery.Fields[5].AsString));
      KodOtd:=ADOQuery.Fields[7].AsInteger;
      NObjParent:='';
      NObj:=ADOQuery.Fields[9].AsString;
      try
       if BranchNum <> '' then
        if MaxNum < StrToInt(BranchNum) then MaxNum:=StrToInt(BranchNum);
      except

      end;
     end;
    BranchNums.Add(Branch);

    ADOQuery.Next;
   end;
  DrawGridBranchs.RowCount:=(MaxNum-1) div DrawGridBranchs.ColCount + 1;
  UpdateUnitsGrids;
 except
  Log('except Получаем данные ломбардов');
 end;

 //Получаем данные скупок
 ADOQuery.SQL.Text:=
 'SELECT NamePL, plat, Telef, email, Adres, FAX, Gorod, IsNULL(Reg, 0), TipNP, nmgorod, NObjUnited '+
 'FROM spADR_Ex WHERE (TipAdr IN (''885''))  and PLAT Not Like ''%z%'' and PLAT Not Like ''%x%'' and (DClose IS NULL OR DClose > GETDATE()) ORDER BY Right(''     ''+plat,6)';
 try
  ADOQuery.Open;
  BuyingNums.Clear;
  BuyingSNums.Clear;
  MaxNum:=0;
  MaxNum2:=0;
  while not ADOQuery.Eof do
   begin
    with Branch do
     begin
      Name:=ADOQuery.Fields[0].AsString;
      str:=Truncate(ADOQuery.Fields[1].AsString);
      BranchNum:=str;
      PLAT:=str;
      Delete(BranchNum, 1, 1);
      Number:=FieldToNumber(Truncate(ADOQuery.Fields[2].AsString));
      EMail:=Truncate(ADOQuery.Fields[3].AsString);
      Address:=Truncate(ADOQuery.Fields[4].AsString);
      if ADOQuery.Fields[6].AsString <> '' then
       if Pos(ADOQuery.Fields[6].AsString, Address) = 0 then
        Address:=ADOQuery.Fields[8].AsString+' '+ADOQuery.Fields[6].AsString + ', ' + Address;
      if ADOQuery.Fields[9].AsString <> '' then Address:=ADOQuery.Fields[9].AsString+', '+Address;
      FAX:=FieldToNumber(Truncate(ADOQuery.Fields[5].AsString));
      KodOtd:=ADOQuery.Fields[7].AsInteger;
      NObjParent:=ADOQuery.Fields[10].AsString;
      NObj:='';
      try
       case AnsiLowerCase(str)[1] of
        's':
         begin
          if BranchNum <> '' then
           if MaxNum2 < StrToInt(BranchNum) then MaxNum2:=StrToInt(BranchNum);
          BuyingSNums.Add(Branch);
         end
       else
        begin
         if BranchNum <> '' then
          if  MaxNum < StrToInt(BranchNum) then MaxNum:=StrToInt(BranchNum);
         BuyingNums.Add(Branch);
        end;
       end;
      except

      end;
     end;

    ADOQuery.Next;
   end;
  DrawGridBuyings.RowCount:=(MaxNum-1) div DrawGridBuyings.ColCount + 1;
  DrawGridBuyingsS.RowCount:=(MaxNum2-1) div DrawGridBuyingsS.ColCount + 1;
  UpdateUnitsGrids;
 except
  Log('except Получаем данные скупок');
 end;

 //Получаем данные магазинов
 ADOQuery.SQL.Text:=
  'SELECT NamePL, plat, Telef, email, Adres, FAX, Gorod, KodOtd, TipNP, nmgorod, NObjUnited '+
  'FROM spADR_Ex WHERE  (TipAdr IN (''884'')) and PLAT Not Like ''%z%'' and PLAT Not Like ''%x%'' and (DClose IS NULL OR DClose > GETDATE()) AND PRES <> '''' ORDER BY Right(''     ''+plat,6)';
 try
  ADOQuery.Open;
  ShopsNums.Clear;
  MaxNum:=0;
  while not ADOQuery.Eof do
   begin
    with Branch do
     begin
      Name:=Truncate(ADOQuery.Fields[0].AsString);
      BranchNum:=Truncate(ADOQuery.Fields[1].AsString);
      PLAT:=Truncate(ADOQuery.Fields[1].AsString);
      Number:=FieldToNumber(Truncate(ADOQuery.Fields[2].AsString));
      EMail:=Truncate(ADOQuery.Fields[3].AsString);
      Address:=Truncate(ADOQuery.Fields[4].AsString);
      if ADOQuery.Fields[6].AsString <> '' then
       if Pos(ADOQuery.Fields[6].AsString, Address) = 0 then
        Address:=ADOQuery.Fields[8].AsString+' '+ADOQuery.Fields[6].AsString + ', ' + Address;
      if ADOQuery.Fields[9].AsString <> '' then Address:=ADOQuery.Fields[9].AsString+', '+Address;
      FAX:=FieldToNumber(Truncate(ADOQuery.Fields[5].AsString));
      NObjParent:=ADOQuery.Fields[10].AsString;
      NObj:='';
      try
       if BranchNum <> '' then
        begin
         BranchNum:=IntToStr(StrToInt(BranchNum)-200);
         if MaxNum < StrToInt(BranchNum) then MaxNum:=StrToInt(BranchNum);
        end;
      except

      end;
     end;
    ShopsNums.Add(Branch);
    ADOQuery.Next;
   end;
  ListBoxShops.Items.BeginUpdate;
  ListBoxShops.Items.Clear;
  if ShopsNums.Count > 0 then
   for i:= 0 to ShopsNums.Count - 1 do
    begin
     ListBoxShops.Items.Add('');
    end;
  ListBoxShops.Items.EndUpdate;
  DrawGridShops.RowCount:=(MaxNum-1) div DrawGridShops.ColCount + 1;
  UpdateUnitsGrids;
 except
  Log('except Получаем данные магазинов');
 end;

 //Получаем данные отделов
 ADOQuery.SQL.Text:= 'SELECT OBLAST, NameS, TELEF FROM spADR_Ex WHERE (TipAdr = ''881'') AND NOT (OBLAST is NULL) ORDER BY NameS';
 try
  ADOQuery.Open;
  GroupsNums.Clear;
  with Number do
   begin
    FIO:='Все отделы';
    NumInteranl:='0000';
    GroupsNums.Add(Number);
   end;

  while not ADOQuery.Eof do
   with Number do
    begin
     FIO:=Truncate(ADOQuery.Fields[1].AsString);
     NumInteranl:=FieldToNumber(Truncate(ADOQuery.Fields[0].AsString));
     NumLandline:=FieldToNumber(Truncate(ADOQuery.Fields[2].AsString));
     GroupsNums.Add(Number);
     ADOQuery.Next;
    end;

  with Number do
   begin
    FIO:='Фин. мониторинг';
    NumInteranl:='2200';
    GroupsNums.Add(Number);
   end;
  with Number do
   begin
    FIO:='Сопр. бизнеса';
    NumInteranl:='2300';
    GroupsNums.Add(Number);
   end;
  with Number do
   begin
    FIO:='Док. обеспечение';
    NumInteranl:='2400';
    GroupsNums.Add(Number);
   end;
  ListBoxGroups.Items.BeginUpdate;
  ListBoxGroups.Items.Clear;
  if GroupsNums.Count > 0 then
   begin  
    for i:= 0 to GroupsNums.Count - 1 do
     begin
      ListBoxGroups.Items.Add('');
     end;
    CIDGroup:=GetCIDGroup; 
   end;     
  ListBoxGroups.Items.EndUpdate;
 except
  Log('except Получаем данные отделов');
 end;

 //Получаем данные офисных работников и заполняем поле "Мой отдел"
 ADOQuery.SQL.Text:= 'SELECT NamePL, Dolj, Oblast, Telef, email, ADRes_, FAX FROM spADR_Ex WHERE (TipAdr IN (''66'')) and (pdreg>=0) order by 1';
 try
  ADOQuery.Open;
  OfficeNums.Clear;
  GroupNums.Clear;
  while not ADOQuery.Eof Do
   begin
    Number.FIO:=Truncate(ADOQuery.Fields[0].AsString);
    Number.Position:=Truncate(ADOQuery.Fields[1].AsString);
    if Number.Position <> '' then Number.Position[1]:=AnsiUpperCase(Number.Position[1])[1];
    Number.NumInteranl:=FieldToNumber(Truncate(ADOQuery.Fields[2].AsString));
    Number.NumLandline:=FieldToNumber(Truncate(ADOQuery.Fields[3].AsString));
    Number.EMail:=Truncate(ADOQuery.Fields[4].AsString);
    Number.Address:=Truncate(ADOQuery.Fields[5].AsString);
    Number.NumCell:=FieldToNumber(Truncate(ADOQuery.Fields[6].AsString));
    OfficeNums.Add(Number);
    //Если нашли себя в списке, то запоминаем имя
    if (Number.NumInteranl = CID) then CIDName:=Number.FIO;
    //Если длина внутреннего номера от двух символов (цифр) то мы добавляем в быстрый набор номера совпадающего отдела
    if (Length(Number.NumInteranl) >= 2) and (Length(CID) >= 2) then
     if (Copy(Number.NumInteranl, 1, 2) = Copy(CID, 1, 2)) and (Number.NumInteranl <> CID) Then
      begin
       if GetFIO(Number.FIO, sF, sI, sO) then
            str:=CreateFIO(sF, sI, sO)
       else str:=Number.FIO;
       Number.FIO:=str;
       GroupNums.Add(Number);
      end;
    ADOQuery.Next;
   end;
  FilterOffice('00');
  UpdateTableOffice;
  UpdateGridGroup;
  if ListBoxGroups.Count > 0 then ListBoxGroups.ItemIndex:=0;
  ListBoxGroupsClick(nil);
 except
  Log('except Получаем данные офисных работников и заполняем поле "Мой отдел"');
 end;

 //Отделения
 ADOQuery.SQL.Text:= 'SELECT NmOtd, FIOBoss, dolgnost, telef, fax, email, skype, KodOtd, adres_ FROM spAdrOtdWithAddres where not nmotd like ''скупки%''and not nmotd like ''% СК%'' ORDER BY NmOtd';
 try
  ADOQuery.Open;
  DepartNums.Clear;
  DepartBuyNums.Clear;
  while not ADOQuery.Eof do
   begin
    Depart.FIO:=Truncate(ADOQuery.Fields[1].AsString);
    Depart.Position:=Truncate(ADOQuery.Fields[2].AsString);
    if Depart.Position <> '' then Depart.Position[1]:=AnsiUpperCase(Depart.Position[1])[1];
    Depart.NumInteranl:='';
    Depart.NumLandline:=FieldToNumber(Truncate(ADOQuery.Fields[3].AsString));
    Depart.EMail:=Truncate(ADOQuery.Fields[5].AsString);
    Depart.Address:=Truncate(ADOQuery.Fields[8].AsString);
    Depart.Name:=Truncate(StringReplace(ADOQuery.Fields[0].AsString, 'отделение', '', [rfReplaceAll, rfIgnoreCase]));
    Depart.NumCell:=FieldToNumber(Truncate(ADOQuery.Fields[4].AsString));
    Depart.KodOtd:=ADOQuery.Fields[7].AsInteger;
    Depart.Color:=CreateDepartColor(Depart);
    DepartNums.Add(Depart);
    DepartBuyNums.Add(Depart);  
    ADOQuery.Next;
   end;
  UpdateTableDeparts;
  ListBoxDeparts.Items.BeginUpdate;
  ListBoxDeparts.Items.Clear;
  if DepartNums.Count > 0 then
   for i:= 0 to DepartNums.Count - 1 do
    begin
     ListBoxDeparts.Items.Add('');
    end;
  ListBoxDeparts.Items.EndUpdate;
 except
  Log('except Получаем данные отделений');
 end;

 //Фильтруем список отделений для скупок
 i:=0;
 if BuyingNums.Count + BuyingSNums.Count > 0 then
  if DepartBuyNums.Count > 0 then
   while i < DepartBuyNums.Count do
    begin
     DepFind:=False;
     for MaxNum:= 0 to Max(BuyingNums.Count-1, BuyingSNums.Count-1) do
      begin
       if MaxNum <= BuyingNums.Count - 1 then if DepartBuyNums[i].KodOtd = BuyingNums[MaxNum].KodOtd then
        begin
         DepFind:=True;
         Break;
        end;
       if MaxNum <= BuyingSNums.Count - 1 then if DepartBuyNums[i].KodOtd = BuyingSNums[MaxNum].KodOtd then
        begin
         DepFind:=True;
         Break;
        end;
      end;
     if not DepFind then DepartBuyNums.Delete(i)
     else Inc(i);
    end;
 ListBoxBuyingDepart.Items.BeginUpdate;
 ListBoxBuyingDepart.Items.Clear;
 if DepartBuyNums.Count > 0 then for i:= 0 to DepartBuyNums.Count - 1 do ListBoxBuyingDepart.Items.Add('');
 ListBoxBuyingDepart.Items.EndUpdate;
 //Прочее
 ADOQuery.SQL.Text:= 'SELECT [nRecCallDop], [NamePl], [Dolj], [Adr], [mail], [Tel1], [Tel2], [IPtel], [Comment], [xSha], [UserId] FROM [elix].[dbo].[sCallDop]  WHERE (xSha <> 0) or (UserId = '+QuotedStr(CID)+')';
 try
  ADOQuery.Open;
  OtherNums.Clear;

  while not ADOQuery.Eof do
   begin
    if (Length(CID) > 1) and (Length(ADOQuery.Fields[10].AsString) > 1) then
     begin
      if Copy(CID, 1, 2) <> Copy(ADOQuery.Fields[10].AsString, 1, 2) then
       begin
        ADOQuery.Next;
        Continue;
       end;
     end;

    OtherNum.nRecCallDop:=ADOQuery.Fields[0].AsInteger;
    OtherNum.FIO:=Truncate(ADOQuery.Fields[1].AsString);
    OtherNum.Position:=Truncate(ADOQuery.Fields[2].AsString);
    if OtherNum.Position <> '' then OtherNum.Position[1]:=AnsiUpperCase(OtherNum.Position[1])[1];
    OtherNum.Address:=Truncate(ADOQuery.Fields[3].AsString);
    OtherNum.EMail:=Truncate(ADOQuery.Fields[4].AsString);
    OtherNum.NumLandline:=FieldToNumber(Truncate(ADOQuery.Fields[5].AsString));
    OtherNum.NumCell:=FieldToNumber(Truncate(ADOQuery.Fields[6].AsString));
    OtherNum.NumInteranl:=FieldToNumber(Truncate(ADOQuery.Fields[7].AsString));
    OtherNum.Commnet:=Truncate(ADOQuery.Fields[8].AsString);
    OtherNum.KodOtd:=-1;
    OtherNum.xSha:=ADOQuery.Fields[9].AsInteger <> 0;
    OtherNum.UserID:=ADOQuery.Fields[10].AsString;
    OtherNums.Add(OtherNum);
    ADOQuery.Next;
   end;
  ListBoxOther.Items.BeginUpdate;
  ListBoxOther.Items.Clear;
  if OtherNums.Count > 0 then
   for i:= 0 to OtherNums.Count - 1 do
    begin
     ListBoxOther.Items.Add('');
    end;
  ListBoxOther.Items.EndUpdate;
  OtherSort;
 except
  Log('except Получаем данные "прочее"');
 end;

 for i:= 0 to BranchNums.Count-1 do
  begin
   for j:= 0 to ShopsNums.Count-1 do
    begin
     if ShopsNums[j].NObjParent = BranchNums[i].NObj then
      begin
       Branch:=BranchNums[i];
       Branch.NObjParent:='S1'+ShopsNums[j].BranchNum;
       Branch.Name:=Branch.Name+' + '+ShopsNums[j].Name;
       BranchNums[i]:=Branch;

       Branch:=ShopsNums[j];
       Branch.Address:='В ломбарде №'+BranchNums[i].BranchNum+', '#13#10+Branch.Address;
       ShopsNums[j]:=Branch;
       Break;
      end;
    end;
   if BranchNums[i].NObjParent <> '' then Continue;

   for j:= 0 to BuyingNums.Count-1 do
    begin
     if BuyingNums[j].NObjParent = BranchNums[i].NObj then
      begin
       Branch:=BranchNums[i];
       Branch.NObjParent:='B1'+BuyingNums[j].BranchNum;
       Branch.Name:=Branch.Name+' + '+BuyingNums[j].Name+' Гранула';
       BranchNums[i]:=Branch;

       Branch:=BuyingNums[j];
       Branch.Address:='В ломбарде №'+BranchNums[i].BranchNum+', '#13#10+Branch.Address;
       BuyingNums[j]:=Branch;
       Break;
      end;
    end;
   if BranchNums[i].NObjParent <> '' then Continue;

   for j:= 0 to BuyingSNums.Count-1 do
    begin
     if BuyingSNums[j].NObjParent = BranchNums[i].NObj then
      begin
       Branch:=BranchNums[i];
       Branch.NObjParent:='B2'+BuyingSNums[j].BranchNum;
       Branch.Name:=Branch.Name+' + '+BuyingSNums[j].Name+' ДР';
       BranchNums[i]:=Branch;

       Branch:=BuyingSNums[j];
       Branch.Address:='В ломбарде №'+BranchNums[i].BranchNum+', '#13#10+Branch.Address;
       BuyingSNums[j]:=Branch;
       Break;
      end;
    end;
  end;

 ADOQuery.Close;
 ADOQuery.Free;
 ADOConnection.Connected:=False;
 ADOConnection.Free;
 UpdateAppCaption;

 CordDrawGroup:=GridCord(-1, -1);
 CordDrawShops:=GridCord(-1, -1);
 CordDrawBuying:=GridCord(-1, -1);
 CordDrawBranchs:=GridCord(-1, -1);
 CordDrawBuyingS:=GridCord(-1, -1);
 CordDrawFavorite:=GridCord(-1, -1);
 CordDrawNumpad:=GridCord(-1, -1);
 GridUnselect(DrawGridGroup);
 GridUnselect(DrawGridShops);
 GridUnselect(DrawGridBuyings);
 GridUnselect(DrawGridBranchs);
 GridUnselect(DrawGridBuyingsS);
 GridUnselect(DrawGridFavorite);
 GridUnselect(DrawGridNumPad);
end;

procedure TFormMain.ActionSearchExecute(Sender: TObject);
begin
 ActionShowWindowExecute(nil);
 SetPage(TabSheetCatalog);
 SetCatalog(TabSheetSearch);
 ButtonedEditSearchGlobal.SetFocus;
 PanelMenuState(True);
end;

procedure TFormMain.ActionSettingsExecute(Sender: TObject);
begin
 if GetForegroundWindow <> Handle then ActionShowWindowExecute(nil);
 Settings;
end;

procedure TFormMain.ActionShowWindowExecute(Sender: TObject);
begin
 Show;
 WindowState:=wsNormal;
 SetForegroundWindow(Handle);
end;

procedure TFormMain.OtherSort;
var i, j:Integer;
    Item:TOtherRec;
begin
 if OtherNums.Count <= 0 then Exit;     //0-4
 for i:=1 to (OtherNums.Count-1) do   //0-3
  for j:=0 to (OtherNums.Count-1)-i do  //0-
   begin
    if OtherNums[j].xSha and (not OtherNums[j+1].xSha) then
     begin
      Item:=OtherNums[j];
      OtherNums[j]:=OtherNums[j+1];
      OtherNums[j+1]:=Item;
      Continue;
     end;
    if SortOtherItem(j, j+1) then
     begin
      Item:=OtherNums[j];
      OtherNums[j]:=OtherNums[j+1];
      OtherNums[j+1]:=Item;
     end;
   end;
 ListBoxOther.Repaint;
end;

procedure TFormMain.ActionSortOtherASCExecute(Sender: TObject);
begin
 FSortOtherASC:=True;
 ActionSortOtherASC.Checked:=True;
 OtherSort;
end;

procedure TFormMain.ActionSortOtherCommentExecute(Sender: TObject);
begin
 FSortOtherBy:=1;
 ActionSortOtherComment.Checked:=True;
 OtherSort;
end;

procedure TFormMain.ActionSortOtherDESCExecute(Sender: TObject);
begin
 FSortOtherASC:=False;
 ActionSortOtherDESC.Checked:=True;
 OtherSort;
end;

procedure TFormMain.ActionSortOtherNameExecute(Sender: TObject);
begin
 FSortOtherBy:=0;
 ActionSortOtherName.Checked:=True;
 OtherSort;
end;

procedure TFormMain.ButtonDialLandlineClick(Sender: TObject);
begin
 InsertNumber(EditCatalogNumLandline.Text);
end;

procedure TFormMain.ButtonDialInternalClick(Sender: TObject);
begin
 InsertNumber(EditCatalogNumIn.Text);
end;

procedure TFormMain.ButtonDialCellClick(Sender: TObject);
begin
 InsertNumber(EditCatalogNumCell.Text);
end;

procedure TFormMain.StringGridGlobalSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var Sel:TCommonRec;
begin
 Sel.FIO:=StringGridGlobal.Cells[0, ARow];
 Sel.NumInteranl:=StringGridGlobal.Cells[3, ARow];
 Sel.NumLandline:=StringGridGlobal.Cells[4, ARow];
 Sel.NumCell:=StringGridGlobal.Cells[5, ARow];
 Sel.EMail:=StringGridGlobal.Cells[6, ARow];
 Sel.Address:=StringGridGlobal.Cells[7, ARow];
 Sel.Commnet:=StringGridGlobal.Cells[8, ARow];
 Sel.Position:=StringGridGlobal.Cells[9, ARow];
 Sel.RecType:=rtOther;
 if FUseMainSub then SelectedNumber:=Sel else SelectedNumberExt:=Sel;
 SetSelectedNumber;
end;

procedure TFormMain.TableExJournalDblClick(Sender: TObject);
begin
 if not IndexInList(TableExJournal.ItemIndex, TList(Journal)) then Exit;
 EditMainNumber.Text:=Journal.Items[TableExJournal.ItemIndex].inNumber;
end;

procedure TFormMain.TableExJournalDrawCellData(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var str:string;
    Item:TJournalRec;
begin
 with TableExJournal.Canvas do
  begin
   if not IndexInList(ARow, TList(Journal)) then
    begin
     Font.Style:=[fsBold];
     TextOut(Rect.Left+10, Rect.Top + (Rect.Height div 3), 'Пусто');
     Exit;
    end;
   Brush.Style:=bsClear;
   Item:=Journal[ARow];
   //Иконка
   case Item.ItemType of
    jtDialing:  ImageListNumbers.Draw(TableExJournal.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 13);
    jtIncoming: ImageListNumbers.Draw(TableExJournal.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 14);
    jtMissed:   ImageListNumbers.Draw(TableExJournal.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 15);
    jtRedirect: ImageListNumbers.Draw(TableExJournal.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 16);
   end;

   //Тип записи
   if (Item.ItemType in [jtMissed]) and (Item.EventCount > 1)
   then str:=' ('+IntToStr(Item.EventCount)+')'
   else str:='';
   TextOut(Rect.Left+36, Rect.Top, JRItemTypeToStr(Item.ItemType) + str);

   //Дата записи
   if DateToStr(Now  ) = DateToStr(Item.inStart) then str:='в '+FormatDateTime('HH:MM', Item.inStart) else
   if DateToStr(Now-1) = DateToStr(Item.inStart) then str:='Вчера в '+FormatDateTime('HH:MM', Item.inStart) else
   if DateToStr(Now-2) = DateToStr(Item.inStart) then str:='Позавчера в '+FormatDateTime('HH:MM', Item.inStart)
   else str:=FormatDateTime('DD.MM.YYYY в HH:MM', Item.inStart);
   TextOut(Rect.Right - (TextWidth(str) + 3), Rect.Top, str);

   //Субъект
   Font.Style:=[fsBold];
   TextOut(Rect.Left+36, Rect.Top + Rect.Height div 3, Item.inSubject);
   Font.Style:=[];

   //Номер
   TextOut(Rect.Left+36, Rect.Top + Round(Rect.Height div 3 * 2), Item.inNumber);

   //Время звонка
   if Item.ItemType in [jtIncoming, jtDialing] then
    begin
     str:=TimeStampToStr(Item.TimeDur);
     TextOut(Rect.Right - (TextWidth(str) + 3), Rect.Top + Round(Rect.Height div 3 * 2), str);
    end
   else

   //Окончание звонка, если пропущенный
   if (Item.ItemType in [jtMissed]) and (Item.EventCount > 1) then
    begin
     str:=' пытался дозвониться '+TimeStampToStr(Item.TimeDur);
     TextOut(Rect.Right - (TextWidth(str) + 3), Rect.Top + Round(Rect.Height div 3 * 2), str);
    end;
  end;
end;

procedure TFormMain.TableExJournalListDblClick(Sender: TObject);
begin
 if not IndexInList(TableExJournalList.ItemIndex, TList(JournalFilter)) then Exit;
 EditMainNumber.Text:=JournalFilter.Items[TableExJournalList.ItemIndex].inNumber;
 if PageControlMain.ActivePage <> TabSheetPhone then SetPage(TabSheetPhone);
end;

procedure TFormMain.TableExJournalListDrawCellData(Sender: TObject; ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var str:string;
    Item:TJournalRec;
begin
 with TableExJournalList.Canvas do
  begin
   if not IndexInList(ARow, TList(JournalFilter)) then
    begin
     Font.Style:=[fsBold];
     TextOut(Rect.Left+10, Rect.Top + (Rect.Height div 3), 'Пусто');
     Exit;
    end;
   Brush.Style:=bsClear;
   Item:=JournalFilter[ARow];
   //Иконка
   case Item.ItemType of
    jtDialing:  ImageListNumbers.Draw(TableExJournalList.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 13);
    jtIncoming: ImageListNumbers.Draw(TableExJournalList.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 14);
    jtMissed:   ImageListNumbers.Draw(TableExJournalList.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 15);
    jtRedirect: ImageListNumbers.Draw(TableExJournalList.Canvas, Rect.Left + 1, Rect.Top + (Rect.Height div 2 - Icon.Height div 2), 16);
   end;
 
   //Тип записи
   if (Item.ItemType in [jtMissed]) and (Item.EventCount > 1)
   then str:=' ('+IntToStr(Item.EventCount)+')'
   else str:='';
   TextOut(Rect.Left+36, Rect.Top, JRItemTypeToStr(Item.ItemType) + str);

   //Дата записи
   if DateToStr(Now  ) = DateToStr(Item.inStart) then str:='в '+FormatDateTime('HH:MM', Item.inStart) else
   if DateToStr(Now-1) = DateToStr(Item.inStart) then str:='Вчера в '+FormatDateTime('HH:MM', Item.inStart) else
   if DateToStr(Now-2) = DateToStr(Item.inStart) then str:='Позавчера в '+FormatDateTime('HH:MM', Item.inStart)
   else str:=FormatDateTime('DD.MM.YYYY в HH:MM', Item.inStart);
   TextOut(Rect.Right - (TextWidth(str) + 3), Rect.Top, str);

   //Субъект
   Font.Style:=[fsBold];
   TextOut(Rect.Left+36, Rect.Top + Rect.Height div 3, Item.inSubject);
   Font.Style:=[];

   //Номер
   TextOut(Rect.Left+36, Rect.Top + Round(Rect.Height div 3 * 2), Item.inNumber);

   //Время звонка
   if Item.ItemType in [jtIncoming, jtDialing] then
    begin
     str:=TimeStampToStr(Item.TimeDur);
     TextOut(Rect.Right - (TextWidth(str) + 3), Rect.Top + Round(Rect.Height div 3 * 2), str);
    end
   else

   //Окончание звонка, если пропущенный
   if (Item.ItemType in [jtMissed]) and (Item.EventCount > 1) then
    begin
     str:=' пытался дозвониться '+TimeStampToStr(Item.TimeDur);
     TextOut(Rect.Right - (TextWidth(str) + 3), Rect.Top + Round(Rect.Height div 3 * 2), str);
    end;
  end;
end;

procedure TFormMain.TableExJournalListMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Cr:TPoint;
begin
 if Button <> mbRight then Exit; 
 if not IndexInList(TableExJournalList.ItemIndex, TList(JournalFilter)) then Exit;  
 Cr:=Mouse.CursorPos;
 PopupMenuJournal.Popup(Cr.X, Cr.Y);
end;

procedure TFormMain.TableExJournalMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if IndexInList(TableExJournal.ItemIndex, TList(Journal)) then  
  if Button = mbRight then ShowNumbersForButton(Journal[TableExJournal.ItemIndex].inNumber);
end;

procedure TFormMain.TableExDepartGetData(FCol, FRow: Integer; var Value: string);
begin
 if not IndexInList(FRow, TList(DepartNums)) then Exit;
 case FCol of
  0: Value:=DepartNums[FRow].Name;
  1: Value:=DepartNums[FRow].FIO;
  2: Value:=DepartNums[FRow].NumLandline;
 end;
end;

procedure TFormMain.TableExDepartItemClick(Sender: TObject; MouseButton: TMouseButton; const Index: Integer);
begin
 if Index < 0 then Exit;
 if FUseMainSub
 then SelectedNumber:=DepartToCommon(DepartNums[Index])
 else SelectedNumberExt:=DepartToCommon(DepartNums[Index]);
 SetSelectedNumber;
end;

procedure TFormMain.TableExOfficeGetData(FCol, FRow: Integer; var Value: string);
begin
 if not IndexInList(FRow, TList(FilteredOffice)) then Exit;
 case FCol of
  0: Value:=FilteredOffice[FRow].FIO;
  1: Value:=FilteredOffice[FRow].Position;
 end;
end;

procedure TFormMain.TableExOfficeItemClick(Sender: TObject; MouseButton: TMouseButton; const Index: Integer);
begin
 if Index < 0 then Exit;
 if FUseMainSub
 then SelectedNumber:=NumberToCommon(FilteredOffice[Index])
 else SelectedNumberExt:=NumberToCommon(FilteredOffice[Index]);
 SetSelectedNumber;
end;

procedure TFormMain.TabSheetBranchsShow(Sender: TObject);
begin
 LeftSideSet(lsSubject);
end;

procedure TFormMain.TabSheetChatShow(Sender: TObject);
begin
 LeftSideSet(lsChatContact);
 AllowMessage:=False;
 ActiveControl:=EditChatSend;
 if ShowChatHelp and ChatOff then
  begin
   ShowChatHelp:=False;
   PanelChatHelp.Visible:=True;
   Exit;
  end;
end;

procedure TFormMain.TimerAutoConnectTimer(Sender: TObject);
begin
 if not Initialized then Exit;
 if Length(CID) < 4 then Exit;
 if not AutoConnecting then
  begin
   AutoConnecting:=True;
   Log('start TimerAutoConnectTimer');
   ClientSocketAsterisk.Socket.SendText('');
   if not ClientSocketAsterisk.Active then
    begin
     ActionReconExecute(nil);
     ActionReloadExecute(nil);
    end;
   if not ChatOff then
    if not UDPServerChat.Active then UDPServerChat.Active:=True;
   AutoConnecting:=False;
   Log('finish TimerAutoConnectTimer');
  end;
end;

procedure TFormMain.TimerDayChangeTimer(Sender: TObject);
begin
 RunDate:=Now;
end;

procedure TFormMain.TimerStampTimer(Sender: TObject);
begin
 if (not Initialized) or (Application.Terminated) then Exit;
 LabelConData.Caption:=IntToStr(DataIn div 1024)+'/'+IntToStr(DataOut div 1024)+' кб';
 case GlobalState of
  gsDial:
   begin
    LabelState.Caption:=TimeStampToStrMini(TimeBetwen(WorkCall.inStart, Now));
    LabelinSubject.Caption:=WorkCall.inSubject;
   end;
  gsDialing:
   begin
    LabelState.Caption:='Набор номера...';
    LabelinSubject.Caption:=WorkCall.inSubject;
   end;
  gsIncomingCall:
   begin
    if WorkCall.inSubject = CID then
     begin
      LabelState.Caption:='00:00:00';
      LabelinSubject.Caption:='Поднимите трубку';
     end
    else
     begin
      LabelState.Caption:='Входящий вызов';
      LabelinSubject.Caption:=WorkCall.inSubject;
     end;
   end;
 end;
 if PanelDownloading.Showing then
  begin
   if not StopUpdate then
    begin
     if UpdateState >= 0 then
      begin
       LabelUpState.Caption:='Загружено '+IntToStr(UpdateState)+'%';
       ProgressBarUpdate.Progress:=UpdateState;
       ProgressBarUpdate.Repaint;
      end
     else
      begin
       LabelUpState.Caption:='Нет соединения';
       ProgressBarUpdate.Progress:=1;
       ProgressBarUpdate.Repaint;
      end;
    end;
  end;

 FormDialing.LabelState.Caption:=LabelState.Caption;
 FormDialing.LabelinSubject.Caption:=LabelinSubject.Caption;
 if AllowMessage then ImageChat.Visible:=not ImageChat.Visible else ImageChat.Visible:=False;
end;

procedure TFormMain.TimerUpdatesTimer(Sender: TObject);
begin
 SaveDataAndSettings;
 if not Initialized then Exit;
 if not CheckingVersion then FormMain.CheckActualVersion(False);
end;

procedure TFormMain.TrayIconBalloonClick(Sender: TObject);
begin
 RunUpdate(True);
end;

procedure TFormMain.TrayIconDblClick(Sender: TObject);
begin
 if GetForegroundWindow = Handle then Close else ActionShowWindowExecute(nil);
end;

var i:Integer;

{ TAppVerison }

function TAppVerison.GetVersion:string;
begin
 Result:=IntToStr(Major)+'.'+IntToStr(Minor);
end;

initialization
//Минимальная инициализация

  UpdateFile:=ExtractFilePath(Application.ExeName) + UpdateExe;
  WM_MSGSHOW:= RegisterWindowMessage('AsterLine_LKDU_PHONE_SHOW');
  WM_MSGCLOSE:=RegisterWindowMessage('AsterLine_LKDU_PHONE_CLOSE');
  //Каталог лога
  if not DirectoryExists(ExtractFilePath(Application.ExeName)+'Logs') then CreateDir(ExtractFilePath(Application.ExeName)+'Logs');
  if DirectoryExists(ExtractFilePath(Application.ExeName)+'Logs') then
   begin
    i:=0;
    repeat
     Inc(i);
     LogName:='LOG_'+FormatDateTime('HHMMSS_DDMMYYYY_', Now)+IntToStr(i)+'.log';
    until not FileExists(ExtractFilePath(Application.ExeName)+'Logs\'+LogName);
   end;

end.

