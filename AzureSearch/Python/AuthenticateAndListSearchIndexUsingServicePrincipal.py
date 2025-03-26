from azure.identity import ClientSecretCredential
from azure.search.documents.indexes import SearchIndexClient

# Replace these with your Service Principal details
tenant_id = '16b3c013-d300-468d-ac64-xxxxxxxxxxxxx'
client_id = '0ee98cd8-a583-4b81-aea4-xxxxxxxxxxxx'
client_secret = '_CF8Q~cItr9FoNKDPsN8ukkL~xxxxxxxxxxxx'

# Replace with your Azure Search service details
search_service_name = "bhautikaisearchtest"
endpoint = f"https://{search_service_name}.search.windows.net"

# Authenticate using the Service Principal credentials
credential = ClientSecretCredential(tenant_id=tenant_id, client_id=client_id, client_secret=client_secret)

# Create a client instance to interact with the search service
client = SearchIndexClient(endpoint=endpoint, credential=credential)

# Fetch the list of all indexes in the service
indexes = client.list_indexes()

# Print the list of indexes
for index in indexes:
    print(f"Index name: {index.name}")