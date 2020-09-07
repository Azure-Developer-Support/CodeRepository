#+++++++++++++++DISCLAIMER+++++++++++++++++++++++++++++
#------------------------------------------------------------------------
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for 
#a particular purposes. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, owners of this github repository, or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 
#-------------------------------------------------------------------------



param(
[Parameter(Mandatory=$true)]
[string]$cacheName,
[Parameter(Mandatory=$false)]
[string]$dnsSuffix = ".redis.cache.windows.net",
[Parameter(Mandatory=$false)]
[int]$port = 6380,
[Parameter(Mandatory=$false)]
[int]$timeoutMS = 2000
)
$dns = "$cacheName$dnsSuffix"
$protocolsToTest = @(
    [System.Security.Authentication.SslProtocols]::Tls,
    [System.Security.Authentication.SslProtocols]::Tls11,
    [System.Security.Authentication.SslProtocols]::Tls12
)
$protocolsToTest | % {
    $ver = $_
    $tcpsocket = New-Object Net.Sockets.TcpClient($dns, $port)
    if(!$tcpsocket)
    {
        Write-Error "$ver- Error Opening Connection: $port on $computername Unreachable"
        exit 1;
    }
    else
    {
        $tcpstream = $tcpsocket.GetStream()
        $sslStream = New-Object System.Net.Security.SslStream($tcpstream,$false)
        $sslStream.ReadTimeout = $timeoutMS
        $sslStream.WriteTimeout = $timeoutMS
        try
        {
            $sslStream.AuthenticateAsClient($dns, $null, $ver, $false)
            Write-Host "$ver- Enabled"
        }
        catch [System.IO.IOException]
        {
            Write-Host "$ver- Disabled"
        }
        catch
        {
            Write-Error "Unexpected exception $_"
        }
    }
}
