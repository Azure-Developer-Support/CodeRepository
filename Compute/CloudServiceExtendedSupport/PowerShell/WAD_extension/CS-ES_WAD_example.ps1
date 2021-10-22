# Create WAD extension object
$storageAccountKey = Get-AzStorageAccountKey -ResourceGroupName "CS-ES-TEST" -Name "csesstorageaccount"
$configFilePath = "C:\Users\satlb\Downloads\Public-config.xml"
$wadExtension = New-AzCloudServiceDiagnosticsExtension -Name "WADExtension" -ResourceGroupName "CS-ES-TEST" -CloudServiceName "customertestsk" -StorageAccountName "csesstorageaccount" -StorageAccountKey $storageAccountKey[0].Value -DiagnosticsConfigurationPath $configFilePath -TypeHandlerVersion "1.5" -AutoUpgradeMinorVersion $true


# Add <privateConfig> settings
$wadExtension.ProtectedSetting = "<PrivateConfig><StorageAccount name='<storage account name>' key='<storage account key>' endpoint='https://core.windows.net/' /></PrivateConfig>"


# Get existing Cloud Service
$cloudService = Get-AzCloudService -ResourceGroup "CS-ES-TEST" -CloudServiceName "customertestsk"


# Add WAD extension to existing Cloud Service extension object
$cloudService.ExtensionProfile.Extension = $cloudService.ExtensionProfile.Extension + $wadExtension


# Update Cloud Service
$cloudService | Update-AzCloudService

#The sample Public-config.xml is attached in the same folder for reference.
