# Azure Storage Blob Container Names and Count from Blob Inventory Report using Databricks - Python
### ATTENTION: DISCLAIMER ###

# DISCLAIMER
# The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, 
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages 


############# Script Overview #################################################################
########## This script helps in getting the Storage Account Container Names and Count from Blob Inventory Report using pyspark on Azure Databricks #########################

from pyspark.sql.types import StructType, StructField, IntegerType, StringType
import pyspark.sql.functions as F  
from pyspark.sql.functions import *

storage_account_name = "mystorageaccountname" # Storage Account Name
storage_account_key = "XXXX/d+XXXXX=" # Storage Account Primary/Secondary Access Key
container = "mycontainer" # Storage Account Container Name
blob_inventory_file = "/2023/12/05/11-32-49/766inventoryRule/766inventoryRule.csv" # Folder path where the blob inventory report is present
hierarchial_namespace_enabled = False

if hierarchial_namespace_enabled == False:
  spark.conf.set("fs.azure.account.key.{0}.blob.core.windows.net".format(storage_account_name), storage_account_key)
  df = spark.read.csv("wasbs://{0}@{1}.blob.core.windows.net/{2}".format(container, storage_account_name, blob_inventory_file), header='true', inferSchema='true')

else:
  spark.conf.set("fs.azure.account.key.{0}.dfs.core.windows.net".format(storage_account_name), storage_account_key)
  df = spark.read.csv("abfss://{0}@{1}.dfs.core.windows.net/{2}".format(container, storage_account_name, blob_inventory_file), header='true', inferSchema='true')

container_list=df.select(split(df.Name, '/', -1)[0].alias('container')).collect()
unique_container_list=set(container_list)

display(unique_container_list) # Prints the list of container
display(len(unique_container_list)) # Prints the number of container
