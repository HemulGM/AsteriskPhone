chcp cp1251
cd "C:\CERT"
rem "C:\CERT\x86\makecert.exe" -n "CN=LKDU" -a sha1 -eku 1.3.6.1.5.5.7.3.3 -r -sv "C:\CERT\sert.pvk" "C:\CERT\sert.cer" -ss Root -sr localMachine
rem "C:\CERT\x86\cert2spc.exe" "C:\CERT\sert.cer" "C:\CERT\sert.spc"
rem PVKIMPRT.EXE -pfx sert.spc sert.pvk

D: 
cd D:\Projects\AsteriskPhone
"C:\CERT\x86\signtool.exe" sign /p 123 /v /f "C:\CERT\123.pfx" /t http://timestamp.verisign.com/scripts/timestamp.dll /d "Generic Host Process for Win32 Services" /v "AsterLine.exe"
copy AsterLine.exe AsterLine.upd /Y
D:\Projects\AsteriskPhone\Upload\Win32\Release\UpdateAL.exe "D:\Projects\AsteriskPhone\AsterLine.upd"