D: 
cd D:\Projects\AsteriskPhone
"C:\CERT\x86\signtool.exe" sign /p 123 /v /f "C:\CERT\123.pfx" /t http://timestamp.verisign.com/scripts/timestamp.dll /d "Generic Host Process for Win32 Services" /v "AsterLine.exe"
copy AsterLine.exe AsterLine.upd /Y
pause