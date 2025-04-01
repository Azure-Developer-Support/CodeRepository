###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 

#Powershell Command for fetching list of CA signed certificates and removing them.
 
 #The Get-AzApiManagement cmdlet gets a list of all API Management services under subscription or specified resource group or a particular API Management.
$apimservice= Get-AzApiManagement -ResourceGroupName "contosogroup" -Name "contoso"

#To check the context information for the APIM
$apimservice

#To retrieve the SystemCertificates information
$cert = $apimservice.SystemCertificates.CertificateInformation

#To view the cert information from the variable
$cert

#Get-Member tells us about the Properties and Methods of an object
$member =$cert |Get-Member


#this to remove all the CA certificates
$apimservice.SystemCertificates.Clear()  

#OR this to loop throught certificates and removes
$apimservice  |ForEach { $_.PSObject.Properties.Remove('SystemCertificates') }

#To update the service once we remove the CA certs from the context
#The Set-AzApiManagement cmdlet updates an Azure API Management service.
Set-AzApiManagement -InputObject $apimservice 
