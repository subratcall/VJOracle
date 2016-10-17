$EmailFrom = “menonvp@gmail.com”
$EmailTo = “menonvp@gmail.com”
$Subject = “Test from windows”
$Body = “testing powersheel emailing”
$SMTPServer = “smtp.gmail.com”
$SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 587)
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential(“menonvp”, “neelkannan12”);
$SMTPClient.Send($EmailFrom, $EmailTo, $Subject, $Body)