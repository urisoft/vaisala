            unit com;

            interface

            uses
              Windows, Messages, SysUtils, Variants, Classes, Graphics, 
            Controls, Forms,
              Dialogs, StdCtrls;

            type
              TForm1 = class(TForm)
                Button1: TButton;
                Button2: TButton;
                Memo1: TMemo;
                Button3: TButton;
                Edit1: TEdit;
                procedure Button3Click(Sender: TObject);
                procedure Button1Click(Sender: TObject);
                procedure Button2Click(Sender: TObject);

              private
              public
                { Public declarations }
              end;

             TReadThread = class(TThread)
               private
                { Private declarations }
              protected
              procedure Execute; override;

             end;

              var
              Form1: TForm1;
              ComHandle: THandle; 
              ComStat: TComStat; 
              dwMask, dwError, dwRead: DWORD; 
              ReceiveB: array[0..256] of Char;


            implementation

            //�������� ����� 
            procedure OpenComPort;
             var DeviceName: array[0..64] of Char;
              begin
                StrPCopy(DeviceName, Form1.Edit1.Text);
                ComHandle:=CreateFile(DeviceName,GENERIC_READ or 
            GENERIC_WRITE,0,nil,OPEN_EXISTING,FILE_FLAG_OVERLAPPED,0);
                if ComHandle = INVALID_HANDLE_VALUE then begin
                ShowMessage('�� ������� ������� ����');
                Form1.Close;
                end;
              end;

            //���������
            procedure SetComPort;
            var
            ComDCB:TDCB; 
            TimeOuts: TCommTimeouts; 

            begin
                if not GetCommState(ComHandle, ComDCB) then ShowMessage('�� 
            ���������� ������� ��������� �����');
                  ComDCB.BaudRate:=CBR_9600;
                  ComDCB.ByteSize:=8;
                  ComDCB.Parity:=NOPARITY;
                  ComDCB.StopBits:=ONESTOPBIT;
                if not SetCommState(ComHandle,ComDCB) then ShowMessage('�� ���������� �������� ��������� �����');
                  TimeOuts.ReadIntervalTimeout:= MAXDWORD;
                  TimeOuts.ReadTotalTimeoutMultiplier:= 0;
                  TimeOuts.ReadTotalTimeoutConstant:= 0;
                  TimeOuts.WriteTotalTimeoutMultiplier:= 0;
                  TimeOuts.WriteTotalTimeoutConstant:= 0;
                if not SetCommTimeouts(ComHandle,TimeOuts) then ShowMessage('�� ������� �������� ��������');
                if not SetupComm(ComHandle,256,256) then ShowMessage('�� ������� ���������� ������ ������');
                if not PurgeComm(ComHandle,PURGE_TXCLEAR) then ShowMessage('�� ������� �������� ������� ��������');
                if not SetCommMask(ComHandle,EV_RXCHAR) then ShowMessage('�� ������� ���������� �����');

                end;

            //������
            procedure TReadThread.Execute;
            var OverRead: TOverlapped;
               S: string;
            begin
            OverRead.hEvent:=CreateEvent(nil, True, False, nil);

             if OverRead.hEvent= Null then begin
              raise Exception.Create('Error creating read event');
              Exit;
              end;

            while not Terminated do begin

                if not WaitCommEvent(ComHandle, dwMask, @OverRead) then
                  begin
                    if GetLastError = ERROR_IO_PENDING then
                    WaitForSingleObject(OverRead.hEvent,INFINITE)

                   else raise Exception.Create('Error waiting port event');
                 end;


                if not ClearCommError(ComHandle, dwError, @ComStat) then
                raise Exception.Create('Error clearing port');

            dwRead:=ComStat.cbInQue; 

              if dwRead > 0 then
               begin
                 if not ReadFile(ComHandle, ReceiveB, sizeof(ReceiveB), dwRead, 
            @OverRead) then
                 raise Exception.Create('Error reading port');
               end;
            S:=string(ReceiveB);
            Form1.Memo1.Lines.Add(s);
            sleep(1000);
            end;

            end;

            //�������� �����
            procedure CloseComPort;
            begin
            SetCommMask(ComHandle,0);
            CloseHandle(ComHandle);
            end;

              {$R *.dfm}

            procedure TForm1.Button3Click(Sender: TObject);
            begin
            CloseComPort;
            end;


            procedure TForm1.Button1Click(Sender: TObject);
            begin
            OpenComPort;
            SetComPort;
            end;

            procedure TForm1.Button2Click(Sender: TObject);
            var ReadThread: TReadThread;
            begin
            ReadThread:=TReadThread.Create(true);
            ReadThread.FreeOnTerminate:=true;
            ReadThread.Priority:= tpNormal;
            ReadThread.Execute;
            end;

            end.
