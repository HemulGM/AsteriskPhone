'скрипт автоматического копирования файлов
 StartFile = "\\192.068.0.244\elix-public\sdfsdf.asd" ' откуда копируем
 EndFolder = "C:\aa.a" ' куда копируем
 '***********************************************
 Set StartFiles = CreateObject("Scripting.FileSystemObject")
 Set WSNetwork = CreateObject("WScript.Network")
 num = 0
 'копируем файлы
 on error resume next
 StartFiles.CopyFile StartFile, EndFolder, True

 'сообщаем о результатах копирования
 If Err.Number>0 Then
 WScript.Echo "прошло с ошибками. "
 else
 WScript.Echo "прошло успешно."
 Err.Clear
 End if