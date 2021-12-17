###ATTENTION: DISCLAIMER###

#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


#############Script Overview#################################################################

#The below scripts will give you the activation details and its last exit information like exit code, timestamp etc of all services of an application across all nodes. While you can see same information from SF explorer but with SF explorer you can see only one code package for one node at a time.
#These scripts will provide details of an application (all services) across all nodes:

# Connect to the cluster using a client certificate.

Connect-ServiceFabricCluster -ConnectionEndpoint <endpoint> -KeepAliveIntervalInSec 10 -X509Credential -ServerCertThumbprint <thumbprint> -FindType FindByThumbprint -FindValue <thumbprint> -StoreLocation CurrentUser -StoreName My
#Get all the nodes of the cluster

$nodes = Get-ServiceFabricNode

#loop through all the nodes and get the deployed package details

foreach($node in $nodes)
{
  
    Write-Output "=============================Node:==================== " $node.NodeName "================================================="

    Get-ServiceFabricDeployedCodePackage -NodeName $node.NodeName -ApplicationName "fabric:/GettingStartedApplication" 
  }

#If you want to check the deployed code package details for a specific service, you can update the service package name in the PS cmd as below:

#Get-ServiceFabricDeployedCodePackage -NodeName "_nt_0" -ApplicationName "fabric:/GettingStartedApplication" -ServiceManifestName "ActorBackendServicePkg" 

#Ref: https://docs.microsoft.com/en-us/powershell/module/servicefabric/get-servicefabricdeployedcodepackage?view=azureservicefabricps
