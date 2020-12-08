####
## DISCLAIMER : This is a sample and is provided as is with no warranties express or implied.
####
[Reflection.Assembly]::LoadWithPartialName("System.Web")| out-null
Parameter
$uri = 'https://<yournamespace>.servicebus.windows.net/<yourqueuename>'
$Access_Policy_Name="<youraccesspolicyname>"
$Access_Policy_Key="youraccesskeyvalue"

#Token expires now+300
$Expires=([DateTimeOffset]::Now.ToUnixTimeSeconds())+300
#Building Token
$SignatureString=[System.Web.HttpUtility]::UrlEncode($URI)+ "`n" + [string]$Expires
$HMAC = New-Object System.Security.Cryptography.HMACSHA256
$HMAC.key = [Text.Encoding]::ASCII.GetBytes($Access_Policy_Key)
$Signature = $HMAC.ComputeHash([Text.Encoding]::ASCII.GetBytes($SignatureString))
$Signature = [Convert]::ToBase64String($Signature)
$SASToken = "SharedAccessSignature sr=" + [System.Web.HttpUtility]::UrlEncode($URI) + "&sig=" + [System.Web.HttpUtility]::UrlEncode($Signature) + "&se=" + $Expires + "&skn=" + $Access_Policy_Name
$headerParams = @{'Authorization'="$($SASToken)"}
$messageuri =  $uri + '/' + 'messages'
$body = @{'name'= 'test message'} 

Invoke-WebRequest -Uri $messageuri -Method Post -Headers $headerParams -Body $body 
