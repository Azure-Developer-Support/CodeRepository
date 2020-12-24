#-------------------------------------------------------------------------
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
#-------------------------------------------------------------------------

#IMPORT THE LIBRARIES INTO YOUR FILE
from azure.storage.filedatalake import DataLakeServiceClient
from azure.storage.filedatalake._shared.base_client import create_configuration

#OPTION 1  - MAKING USE OF CONNECTION STRING AND CREATING THE DATALAKE CLIENT 
connection_string="PUT CONNECTION STRING HERE"

#CREATE THE DATALAKE SERVICE CLIENT 
service_client = DataLakeServiceClient.from_connection_string(connection_string)

##OPTION 2  - MAKING USE OF ACCESS KEY AND CREATING THE DATALAKE CLIENT 
storage_account_key="ACCESS KEY"
storage_account_name="ACCOUNT NAME" 

#CREATE THE DATALAKE SERVICE CLIENT 
service_client = DataLakeServiceClient(account_url="{}://{}.dfs.core.windows.net".format("https", storage_account_name), credential=storage_account_key)

#PERFORM THE LISTING OPERATION
file_systems = service_client.list_file_systems()
for file_system in file_systems:
    print(file_system.name)
