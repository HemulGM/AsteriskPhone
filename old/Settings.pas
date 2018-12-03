unit Settings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, sPanel, acSlider,
  Vcl.StdCtrls, sEdit, sSpinEdit, Vcl.ComCtrls,
  Vcl.Buttons, sSpeedButton, sColorSelect;

type
  TFormSettings = class(TForm)
    Bevel1: TBevel;
    ButtonClose: TButton;
    Button1: TButton;
    TrackBarScale: TTrackBar;
    Label1: TLabel;
    EditNumber: TLabeledEdit;
    EditSecret: TLabeledEdit;
    ButtonChangeNumber: TButton;
    Bevel2: TBevel;
    Label2: TLabel;
    Bevel3: TBevel;
    Label3: TLabel;
    Bevel4: TBevel;
    CheckBoxAutorun: TCheckBox;
    Label4: TLabel;
    Bevel5: TBevel;
    ButtonColorSet: TButton;
    ButtonColorReset: TButton;
    ColorSelectMenu: TsColorSelect;
    Label5: TLabel;
    ButtonColorAero: TButton;
    Label6: TLabel;
    Bevel6: TBevel;
    ColorSelectMenuForMenu: TsColorSelect;
    Label7: TLabel;
    Button2: TButton;
    Button3: TButton;
    ButtonColorAeroMenu: TButton;
    CheckBoxUseAero: TCheckBox;
    procedure ButtonChangeNumberClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBoxAutorunClick(Sender: TObject);
    procedure ButtonColorSetClick(Sender: TObject);
    procedure ButtonColorResetClick(Sender: TObject);
    procedure ButtonColorAeroClick(Sender: TObject);
    procedure ButtonColorAeroMenuClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBoxUseAeroClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormSettings: TFormSettings;

implementation
 uses Main, Main.CommonFunc;

{$R *.dfm}

procedure TFormSettings.Button1Click(Sender: TObject);
begin
 WindScale:=TrackBarScale.Position;
 MessageBox(Application.Handle, 'Для применения изменений, перезагрузите программу.', '', MB_ICONASTERISK or MB_OK);
end;

procedure TFormSettings.Button2Click(Sender: TObject);
begin
 FormMain.MenuColor:=ColorDarker(ColorSelectMenuForMenu.ColorValue);
end;

procedure TFormSettings.Button3Click(Sender: TObject);
begin
 FormMain.MenuColor:=clDefMenu;
 ColorSelectMenuForMenu.ColorValue:=FormMain.MenuColor;
end;

procedure TFormSettings.ButtonColorAeroMenuClick(Sender: TObject);
begin
 FormMain.MenuColor:=ColorDarker(GetAeroColor);
 ColorSelectMenuForMenu.ColorValue:=FormMain.MenuColor;
end;

procedure TFormSettings.ButtonChangeNumberClick(Sender: TObject);
begin
 if EditSecret.Text <> '0021' then
  begin
   ShowMessage('Указанный PIN не позволяет сменить номер');
   Exit;
  end;
 if GetNumberOnly(EditNumber.Text) = '' then Exit;
 FormMain.CID:=GetNumberOnly(EditNumber.Text);
 EditNumber.Text:=FormMain.CID;
 if Initialized then
  begin
   if FormMain.ClientSocketAsterisk.Active then
    begin
     FormMain.ActionReconExecute(nil);
     Sleep(2000);
    end;
   FormMain.ActionReconExecute(nil);
   FormMain.ActionReloadExecute(nil);
  end;
 Close;
end;

procedure TFormSettings.ButtonCloseClick(Sender: TObject);
begin
 Close;
end;

procedure TFormSettings.ButtonColorAeroClick(Sender: TObject);
begin
 FormMain.ButtonsColor:=ColorLighter(GetAeroColor);
 ColorSelectMenu.ColorValue:=FormMain.ButtonsColor;
end;

procedure TFormSettings.ButtonColorResetClick(Sender: TObject);
begin
 FormMain.ButtonsColor:=clDefMenuButtons;
 ColorSelectMenu.ColorValue:=FormMain.ButtonsColor;
end;

procedure TFormSettings.ButtonColorSetClick(Sender: TObject);
begin
 FormMain.ButtonsColor:=ColorLighter(ColorSelectMenu.ColorValue);
end;

procedure TFormSettings.CheckBoxAutorunClick(Sender: TObject);
begin
 FormMain.Autorun:=CheckBoxAutorun.Checked;
 CheckBoxAutorun.Checked:=FormMain.Autorun;
end;

procedure TFormSettings.CheckBoxUseAeroClick(Sender: TObject);
begin
 FormMain.UseAeroColor:=CheckBoxUseAero.Checked;
 ColorSelectMenuForMenu.ColorValue:=FormMain.MenuColor;
 ColorSelectMenu.ColorValue:=FormMain.ButtonsColor;
end;

procedure TFormSettings.FormCreate(Sender: TObject);
begin
 ClientWidth:=421;
end;

procedure TFormSettings.FormShow(Sender: TObject);
begin
 SetForegroundWindow(Handle);
 EditNumber.Text:=FormMain.CID;
 EditSecret.Text:='я полный идиот';
 TrackBarScale.Position:=WindScale;
 CheckBoxAutorun.Checked:=FormMain.Autorun;
 ColorSelectMenu.ColorValue:=FormMain.ButtonsColor;
 ColorSelectMenuForMenu.ColorValue:=FormMain.MenuColor;
 CheckBoxUseAero.Checked:=FormMain.UseAeroColor;
end;

end.
