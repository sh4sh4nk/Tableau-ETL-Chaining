$From = "global-Tableau-ServerAdmin@noreply"
$To = @('<recipient mail list>')
$date = Get-date -format "yyyyMMdd"
$logfile="E:\AutomationScript\Tableau\logs\ExtractReflog_" + $date + ".txt"
$Attachment = $logfile
$Subject = "Extract refresh script failure for [Site Name]"
$Body = "ETL Chaining script has failed, please check todays log file in E:\AutomationScript\Tableau\logs"
$SMTPServer = "<server>"
$SMTPPort = "<port>"
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Attachment $Attachment
