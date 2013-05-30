unit comthread;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,Clipbrd;

type
  PTU = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

implementation

{ Important: Methods and properties of objects in VCL or CLX can only be used
  in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure PTU.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ PTU }
uses unit1;


procedure PTU.Execute;
 label ml1,m2;
 var
    ComStat:TComStat;
    c,Result: ShortString;
    i,j: LongInt;
dwMask, dwError: DWORD;
OverRead: TOverlapped;
Buf: array[0..$FF] of Byte;
dwRead,BytesRead: DWORD;
begin
m2:
j:=0;
Form1.s := '';
Form1.ads:='';
 Application.ProcessMessages;
 begin
 BytesRead :=0;
 if not ClearCommError(Form1.hPort, dwError, @ComStat) then
 raise Exception.Create('Error clearing port');
  dwRead:=ComStat.cbInQue;
   for i := 0 to 1000 do Form1.d[I]:=' ';
ml1:
   ReadFile(Form1.hPort, Form1.d, SizeOf(Form1.d),BytesRead, nil);
   for i := 0 to BytesRead do if Form1.d[i]<>' ' then Form1.s := Form1.s + Form1.d[i];
   Form1.count:=Form1.count+BytesRead;
   if( Form1.count<130)and(Form1.f_work=1) then goto ml1;
  end;
  Form1.parse;
  if  Form1.f_work=1 then goto m2;
 CloseHandle(Form1.hPort);
 Terminate;
 Form1.Close;
end;

end.
