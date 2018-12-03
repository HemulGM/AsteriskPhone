unit zvon_form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls;

type
  Tzvonok = class(TForm)
    Label1: TLabel;
    name_caption: TLabel;
    hangup: TSpeedButton;
    SpeedButton2: TSpeedButton;
    num_caption: TLabel;
    num_sip: TLabel;
    num_cid: TLabel;
    procedure hangupClick(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  zvonok: Tzvonok;

implementation

uses Main;

{$R *.dfm}

procedure Tzvonok.hangupClick(Sender: TObject);
begin
form1.soc1.Socket.SendText('Action: Hangup'+#13#10);
form1.soc1.Socket.SendText('Channel: '+num_sip.Caption+#13#10);
form1.soc1.Socket.SendText('Priority: 1'+#13#10);
form1.soc1.Socket.SendText('Async: yes'+#13#10+#13#10);
zvonok.Close;
end;

procedure Tzvonok.SpeedButton2Click(Sender: TObject);
begin
    {
form1.soc1.Socket.SendText('Action: Park'+#13#10);
form1.soc1.Socket.SendText('Channel: '+num_sip.Caption+#13#10);
form1.soc1.Socket.SendText('Channel2: '+num_cid.Caption+#13#10);
form1.soc1.Socket.SendText('Timeout: 30000'+#13#10);
form1.soc1.Socket.SendText('Priority: 1'+#13#10);
form1.soc1.Socket.SendText('Async: yes'+#13#10+#13#10);
   }
{
 form1.soc1.Socket.SendText('Action: Bridge'+#13#10);
form1.soc1.Socket.SendText('Channel1: '+num_sip.Caption+#13#10);
form1.soc1.Socket.SendText('Channel2: SIP/'+num+#13#10);
form1.soc1.Socket.SendText('Tone: yes'+#13#10);
form1.soc1.Socket.SendText('Priority: 1'+#13#10);
form1.soc1.Socket.SendText('Async: yes'+#13#10+#13#10);
 }


form1.soc1.Socket.SendText('Action: Redirect'+#13#10);
form1.soc1.Socket.SendText('Channel: '+num_sip.Caption+#13#10);
//form1.soc1.Socket.SendText('Callerid: '+cid+#13#10);
form1.soc1.Socket.SendText('Timeout: 15000'+#13#10);
form1.soc1.Socket.SendText('Context: '+Content+#13#10);
form1.soc1.Socket.SendText('Exten: '+num+#13#10);   //num
form1.soc1.Socket.SendText('Priority: 1'+#13#10);
form1.soc1.Socket.SendText('Async: yes'+#13#10+#13#10);
    


end;

end.
