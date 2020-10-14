# script reference
# https://docs.microsoft.com/en-us/azure/service-fabric/scripts/service-fabric-powershell-deploy-application

$ClusterName= "YOUR-FULL-CLUSTER-NAME:19000"
$Certthumprint = "YOUR-SF-ACCESS-CERTIFICATE"
$packagepath="YOUR-APP-PACKAGE-FOLDER"
$ApplicationName = "fabric:/DataLossCheckApp"
$ApplicationTypeName = "DataLossCheckAppType"
$ApplicationTypeVersion = "1.0.0"
$ApplicationPackagePathInImageStore = "DataLossCheckApp"

Connect-ServiceFabricCluster -ConnectionEndpoint $ClusterName -KeepAliveIntervalInSec 10 `
     -X509Credential `
     -ServerCertThumbprint $Certthumprint  `
     -FindType FindByThumbprint `
     -FindValue $Certthumprint `
     -StoreLocation CurrentUser `
     -StoreName My

# Copy the application package to the cluster image store.
Copy-ServiceFabricApplicationPackage $packagepath -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $ApplicationPackagePathInImageStore

# Register the application type.
Register-ServiceFabricApplicationType -ApplicationPathInImageStore $ApplicationPackagePathInImageStore

# Create the application instance.
New-ServiceFabricApplication -ApplicationName $ApplicationName -ApplicationTypeName $ApplicationTypeName -ApplicationTypeVersion $ApplicationTypeVersion

# Remove the application package to free system resources.
Remove-ServiceFabricApplicationPackage -ImageStoreConnectionString fabric:ImageStore -ApplicationPackagePathInImageStore $ApplicationPackagePathInImageStore




