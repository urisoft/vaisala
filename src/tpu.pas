unit tpu;

            interface

            uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,  ExtCtrls, Spin, ComCtrls, Grids,
  Menus, TeEngine, Series, TeeProcs, Chart, Mask, CheckLst, ScktComp;

            type
  TBaudRate = (cbr110, cbr300, cbr600, cbr1200, cbr2400, cbr4800, cbr9600,
    cbr14400, cbr19200, cbr38400, cbr56000, cbr57600, cbr115200, cbr128000, cbr256000);
    TForm1 = class(TForm)
    Label1: TLabel;
    Timer1: TTimer;
    Label4: TLabel;
    CS1: TClientSocket;
    Label2: TLabel;
    procedure FormShow(Sender: TObject);
    procedure parse;
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CS1Read(Sender: TObject; Socket: TCustomWinSocket);
    procedure Button2Click(Sender: TObject);
    public
    count:LongInt;
    d: array[0..1000] of Char;
    s,ads:string;
    f_work:byte;
    hPort: THandle;
{ Public declarations }
    end;
   TReadThread = class(TThread)
    private
{ Private declarations }
    end;

var
Form1: TForm1;
ComHandle: THandle;
dwMask, dwError,BytesWritten: DWORD;
Present:TDateTime;
tot_read:Real;
time_int,cn:LongInt;
DCB: TDCB;
CommTimeOuts:TCommTimeOuts;
  BytesRead :dword;
   Year, Month, Day:word;
    hour,min,sec,msec:word;
    DateSeparator: Char;
    TimeSeparator: Char;
    cl:byte;//1-соединение разорвано
implementation
{$R *.dfm}



procedure TForm1.parse;
var
i,j: LongInt;
mmrtst:Real;
begin
  ads:='';
  mmrtst:=0;
  j:=pos('Ta=',s);
  if j>0 then
  begin
  j:=j+2;
  for i:=1 to 4 do ads:=ads+s[j+i];
  Label1.Caption:='Температура: '+ads+' °C';
  j:=0;
  end;

  ads:='';
  j:=pos('Ua=',s);
  if j>0 then
  begin
  j:=j+2;
  for i:=1 to 4 do ads:=ads+s[j+i];
  ads:=ads+' %';
  Label1.Caption:=Label1.Caption+' Влажность: '+ads;
  j:=0;
  end;

  ads:='';
  j:=pos('Pa=',s);
  if j>0 then
  begin
  j:=j+2;
  for i:=1 to 5 do if (ord(s[j+i])in[$30..$39])or( ord(s[j+i])=$2e) then  ads:=ads+s[j+i];
  try mmrtst:=StrToFloat(ads)except mmrtst:=1.0 end;
  mmrtst:=mmrtst*750.063755;
  Label1.Caption:=Label1.Caption+' Давление: '+FloatToStrF(mmrtst,ffFixed,4,1)+' мм.рт.ст.';
  j:=0;
  end;
  s:='';
if mmrtst<>0 then
 begin
  CS1.Close;
  CS1.Socket.Disconnect(1);
  cl:=1;
  Label2.Caption:='Disconnected';
 end;

end;

procedure TForm1.FormShow(Sender: TObject);
var
i,j:byte;
begin
TimeSeparator:=':';
DateSeparator:='.';
DecimalSeparator:='.';
count:=0;
f_work:=1;
cl:=0;
 CS1.Open;
 CS1.Socket.Connect(0);
 Label2.Caption:='Connected';
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
DecodeTime(TdateTime(time),hour,min,sec,msec);
label4.Caption:='Время : '+IntToStr(hour)+':'+IntToStr(min)+':'+IntToStr(sec);
if  cl=1 then if (sec=10)or(sec=40) then
begin
 Label2.Caption:='Connected';
 cl:=0;
 CS1.Open;
 CS1.Socket.Connect(0);
end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  CS1.Close;
   CS1.Socket.Disconnect(1);
    Close;
end;

procedure TForm1.CS1Read(Sender: TObject; Socket: TCustomWinSocket);
begin
 s:=s+Socket.ReceiveText;
    if length(s)>60 then parse;
      if length(s)>60 then s:='';
end;

procedure TForm1.Button2Click(Sender: TObject);
var
mess:string;
begin
mess:='0R0'+#13+#10;
CS1.Socket.SendText(mess);
end;

end.

