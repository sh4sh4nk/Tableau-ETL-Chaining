@ECHO OFF
For /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set date=%%c%%a%%b)


ETLChaining.bat>>Tableau\logs\ExtractReflog_%date%.txt 2>&1
