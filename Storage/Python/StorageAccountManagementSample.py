# The below script is a sample piece of code that helps performing storage account management operations
# We are extracting the properties for the storage account and updating them via code.
#--------------------------------------------------------------------------
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
#--------------------------------------------------------------------------

#IMPORT THE LIBRARIES INTO YOUR FILE
import os
from azure.mgmt.storage import StorageManagementClient
from azure.identity import ClientSecretCredential
from azure.mgmt.storage.models import (StorageAccountUpdateParameters)

#DECLERATION OF VARIABLES
AZURE_CLIENT_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_TENANT_ID = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_CLIENT_SECRET = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_SUBSCRIPTION = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
AZURE_STORAGE_ACCOUNT_NAME = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
AZURE_STORAGE_RESOURCE_NAME = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

#SETTING UP THE CREDENTIALS
credentials = ClientSecretCredential(
    client_id=AZURE_CLIENT_ID,
    tenant_id=AZURE_TENANT_ID,
    client_secret=AZURE_CLIENT_SECRET)

#CREATE STORAGE ACCOUNT MANAGEMENT CLIENT OVER SUBSCRIPTION
storage_client = StorageManagementClient(credentials, subscription_id=AZURE_SUBSCRIPTION)

#GETTING PROPERTIES OF STORAGE ACCOUNT
storage_account = storage_client.storage_accounts.get_properties(resource_group_name=AZURE_STORAGE_RESOURCE_NAME,account_name=AZURE_STORAGE_ACCOUNT_NAME)

#PRINTING PROPERTIES OF STORAGE ACCOUNT
print("Properties of Storage Account are as follow :")
for item in storage_client.storage_accounts.list():
  print(item)

#PRINTING SPECIFIC PROPERTIES VALUES
print("Current Value for Allow Blob Public Access Property : " + str(storage_account.allow_blob_public_access))

print("Current Value for Allow Minimum TLS Version : " + storage_account.minimum_tls_version)

#UPDATING THE PROPERTY VALUE
storage_client.storage_accounts.update(AZURE_STORAGE_RG_NAME,AZURE_STORAGE_ACCOUNT_NAME,StorageAccountUpdateParameters(allow_blob_public_access=False))
storage_client.storage_accounts.update(AZURE_STORAGE_RG_NAME,AZURE_STORAGE_ACCOUNT_NAME,StorageAccountUpdateParameters(minimum_tls_version='TLS1_1'))

#GETTING UPDATED PROPERTIES OF STORAGE ACCOUNT
storage_account = storage_client.storage_accounts.get_properties(resource_group_name=AZURE_STORAGE_RESOURCE_NAME,account_name=AZURE_STORAGE_ACCOUNT_NAME)

#PRINTING NEW PROPERTIES VALUES
print("New Value for Allow Blob Public Access Property : "+str(storage_account.allow_blob_public_access))
print("New Value for Allow Minimum TLS Version : "+storage_account.minimum_tls_version)


