
chcp 65001
@ECHO OFF
ECHO.
ECHO. ==== %date% %time% Initiating  ETL Chaining Script ====
ECHO.
ECHO. ==== Setting Variables ====
ECHO.

setlocal EnableDelayedExpansion

REM Tabcmd location
SET tabcmd="<D:\Tableau Server\10.5\bin\tabcmd.exe>"

REM Shared Network path where Flag files are kept
SET shared_repo="<\\Network_Hostname\SomeFolder>"

REM Local repo is also maintained where flag files are copied from above network path
SET local_repo="<E:\AutomationScript\Tableau>"


ECHO ==== Login to Shared Network path with credentials ====
ECHO.



NET USE %shared_repo% <password>  /USER:<username>

if %ERRORLEVEL% neq 0 ( ECHO. %date% %time%:: Login Error in network, check Credentials or Network path %ERRORLEVEL%
GOTO MAIL_ALERT)


REM NET USE %shared_repo%

REM if %ERRORLEVEL% neq 0 ( ECHO Error level %ERRORLEVEL%, Login issues
REM EXIT /b %ERRORLEVEL%)

ECHO ==== Logged in ====
ECHO.

REM Get Current Date
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set DATE_THRESHOLD=%%c%%a%%b)
ECHO ==== Todays date is %DATE_THRESHOLD% ====
ECHO.



for /f " " %%F in ('dir /b /o:-d %shared_repo%\*_%DATE_THRESHOLD%.*') do (

REM Get Extract filename
SET filename=%%F

REM Strip _Date.txt from the file name, last 13 chars from file name format extractName_YYYYMMDD.txt
SET extract=!filename:~0,-13!

REM Set full text file name
set fullname=!extract!_%DATE_THRESHOLD%.txt

IF EXIST %shared_repo%\!fullname! (
if NOT exist %local_repo%\!fullname! (xcopy %shared_repo%\!fullname! %local_repo%
    if %ERRORLEVEL% neq 0 ( ECHO. %date% %time% :: File Copying Error from network %ERRORLEVEL%
GOTO MAIL_ALERT)
	ECHO.
	ECHO %date% %time% ====File found and triggering extract refresh for !extract! ====
	ECHO.
	%tabcmd% login --server <https://tableauhost.example> --username <tableauUser> --password <userPassword> -t "<SiteName>" --no-certcheck
	ECHO.
	if %ERRORLEVEL% neq 0 ( ECHO. %date% %time% :: Tableau Server login failure with error level %ERRORLEVEL%
GOTO MAIL_ALERT)

	REM Trigger extract refresh
	%tabcmd% refreshextracts --project "<Hardcoded Project name>" --datasource "!extract!" --no-certcheck

	if %ERRORLEVEL% neq 0 ( ECHO. %date% %time% :: Tableau Server extract refresh failure with error level %ERRORLEVEL%
GOTO MAIL_ALERT)

	) else ( echo. ==== Exit, as refresh extract has already been triggered for !extract! ====
echo.)
)


  )

net use /delete  %shared_repo%
ECHO. ==== %date% %time% Finished,  ETL Chaining Script ====
ECHO.

GOTO EOF

:MAIL_ALERT

Powershell.exe -executionpolicy remotesigned -File  E:\AutomationScript\Mailer.ps1

:EOF
