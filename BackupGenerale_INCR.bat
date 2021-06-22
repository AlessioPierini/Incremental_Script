@Echo off
@title Backup
set loop=0

REM ========================================
REM Prova a montare la cartella di rete
REM ========================================

:BACKUP
color 0f
net use R: \\ILTUPERCORSO\CARTELLA
if ERRORLEVEL 1 goto loop
mode 61, 13

REM ============================
REM Impostazioni ora e data
REM ============================

Set mydate_0=%Date%
Set mydate_1=%mydate_0:/=-%
Set mydate=%mydate_1: =_%

REM ============================
REM Selezione cartelle
REM ============================

mode 116, 29
Set /p SSrv="Cartella di origine:		"							
echo Per esempio: 	C:\Cartella o \\server\cartella
Set /p DSrv="Cartella di destinazione:	"							

REM ======================================
REM Creare la cartella con nome+data
REM ======================================

if not exist "C:\LOG\" mkdir C:\LOG									
Set currBackupDir=%DSrv%\%mydate%
mkdir %currBackupDir%

REM ======================================
REM Opzioni robocopy
REM ======================================

Set Opt1=/MIR /FFT /R:3 /W:10 /Z /NP /NDL /LOG:C:\LOG\LOG_%mydate%.txt		

REM ======================================
REM Esegui RoboCopy
REM ======================================

Robocopy "%SSrv%" "%currBackupDir%" %Opt1%
ForFiles /p "%SSrv%" /s /d -30 /c "cmd /c del @file"				
cd %SSrv%
dir %SSrv% >> C:\LOG\LOG_File_Rimasti_%mydate%.txt
PING localhost -n 2 >NUL

REM ======================================
REM Sposta i LOG dentro la loro cartella
REM ======================================

if not exist "C:\LOG\LOG_%mydate%" mkdir "C:\LOG\LOG_%mydate%"		
MOVE "C:\LOG\LOG_%mydate%.txt" "C:\LOG\LOG_%mydate%"
MOVE "C:\LOG\LOG_File_Rimasti_%mydate%.txt" "C:\LOG\LOG_%mydate%"
PING localhost -n 2 >NUL

REM ======================================
REM Smontare disco e uscire
REM ======================================

net use * /delete /y												
exit

REM ======================================
REM Assenza di rete o errore
REM ======================================

:ERROR
echo Problema con la rete
timeout /t 3
exit

REM ========================================
REM Loop per verificare che la rete sia connessa
REM ========================================

:loop
color 04
set /a loop=%loop%+1 
net use * /delete /y
IF NOT ERRORLEVEL 1 goto BACKUP
TIMEOUT /t 2
if "%loop%"=="4" goto error
goto loop

REM Si possono usare credenziali diverse usando "  net use w: \\myserver\fileshare /user:MyID MyPassword  "




