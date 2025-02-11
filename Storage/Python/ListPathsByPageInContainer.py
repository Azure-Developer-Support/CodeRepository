#-------------------------------------------------------------------------
#DISCLAIMER
#The sample scripts are not supported under any Microsoft standard support program or service.
# The sample scripts are provided AS IS without warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.
# The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.
# In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including,
# without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
#-------------------------------------------------------------------------

# This script helps in listing paths by page in a conatiner in ADLS Gen2 account

#IMPORT THE LIBRARIES INTO YOUR FILE
from azure.identity import DefaultAzureCredential
from azure.storage.filedatalake import (
    DataLakeDirectoryClient,
    DataLakeServiceClient,
    FileProperties,
    FileSystemClient,
)

connection_string = "Azure Data Lake Storage Account Connection String"
container_name = "mycontainer"
maxresults_parpage = 3
 
dfs_client = DataLakeServiceClient.from_connection_string(connection_string)
 
def main():
    dfs_fs_client = dfs_client.get_file_system_client(file_system=container_name)
    paths = dfs_fs_client.get_paths(max_results=maxresults_parpage)
    allpaths = dfs_fs_client.get_paths()

    print("=============all paths:===============")
    print(len(list(paths)))

    print("=============path by page:===============")
    print(len(list(paths.by_page())))
 
    # outputs all the paths
    print("===================path in paths:===================")

    for path in allpaths:
        print(path.name)
 
    # list iterators
    print("==================list===================")
    list_paths = list(paths.by_page())

    for item in list_paths:
        for file in item:
            #print(file.name)
            print(file)
 
if __name__ == '__main__':
    main()
