Unit aster;

Interface

Uses
 IniFiles, Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
 Forms, Dialogs, StdCtrls, ScktComp, ComCtrls, Buttons, DB, ADODB, Grids, DBGrids,
 ImgList, ExtCtrls, Menus, ShellAPI, IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdTelnet;

Type
 TForm1 = Class(TForm)
  Button1: TButton;
  Memo1: TMemo;
  Button2: TButton;
  setting: TButton;
  PageControl1: TPageControl;
  TabSheet1: TTabSheet;
  TabSheet2: TTabSheet;
  num_telefon: TEdit;
  ADOConnection1: TADOConnection;
  ADOCommand1: TADOCommand;
  ADOTable1: TADOTable;
  DataSource1: TDataSource;
  ADOQuery1: TADOQuery;
  sg1: TStringGrid;
  fio: TEdit;
  Label2: TLabel;
  Label3: TLabel;
  num_gorod: TEdit;
  num_sot: TEdit;
  Label4: TLabel;
  Label5: TLabel;
  email: TEdit;
  TabSheet3: TTabSheet;
  GroupBox1: TGroupBox;
  sbtn_1: TSpeedButton;
  GroupBox2: TGroupBox;
  sbtn_2: TSpeedButton;
  sbtn_3: TSpeedButton;
  sbtn_4: TSpeedButton;
  sbtn_5: TSpeedButton;
  sbtn_6: TSpeedButton;
  sbtn_7: TSpeedButton;
  sbtn_8: TSpeedButton;
  sbtn_9: TSpeedButton;
  sbtn_10: TSpeedButton;
  sbtn_11: TSpeedButton;
  sbtn_12: TSpeedButton;
  TabSheet4: TTabSheet;
  sg2: TStringGrid;
  links: TShape;
  otdel: TPopupMenu;
  pop_menu: TMenuItem;
  exit_btn: TButton;
  MainMenu1: TMainMenu;
  N3: TMenuItem;
  N5: TMenuItem;
  TabSheet5: TTabSheet;
  sg3: TStringGrid;
  TabSheet6: TTabSheet;
  history_sg: TStringGrid;
  sbtn_13: TSpeedButton;
  sbtn_14: TSpeedButton;
  sbtn_15: TSpeedButton;
  sbtn_16: TSpeedButton;
  edit_pozvon: TEdit;
  btz_pozvon: TBitBtn;
  Label1: TLabel;
  Timer1: TTimer;
    soc1: TClientSocket;
    TimerLink: TTimer;
    btn_telefon2: TButton;
    btn_telefon1: TButton;
    btn_telefon3: TButton;
    doljn: TEdit;
    adress: TEdit;
  Procedure Button1Click(Sender: TObject);
  Procedure soc1Connect(Sender: TObject; Socket: TCustomWinSocket);
  Procedure soc1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
  Procedure Button2Click(Sender: TObject);
  Procedure settingClick(Sender: TObject);
  Procedure soc1Write(Sender: TObject; Socket: TCustomWinSocket);
  Procedure soc1Read(Sender: TObject; Socket: TCustomWinSocket);
  Procedure create_btn(Var names, pid: String; kol: integer);
  Procedure zvon(number: String);
  Procedure FormShow(Sender: TObject);
  Procedure FormCreate(Sender: TObject);
  Procedure sg1SelectCell(Sender: TObject; ACol, ARow: Integer; Var CanSelect: Boolean);
  Procedure sbtn_1Click(Sender: TObject);
  Procedure lombard_Click(sender: tobject);
  Procedure sbtn_1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  Procedure pop_menuClick(Sender: TObject);
  Procedure btn_telefon1Click(Sender: TObject);
  Procedure n11Click(Sender: TObject);
  Procedure exit_btnClick(Sender: TObject);
  Procedure btn_telefon2Click(Sender: TObject);
  Procedure btn_telefon3Click(Sender: TObject);
  Procedure sg3SelectCell(Sender: TObject; ACol, ARow: Integer; Var CanSelect: Boolean);
  Procedure btz_pozvonClick(Sender: TObject);
  Procedure Timer1Timer(Sender: TObject);
    procedure soc1Error(Sender: TObject; Socket: TCustomWinSocket;
      ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure TimerLinkTimer(Sender: TObject);
    procedure soc1Connecting(Sender: TObject; Socket: TCustomWinSocket);
 Private
 End;

Var
 Form1: TForm1;
 num, cid, Content, msg: String;
 perevod: String;
 ok: integer;

Implementation

Uses
 zvon_form, settings;

{$R *.dfm}

Procedure tform1.create_btn(Var names, pid: String; kol: integer);
Var s_btn: TSpeedButton;
Begin
 s_btn := TSpeedButton.Create(self);
 s_btn.Width := 50;
 s_btn.Height := 50;
 s_btn.Caption := names;
 s_btn.Name := pid;
 s_btn.Left := kol * 50 + 5;
 s_btn.Top := 100;
End;

Procedure tform1.zvon(number: String);
Var
 nomer_telefona, s, msg: String;
 i: integer;
Begin
    // sleep(100);
 soc1.Socket.SendText(AnsiString('Action: CoreShowChannels'+ #13#10+ #13#10));
  //   sleep(100);
 soc1.Socket.SendText(AnsiString('Priority: 1' + #13#10 + #13#10));
 //    sleep(100);
 soc1.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));



// sleep(100);

 nomer_telefona := '';
 s := number;
 For i := 1 To length(s) Do
  If s[i] In ['0'..'9'] Then
   nomer_telefona := nomer_telefona + s[i];

  //    while ok=0 do;

 If perevod <> '' Then
 Begin
  memo1.Lines.Add(perevod+'perevod ------------ '+nomer_telefona);
  soc1.Socket.SendText(AnsiString('Action: Redirect' + #13#10));
  soc1.Socket.SendText(AnsiString('Channel: ' + perevod + #13#10));
  soc1.Socket.SendText(AnsiString('Exten: ' + nomer_telefona + #13#10));
  soc1.Socket.SendText(AnsiString('Context: ' + Content + #13#10));
  soc1.Socket.SendText(AnsiString('Priority: 1' + #13#10));
  soc1.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));
  perevod := '';
 {
     Action: Redirect
Channel: Zap/73-1
ExtraChannel: SIP/199testphone-1f3c
Exten: 8600029
Context: default
Priority: 1
}
 End
 Else
 Begin
  memo1.Lines.Add('connect ------------ '+nomer_telefona);
  soc1.Socket.SendText(AnsiString('Action: Originate' + #13#10));
  soc1.Socket.SendText(AnsiString('Channel: SIP/' + cid + #13#10));
  soc1.Socket.SendText(AnsiString('Callerid: ' + cid + #13#10));
  soc1.Socket.SendText(AnsiString('Timeout: 15000' + #13#10));
  soc1.Socket.SendText(AnsiString('Context: ' + Content + #13#10));
  soc1.Socket.SendText(AnsiString('Exten: ' + nomer_telefona + #13#10));
  soc1.Socket.SendText(AnsiString('Priority: 1' + #13#10));
  soc1.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));
 End;
 perevod := '';
 ok := 0;
End;

Procedure TForm1.Button1Click(Sender: TObject);
Begin
 if soc1.Active then
  begin
   soc1.Socket.SendText(AnsiString('Action: Logoff' + #13#10 + #13#10));
  end
 else
  begin
   memo1.Lines.Add('connecting...');
   soc1.Host := '192.168.0.111';
   soc1.Port := 5038;
   soc1.Open;
   memo1.Lines.Add('connected');
  end;
End;

Procedure TForm1.soc1Connect(Sender: TObject; Socket: TCustomWinSocket);
Var
 msg, stroka: String;
 position, i, x_nom: Integer;
Begin
 memo1.Lines.Add('Авторизация...');
 soc1.Socket.SendText(AnsiString('Action: login' + #13#10));
 soc1.Socket.SendText(AnsiString('Username: astmanproxy' + #13#10));
 soc1.Socket.SendText(AnsiString('Secret: telefon8501525' + #13#10 + #13#10));

 //soc1.Socket.SendText('Action: Sippeers'+#13#10);
 //soc1.Socket.SendText('Priority: 1'+#13#10);
 //soc1.Socket.SendText('Async: yes'+#13#10+#13#10);
 //soc1.OnRead:=soc1Read;
 links.Brush.Color:= clLime;
End;

procedure TForm1.soc1Connecting(Sender: TObject; Socket: TCustomWinSocket);
begin
 Memo1.Lines.Add('Соединение...');
end;

Procedure TForm1.soc1Disconnect(Sender: TObject; Socket: TCustomWinSocket);
Begin
 memo1.Lines.Add('disconnected');
 links.Brush.Color:= clSilver;
End;

procedure TForm1.soc1Error(Sender: TObject; Socket: TCustomWinSocket;
  ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
 case ErrorEvent of
  eeGeneral: ShowMessage('eeGeneral');
  eeSend: ShowMessage('eeSend');
  eeReceive: ShowMessage('eeReceive');
  eeConnect: ShowMessage('eeConnect');
  eeDisconnect: ErrorCode:=0;
  eeAccept: ShowMessage('eeAccept');
  eeLookup: ShowMessage('eeLookup');
 end;
 ErrorCode:=0;
end;

Procedure TForm1.Button2Click(Sender: TObject);
Begin
 num := num_telefon.text;
//cid := '1207';
 Content := 'from-internal';

 soc1.Socket.SendText(AnsiString('Action: Originate' + #13#10));
 soc1.Socket.SendText(AnsiString('Channel: SIP/' + cid + #13#10));
 soc1.Socket.SendText(AnsiString('Callerid: ' + cid + #13#10));
 soc1.Socket.SendText(AnsiString('Timeout: 15000' + #13#10));
 soc1.Socket.SendText(AnsiString('Context: ' + Content + #13#10));
 soc1.Socket.SendText(AnsiString('Exten: ' + num + #13#10));
 soc1.Socket.SendText(AnsiString('Priority: 1' + #13#10));
 soc1.Socket.SendText(AnsiString('Async: yes' + #13#10 + #13#10));

//msg:=soc1.Socket.ReceiveText;
//memo1.Lines.Add(msg);
 //label1.Caption:=msg;

//memo1.Lines.Add('gudok');
 //soc1.Close
End;

Procedure TForm1.settingClick(Sender: TObject);
Begin
 form2.showmodal;
//memo1.Lines.Add(soc1.Socket.ReceiveText);
//soc1.Socket.SendText('Action: Sippeers'+#13#10);
//soc1.Socket.SendText('Priority: 1'+#13#10);
//soc1.Socket.SendText('Async: yes'+#13#10+#13#10);

 // msg:=soc1.Socket.ReceiveText;
// i:=0;
// splitter := TStringList.Create();

/// splitter.Text:=msg;
 // memo1.Lines.Add(msg);

   {
//soc1.Socket.SendText('Action: Sippeers'+#13#10);
soc1.Socket.SendText('Action: Sipshowpeer'+#13#10);
soc1.Socket.SendText('peer: 1207'+#13#10);
soc1.Socket.SendText('Priority: 1'+#13#10);
soc1.Socket.SendText('Async: yes'+#13#10+#13#10);
    }
//soc1.Socket.SendText('Operation: add'+#13#10);
//soc1.Socket.SendText('Filter: "Event: Newchannel"'+#13#10);
//soc1.Socket.SendText('Filter: "!Channel: DAHDI*"'+#13#10);
//soc1.Socket.SendText('Filter: "!Event: Varsset"'+#13#10);

//soc1.Socket.SendText('Channel: SIP/'+cid+'-*'+#13#10);
//soc1.Socket.SendText('Variable: Dialstatus'+#13#10);
//soc1.Socket.SendText('Search: '+cid+#13#10);
//soc1.Socket.SendText('Filter: Bridge'+#13#10);
//soc1.Socket.SendText('Action: Logoff'+#13#10+#13#10);
//sleep(1100);

//msg:=soc1.Socket.ReceiveText;
//memo1.Lines.Add(msg);
//label1.Caption:=msg;


End;

Procedure TForm1.soc1Write(Sender: TObject; Socket: TCustomWinSocket);
Var
 msg: String;
Begin
//msg:=soc1.Socket.ReceiveText;
//memo1.Lines.Add(msg);
// label1.Caption:=msg;
End;

Procedure TForm1.soc1Read(Sender: TObject; Socket: TCustomWinSocket);
Var
 msg, stroka, temp, temp2, kto, komy, kto_nomer, komy_nomer: String;
 position, i, i2, i3, x_nom, x: Integer;
 splitter: TStringList;
Begin

 msg := UTF8Decode(soc1.Socket.ReceiveText);
 Memo1.Lines.Add('msg: '#13#10+msg+#13#10+'done');
 // soc1.Socket.Lock;
//  memo1.Lines.Add(msg);

// if pos(cid, msg)>0
 If (Pos('Event: Bridge', msg) <> 0) Or
    (Pos('Message: Channels will follow', msg) <> 0) Or
    (Pos('Event: Hangup', msg) <> 0) Or
    (Pos('Event: Dial', msg) <> 0)
 then
 Begin
  splitter := TStringList.Create();
  //buf_msg.add(soc1.Socket.ReceiveText);
  // msg:=soc1.Socket.ReceiveText;
  splitter.Text := msg;
//memo1.Lines.Add(msg);
//memo1.Lines.Add('=====================');
// label1.Caption:=msg;
  i := 0;

 //             splitter.Text:=msg;
{ if (Pos('Event: Bridge',msg)<>0) or
 (Pos('Message: Channels will follow',msg)<>0) or
 (Pos('Event: Hangup',msg)<>0) or
 (Pos('Event: Dial',msg)<>0) then
 begin
       }
  i := splitter.indexof('Event: Bridge');
  If i > 1 Then
  Begin
   If splitter[i + 2] = 'Bridgestate: Link' Then
   Begin
               // fio.Color:=cllime;
    zvonok.num_cid.Caption := copy(splitter[i + 5], 10, length(splitter[i + 5]) - 9);
              //  memo1.Lines.Add('==**---  '+splitter[i+4]);     //kto nomer
              //  memo1.Lines.Add('==**---  '+splitter[i+5]);     // komy nomer
              //  memo1.Lines.Add('CallerID1:== '+splitter[i+8]);  //kto
              //  memo1.Lines.Add('CallerID2:== '+splitter[i+9]);  //komy
    temp := splitter[i + 8];
    kto := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
    temp := splitter[i + 9];
    komy := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
  //              memo1.Lines.Add(kto+'===*!!!!!!!!!!!!!!!!*---='+komy);
    temp := splitter[i + 4];
    kto_nomer := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
    temp := splitter[i + 5];
    komy_nomer := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
    If pos(cid, splitter[i + 4]) > 0 Then
    Begin

     For x := 1 To sg1.RowCount - 1 Do
      If sg1.Cells[2, x] = komy Then
      Begin
       sg1.Row := x;
       fio.Color:= cllime;
      End;
     perevod := komy_nomer;
                  //  history_sg.Cells[0,history_sg.RowCount-1]:='я позвонил';
                  //  history_sg.Cells[1,history_sg.RowCount-1]:=komy;
                  //  history_sg.RowCount:=history_sg.RowCount+1;

    End;
    If pos(cid, splitter[i + 5]) > 0 Then
    Begin
     For x := 1 To sg1.RowCount - 1 Do
      If sg1.Cells[2, x] = kto Then
       sg1.Row := x;

     SetForegroundWindow(Handle);
     ShowWindow(Handle, SW_NORMAL);
     perevod := kto_nomer;
                //    history_sg.Cells[0,history_sg.RowCount-1]:='мне звонил 2';
                //    history_sg.Cells[1,history_sg.RowCount-1]:=kto;
                //    history_sg.RowCount:=history_sg.RowCount+1;
                 // fio.Color:=clCream;
    End;
   End
   Else fio.Color:= clCream;
           //   memo1.Lines.Add(copy(msg,position,
           //    memo1.Lines.Add('==**__BR___***===');
   i := 0;
  End;

           // memo1.Lines.Add(msg);
  i := splitter.indexof('Message: Channels will follow');
  If i > 0 Then
  Begin
             //  showmessage('ok');
   i2 := splitter.indexof('Event: CoreShowChannelsComplete');
               //memo1.Lines.Add(msg);
              // memo1.Lines.Add('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
   temp2 := splitter[i2 + 2];
   perevod := '';
   For x := 0 To strtoint(copy(temp2, pos(' ', temp2) + 1, length(temp2) - pos(' ', temp2) + 1)) - 1 Do
   Begin
                 //  temp:=splitter[i+3+x*19];  //chanel
                 //  kto:=copy(temp,pos(' ',temp)+1,length(temp)-pos(' ',temp)+1);
               // //   temp:=splitter[i+16+x*19];  //duration  (skolko time)
                 //  temp:=splitter[i+18+x*19];  //bridgetchanel
    temp := splitter[i + 12 + x * 19];  //CallerIDnum   (kto)
    kto := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
                 //  temp:=splitter[i+14+x*19];  //ConnectedLineNum  (komy)
                 //  komy:=copy(temp,pos(' ',temp)+1,length(temp)-pos(' ',temp)+1);

    temp := splitter[i + 10 + x * 19];  //appdial or dial  (prinyal or pozvonil)
    temp := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
    If (temp = 'AppDial') And (kto = cid) Then
    Begin

     temp := splitter[i + 18 + x * 19];  //bridgetchanel
     perevod := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
     ok := 1;
    End;

                   //memo1.Lines.Add(inttostr(x)+') ==**---  '+temp);

   End;
             //  memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+7]));
             //  memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+8]));
   ok := 1;
   i := 0;
  End;

  i := splitter.indexof('Event: Newstate');
  If i > 1 Then
  Begin
             //  memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+6]));
             //  memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+7]));
             //  memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+8]));

   i := 0;
  End;

  i := splitter.indexof('Event: Hangup');
  If i > 1 Then
  Begin
             //  memo1.Lines.Add('Pologili trubku');
             //  memo1.Lines.Add('!!!!!!! kto zvonil '+utf8toansi(splitter[i+4]));
            //   memo1.Lines.Add('!!!!!!! komy pozvonili '+utf8toansi(splitter[i+6]));
   temp := splitter[i + 4];
   kto := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
   temp := splitter[i + 6];
   komy := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
   If pos(cid, splitter[i + 6]) > 0 Then
   Begin
    perevod := '';
    zvonok.Hide;
                   // history_sg.Cells[0,history_sg.RowCount-1]:='мне звонил';
                   // history_sg.Cells[1,history_sg.RowCount-1]:=kto;
                   // history_sg.RowCount:=history_sg.RowCount+1;
   End;
   If pos(cid, splitter[i + 4]) > 0 Then
   Begin
    perevod := '';
    zvonok.Hide;
              //      history_sg.Cells[0,history_sg.RowCount-1]:='я звонил';
              //      history_sg.Cells[1,history_sg.RowCount-1]:=komy;
              //      history_sg.RowCount:=history_sg.RowCount+1;
   End;

   i := 0;
  End;

  i := splitter.indexof('Event: Dial');
  If i > 1 Then
   If splitter[i + 2] = 'SubEvent: Begin' Then
                // memo1.Lines.Add(copy(splitter[i+7],19,length(splitter[i+7])-18));
//               if copy(splitter[i+7],19,length(splitter[i+7])-18)=cid then
    If pos(cid, splitter[i + 7]) > 0 Then
    Begin
     SetForegroundWindow(Handle);
     ShowWindow(Handle, SW_NORMAL);
     pagecontrol1.ActivePage := tabsheet3;
     zvonok.name_caption.Caption := copy(utf8toansi(splitter[i + 6]), 14, length(utf8toansi(splitter[i + 6])) - 13);
     zvonok.num_caption.Caption := copy(splitter[i + 5], 14, length(splitter[i + 6]) - 13);
     zvonok.num_sip.Caption := copy(splitter[i + 3], 10, length(splitter[i + 3]) - 9);
             //   zvonok.show;
     For x := 1 To sg1.RowCount - 1 Do
      If sg1.Cells[2, x] = zvonok.num_caption.Caption Then
       sg1.Row := x;

               //zvonok.show;
     history_sg.Cells[0, history_sg.RowCount - 1] := 'мне звонил ' + TimeToStr(time) + ' ' + DateToStr(date);
     history_sg.Cells[1, history_sg.RowCount - 1] := copy(splitter[i + 5], 14, length(splitter[i + 6]) - 13);
     history_sg.RowCount := history_sg.RowCount + 1;
    //           memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+3]));
    //           memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+4]));
    //           memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+5]));
    //           memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+6]));
    //           memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+7]));
    //           memo1.Lines.Add('==**---  '+utf8toansi(splitter[i+8]));
     i := 0;
    End
    Else If pos(cid, splitter[i + 3]) > 0 Then
    Begin
     temp := splitter[i + 7];
     temp := copy(temp, pos(' ', temp) + 1, length(temp) - pos(' ', temp) + 1);
     history_sg.Cells[0, history_sg.RowCount - 1] := 'я звонил ' + TimeToStr(time) + ' ' + DateToStr(date);
     history_sg.Cells[1, history_sg.RowCount - 1] := temp;
     history_sg.RowCount := history_sg.RowCount + 1;
     i := 0;
    End;

  splitter.Free;
//soc1.Socket.unLock;
 //memo1.Lines.Add(msg);
//buf_msg.Delete(0);

 End;
End;

Procedure TForm1.FormShow(Sender: TObject);
Var
 btn_text: Array[1..12] Of TEdit;
 btn_nomer: Array[1..12] Of TEdit;
 btn_speed: Array[1..12] Of TspeedButton;
 i: integer;
Begin
//cid:=form2.number_edit.Text;
 num := num_telefon.text; // '1204';
//cid := '1207';
 Content := 'from-internal';
 For i := 1 To 12 Do
 Begin
  btn_text[i] := Form2.FindComponent('btn_' + inttostr(i)) As TEdit;
  btn_nomer[i] := Form2.FindComponent('btn_tel_' + inttostr(i)) As TEdit;
  btn_speed[i] := Form1.FindComponent('sbtn_' + inttostr(i)) As TspeedButton;
  If btn_text[i].Text <> '' Then
  Begin
   btn_speed[i].Caption := btn_text[i].Text;
   btn_speed[i].Hint := btn_nomer[i].Text;
   btn_speed[i].visible := true;
  End
  Else
   btn_speed[i].visible := false;

 End;
 ///// Connect
 If Not soc1.Active Then
 Begin
  soc1.Host := '192.168.0.111';
  soc1.Port := 5038;
  soc1.Open;
 End;
 //// end connect
End;

Procedure TForm1.FormCreate(Sender: TObject);
Var
 b: TspeedButton;
 i, x: integer;
 n: String;
 fini: TIniFile;
Begin
 soc1.Socket.Lock;
 perevod := '';

 fini := TIniFile.Create(ExtractFilePath(Application.ExeName) + 'init.ini');
 cid := fini.ReadString('NUM', 'number', '');

 fini.Free;
 ADOConnection1.DefaultDatabase := 'ELIX';
 ADOConnection1.Connected := true;
 AdoQuery1.Close;
 AdoQuery1.SQL.Text := 'SELECT NamePL, plat, Telef, email, Adres, FAX, nmgorod  FROM  spADR0 WHERE  (TipAdr IN (''888''))  and PLAT Not Like ''%z%'' and PLAT Not Like ''%x%'' and (DClose IS NULL OR DClose > GETDATE()) ORDER BY Right(''     ''+plat,6)';
 AdoQuery1.Open;
 i := 0;

 While Not AdoQuery1.Eof Do
 Begin
  sg2.Cells[0, i] := AdoQuery1.Fields[0].AsString;
  sg2.Cells[1, i] := AdoQuery1.Fields[1].AsString;
  sg2.Cells[2, i] := AdoQuery1.Fields[2].AsString;
  sg2.Cells[3, i] := AdoQuery1.Fields[3].AsString;
  sg2.Cells[4, i] := AdoQuery1.Fields[6].AsString + ', ' + AdoQuery1.Fields[4].AsString;
  sg2.Cells[5, i] := AdoQuery1.Fields[5].AsString;
  n := sg2.Cells[1, i];
  b := TspeedButton.Create(TabSheet2);
  b.Parent := TabSheet2;
  b.Name := 'lk_btn_' + n;
  b.Width := 40;
  b.Height := 22;
  b.Left := 8 + (strtoint(n) Mod 10) * 40;
  b.Top := 8 + (strtoint(n) Div 10) * 22;
  b.caption := ''; //inttostr(i);
  b.flat := true;
  b.Caption := n;
  b.Font.Size := 10;
  b.OnClick := lombard_click;

  AdoQuery1.Next;
  i := i + 1;
  sg2.RowCount := i;
 End;
//  ADOConnection1.Connected:=false;

//  ADOConnection1.Connected:=true;
 AdoQuery1.Close;
 AdoQuery1.SQL.Text := 'SELECT NamePL, Dolj, Oblast, Telef, email, ADRes, FAX  FROM  spADR0 WHERE  (TipAdr IN (''66'')) and pdreg>=0 order by 1';
 AdoQuery1.Open;
 i := 0;
 sg1.ColWidths[0] := 190;
 sg1.ColWidths[1] := 200;
 sg1.ColWidths[2] := 0;
 sg1.ColWidths[3] := 0;
 sg1.ColWidths[4] := 0;
//sg1.ColWidths[5]:=0;

 x := 0;
 While Not AdoQuery1.Eof Do
 Begin
  sg1.Cells[0, i] := AdoQuery1.Fields[0].AsString;
  sg1.Cells[1, i] := AdoQuery1.Fields[1].AsString;
  sg1.Cells[2, i] := AdoQuery1.Fields[2].AsString;
  sg1.Cells[3, i] := AdoQuery1.Fields[3].AsString;
  sg1.Cells[4, i] := AdoQuery1.Fields[4].AsString;
  sg1.Cells[5, i] := AdoQuery1.Fields[5].AsString;
  sg1.Cells[6, i] := AdoQuery1.Fields[6].AsString;

  If (sg1.Cells[2, i] = cid) Then
   form1.Caption := form1.Caption + ' - ' + sg1.Cells[0, i];

  If (copy(sg1.Cells[2, i], 1, 2) = copy(cid, 1, 2)) And (sg1.Cells[2, i] <> cid) Then
  Begin
   b := TspeedButton.Create(groupbox2);
   b.Parent := groupbox2;
   b.Name := 'speed_btn_' + inttostr(x);
   b.Width := 96;
   b.Height := 30;
   b.Left := 10 + (x Mod 4) * 100;
   b.Top := 16 + (x Div 4) * 35;
// b.caption:=''; //inttostr(i);
// b.flat:=true;
   b.Caption := copy(sg1.Cells[0, i], 1, pos(' ', sg1.Cells[0, i]));
   b.Font.Size := 10;
   b.OnClick := sbtn_1Click;
   b.Hint := sg1.Cells[2, i];
   b.ShowHint := true;
   x := x + 1;
   groupbox2.Height := 20 + 35 * ((x Div 4) + 1);
  End;

  AdoQuery1.Next;
  i := i + 1;
  sg1.RowCount := i;
 End;
//////////////////

//  ADOConnection1.Connected:=true;
 AdoQuery1.Close;
 AdoQuery1.SQL.Text := 'SELECT NmOtd, FIOBoss, dolgnost, telef, fax, email, skype FROM  spAdrOtd where xvk<>0 ORDER BY NmOtd';

 AdoQuery1.Open;
 i := 0;
 sg3.ColWidths[0] := 190;
 sg3.ColWidths[1] := 200;
//sg3.ColWidths[2]:=0;
//sg3.ColWidths[3]:=0;
//sg3.ColWidths[4]:=0;
//sg1.ColWidths[5]:=0;

 x := 0;
 While Not AdoQuery1.Eof Do
 Begin
  sg3.Cells[0, i] := StringReplace(AdoQuery1.Fields[0].AsString, 'отделение', '', [rfReplaceAll, rfIgnoreCase]);
  sg3.Cells[1, i] := AdoQuery1.Fields[1].AsString;
  sg3.Cells[2, i] := AdoQuery1.Fields[2].AsString;
  sg3.Cells[3, i] := AdoQuery1.Fields[3].AsString;
  sg3.Cells[4, i] := AdoQuery1.Fields[4].AsString;
  sg3.Cells[5, i] := AdoQuery1.Fields[5].AsString;
  sg3.Cells[6, i] := AdoQuery1.Fields[6].AsString;

  AdoQuery1.Next;
  i := i + 1;
  sg3.RowCount := i;
 End;
//////////////////


 ADOConnection1.Connected := false;



 {
 for i:=1 to sg1.RowCount-1 do begin
   if copy(sg1.Cells[2,i],1,2)=copy(cid,1,2) then begin
  //   menu:= TMenuItem.Create(otdel);
  //   menu.Tag:=i;
  //   menu.Caption:=sg1.Cells[0,i];
 //    menu.OnClick:=pop_menuClick;
    //menu.Caption:=(sender as tspeedbutton).caption;
 //   otdel.Items.Add(menu);
    end;
end;   }

End;

Procedure TForm1.sg1SelectCell(Sender: TObject; ACol, ARow: Integer; Var CanSelect: Boolean);
Begin
 num_telefon.Text := sg1.Cells[2, Arow];
 fio.Text := sg1.Cells[0, Arow];
 doljn.Text := sg1.Cells[1, Arow];
 email.Text := sg1.Cells[4, Arow];
 adress.Text := sg1.Cells[5, Arow];
 num_gorod.Text := sg1.Cells[3, Arow];
 num_sot.Text := sg1.Cells[6, Arow];
End;

Procedure TForm1.sbtn_1Click(Sender: TObject);
Begin
 zvon(TSpeedButton(Sender).hint);
End;

Procedure TForm1.lombard_click(Sender: TObject);
Var
 Arow: integer;
Begin
 Arow := strtoint(TSpeedButton(Sender).caption) - 1;
 num_telefon.Text := ''; //sg2.Cells[2,Arow];
 fio.Text := sg2.Cells[0, Arow];
 doljn.Text := ''; //sg2.Cells[1,Arow];
 email.Text := sg2.Cells[3, Arow];
 adress.Text := sg2.Cells[4, Arow];
 num_gorod.Text := sg2.Cells[2, Arow];
 num_sot.Text := sg2.Cells[5, Arow];
End;

Procedure TForm1.sbtn_1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
Var
 p: tpoint;
 menu: TMenuItem;
 i: integer;
 s: String;
Begin

 If Button <> mbRight Then
  exit;
 p.x := x;
 p.y := y;
 p := (sender As tspeedbutton).ClientToScreen(p);

 otdel.Items.Clear;

 s := copy((sender As tspeedbutton).hint, 1, 2);

 For i := 1 To sg1.RowCount - 1 Do
 Begin
  If copy(sg1.Cells[2, i], 1, 2) = s Then
  Begin
   menu := TMenuItem.Create(otdel);
   menu.Tag := i;
   menu.Caption := sg1.Cells[0, i];
   menu.OnClick := pop_menuClick;
    //menu.Caption:=(sender as tspeedbutton).caption;
   otdel.Items.Add(menu);
  End;
 End;

 otdel.Popup(p.x, p.y);

End;

Procedure TForm1.pop_menuClick(Sender: TObject);
Var
 arow: integer;
Begin
 arow := (sender As TMenuItem).Tag;
 num_telefon.Text := sg1.Cells[2, Arow];
 fio.Text := sg1.Cells[0, Arow];
 doljn.Text := sg1.Cells[1, Arow];
 email.Text := sg1.Cells[4, Arow];
 adress.Text := sg1.Cells[5, Arow];
 num_gorod.Text := sg1.Cells[3, Arow];
 num_sot.Text := sg1.Cells[6, Arow];
End;

Procedure TForm1.btn_telefon1Click(Sender: TObject);
Begin

 zvon(num_gorod.Text);
End;

Procedure TForm1.n11Click(Sender: TObject);
Begin
 ShowWindow(Handle, SW_NORMAL);
 ShowWindow(Application.Handle, SW_SHOW);
End;

Procedure TForm1.exit_btnClick(Sender: TObject);
Begin
 Close;
End;

Procedure TForm1.btn_telefon2Click(Sender: TObject);
Begin
 zvon(num_telefon.Text);
End;

Procedure TForm1.btn_telefon3Click(Sender: TObject);
Begin
 zvon(num_sot.Text);
End;

Procedure TForm1.sg3SelectCell(Sender: TObject; ACol, ARow: Integer; Var CanSelect: Boolean);
Begin
 num_telefon.Text := sg3.Cells[4, Arow];
 fio.Text := sg3.Cells[1, Arow];
 doljn.Text := sg3.Cells[2, Arow];
 email.Text := sg3.Cells[5, Arow];
 adress.Text := sg3.Cells[0, Arow];
 num_gorod.Text := ''; //sg1.Cells[3,Arow];
 num_sot.Text := sg3.Cells[3, Arow];
End;

Procedure TForm1.btz_pozvonClick(Sender: TObject);
Begin
 perevod := '';
 zvon(edit_pozvon.Text);
End;

Procedure TForm1.Timer1Timer(Sender: TObject);
Begin
 label1.Caption := perevod;
End;

procedure TForm1.TimerLinkTimer(Sender: TObject);
begin
 //
end;

End.

