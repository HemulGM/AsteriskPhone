'������ ��������������� ����������� ������
 StartFile = "\\192.068.0.244\elix-public\sdfsdf.asd" ' ������ ��������
 EndFolder = "C:\aa.a" ' ���� ��������
 '***********************************************
 Set StartFiles = CreateObject("Scripting.FileSystemObject")
 Set WSNetwork = CreateObject("WScript.Network")
 num = 0
 '�������� �����
 on error resume next
 StartFiles.CopyFile StartFile, EndFolder, True

 '�������� � ����������� �����������
 If Err.Number>0 Then
 WScript.Echo "������ � ��������. "
 else
 WScript.Echo "������ �������."
 Err.Clear
 End if