#Azure Storage Blob - PowerShell
###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################
##########These scripts provide the script to access the Storage account for PUT operation using Access Key with CURL command #########################

$method = "PUT"
$headerDate = '2014-02-14'
$headers = @{"x-ms-version"="$headerDate"}
$StorageAccountName = "staticwebtest123" #Provide your storage account name
$StorageContainerName = "sudipta-files"  #Provide your storage account container name
$StorageAccountKey = "XXXXXXXXXX" #Provide your storage account access key
$Url = "https://$StorageAccountName.blob.core.windows.net/$StorageContainerName/stub1.txt" #Provide your storage account URL
$body = "Hello world"
$xmsdate = (get-date -format r).ToString()
$headers.Add("x-ms-date",$xmsdate)
$bytes = ([System.Text.Encoding]::UTF8.GetBytes($body))
$contentLength = $bytes.length
$headers.Add("Content-Length","$contentLength")
$headers.Add("x-ms-blob-type","BlockBlob") 
$signatureString = "$method$([char]10)$([char]10)$([char]10)$contentLength$([char]10)$([char]10)$([char]10)$([char]10)$([char]10)$([char]10)$([char]10)$([char]10)$([char]10)"#Add CanonicalizedHeaders
$signatureString += "x-ms-blob-type:" + $headers["x-ms-blob-type"] + "$([char]10)"
$signatureString += "x-ms-date:" + $headers["x-ms-date"] + "$([char]10)"
$signatureString += "x-ms-version:" + $headers["x-ms-version"] + "$([char]10)" #Add CanonicalizedResource
$uri = New-Object System.Uri -ArgumentList $url$signatureString += "/" + $StorageAccountName + $uri.AbsolutePath 
$dataToMac = [System.Text.Encoding]::UTF8.GetBytes($signatureString) 
$accountKeyBytes = [System.Convert]::FromBase64String($StorageAccountKey) 
$hmac = new-object System.Security.Cryptography.HMACSHA256((,$accountKeyBytes))
$signature = [System.Convert]::ToBase64String($hmac.ComputeHash($dataToMac)) 
$headers.Add("Authorization", "SharedKey " + $StorageAccountName + ":" + $signature); 
write-host 'URI' $Url
write-host 'Method' $method
write-host 'headers' $headers[1]
write-host 'Signature' $signature 

curl -Uri $Url -Method $method -headers $headers -Body $body
