program exec;

{$APPTYPE CONSOLE}

uses
  windows,SysUtils,Classes,Contnrs, StrUtils,forms,Dialogs,shellapi;


  procedure EnumFileInQueue(path: PChar; fileExt: string; fileList: TStringList);

var 
   searchRec: TSearchRec;
   found: Integer;
   tmpStr: string;
   curDir: string;
   dirs: TQueue;
   pszDir: PChar;

begin

   dirs := TQueue.Create; //����Ŀ¼����
   dirs.Push(path); //����ʼ����·�����
   pszDir := dirs.Pop;
   curDir := StrPas(pszDir); //����
   {��ʼ����,ֱ������Ϊ��(��û��Ŀ¼��Ҫ����)}
   while (True) do
   begin
      //����������׺,�õ�����'c:\*.*' ��'c:\windows\*.*'������·��
      tmpStr := curDir + '\*.*';
      //�ڵ�ǰĿ¼���ҵ�һ���ļ�����Ŀ¼
      found := FindFirst(tmpStr, faAnyFile, searchRec);
      while found = 0 do //�ҵ���һ���ļ���Ŀ¼��
      begin
          //����ҵ����Ǹ�Ŀ¼
         if (searchRec.Attr and faDirectory) <> 0 then
         begin
          {�������Ǹ�Ŀ¼(C:\��D:\)�µ���Ŀ¼ʱ�����'.','..'��"����Ŀ¼"
          ����Ǳ�ʾ�ϲ�Ŀ¼���²�Ŀ¼�ɡ�����Ҫ���˵��ſ���}
            if (searchRec.Name <> '.') and (searchRec.Name <> '..') then
            begin
               {���ڲ��ҵ�����Ŀ¼ֻ�и�Ŀ¼��������Ҫ�����ϲ�Ŀ¼��·��
                searchRec.Name = 'Windows';
                tmpStr:='c:\Windows';
                �Ӹ��ϵ��һ�������
               }
               tmpStr := curDir + '\' + searchRec.Name;
               {����������Ŀ¼��ӡ����������š�
                ��ΪTQueue���������ֻ����ָ��,����Ҫ��stringת��ΪPChar
                ͬʱʹ��StrNew������������һ���ռ�������ݣ������ʹ�Ѿ���
                ����е�ָ��ָ�򲻴��ڻ���ȷ������(tmpStr�Ǿֲ�����)��}
               dirs.Push(StrNew(PChar(tmpStr)));
            end;
         end
         else //����ҵ����Ǹ��ļ�
         begin
             {Result��¼�����������ļ���������������CreateThread�����߳�
              �����ú����ģ���֪����ô�õ��������ֵ�������Ҳ�����ȫ�ֱ���}
            //���ҵ����ļ��ӵ�Memo�ؼ�
            if fileExt = '.*' then
               fileList.Add(curDir + '\' + searchRec.Name)
            else
            begin
               if SameText(RightStr(curDir + '\' + searchRec.Name, Length(fileExt)), fileExt) then
                  fileList.Add(curDir + '\' + searchRec.Name);
            end;
         end;
          //������һ���ļ���Ŀ¼
         found := FindNext(searchRec);
      end;  
      {��ǰĿ¼�ҵ������������û�����ݣ����ʾȫ���ҵ��ˣ�
        ������ǻ�����Ŀ¼δ���ң�ȡһ�������������ҡ�}
      if dirs.Count > 0 then
      begin
         pszDir := dirs.Pop;
         curDir := StrPas(pszDir);
         StrDispose(pszDir);
      end
      else
         break;
   end;
   //�ͷ���Դ
   dirs.Free;
   FindClose(searchRec);

end;

   var dir: string;  
   i,j:integer;
   FileNameList: TStringList;
   exepath,exeparms:string;
   exedir:pchar;
   startupInfo :TStartupInfo;
  process:TProcessInformation;//exe������Ϣ
  newname:string;
begin 

  if paramstr(1)='' then exit;
   dir := trim(ExtractFilePath(Application.ExeName)+'replay');
   FileNameList := TStringList.Create;
   FileNameList.Add(ExtractFilePath(Application.ExeName)+paramstr(1));
   //EnumFileInQueue(PChar(dir), '.*', FileNameList);
   for i:=0 to FileNameList.Count-1 do
   begin
      try
       newname:=ExtractFileName(FileNameList[i]);
       writeln(FileNameList[i]);
       exepath:=pchar(ExtractFilePath(ParamStr(0))+'pro.exe');
       exeparms:=newname;
       writeln(exepath+' '+exeparms);
       exedir:=pchar(ExtractFilePath(ParamStr(0)));
       writeln(exedir);
       FillChar(startupInfo,sizeof(StartupInfo),0);

          //����һ��YGOCORE����
          if CreateProcess(nil,pchar(exepath+' '+exeparms),Nil,Nil,True,CREATE_NO_WINDOW,Nil,exedir,startupInfo,process) then
          begin
            for j:=0 to 10000 do
            begin
              sleep(5);
            end;
          end;
          TerminateProcess(process.hProcess,0);
      finally
      end;
   end;
   FileNameList.Free;
end.
