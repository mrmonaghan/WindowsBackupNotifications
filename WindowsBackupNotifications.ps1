#Define ProviderName
$ProviderName = "Microsoft-Windows-Backups"

#Build lists of events based on $ProviderName and Event Level
$Errors = Get-WinEvent -FilterHashtable @{ProviderName=$ProviderName
                                Level='1','2','3'
          }
$Information = Get-WinEvent -FilterHashtable @{ProviderName=$ProviderName
                                               Level='4'
                                               }
#Filter $Errors and $Information based on TimeCreated property
$RecentErrors = $Errors | Where-Object {$_.TimeCreated -ge (Get-Date).AddDays(-1)}
$RecentSuccess = $Information | Where-Object {$_.TimeCreated -ge (Get-Date).AddDays(-1)}

#Define mailing information
$To = "recipient@mail.com"
$From = "sender@mail.com"
$SMTPServer = "smtp.webaddress.com"
#Build Email Formatting
$HTMLBody = @()
$Header = @"
            <style>
            body { background-color:#FFFFFF;
            font-family:Tahoma;
            font-size:12pt; }
            h3, h4 {text-align:center;}
            td, th { border:1px solid black;
            border-collapse:collapse; }
            th { color:white;
            background-color:black; }
            table, tr, td, th { padding: 2px; margin: 0px }
            table { width:95%;margin-left:5px; margin-bottom:20px;}
            </style>
"@
$HTMLBody += $Header


#If $RecentErrors contains data, build it into the $HTMLBody table and sent the notification. Else, build $RecentSuccesses into $HTMLBody and send the ntoification
if ($RecentErrors.count -gt 0) {
    $HTMLBody += '<h3>The following backup errors occurred:</h3>'
    $HTMLBody += $RecentErrors | Select-Object TimeCreated,Id,LevelDisplayName,Message | ConvertTo-Html -Fragment | Out-String
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject "Backup Errors" -BodyasHtml -Body "$HTMLBody"
    }
else {
    $HTMLBody += '<h3>Backups succeeded! See related Event Logs below:</h3>'
    $HTMLBody += $RecentSuccess | Select-Object TimeCreated,Id,LevelDisplayName,Message | ConvertTo-Html -Fragment | Out-String
    Send-MailMessage -To $To -From $From -SmtpServer $SMTPServer -Subject "Backup Success!" -BodyasHtml -Body "$HTMLBody"
    }


