"""
Using two ServicePrincipals (for Eventhub and Key-vault separately). One ServicePrincipal to access KeyVault and read credentials for EH's ServicePrincipal. 

KeyVaultConfiguration
(KeyVault creation: https://docs.microsoft.com/en-us/azure/key-vault/general/quick-create-portal
 Storing secrets: https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-portal)
 
 Installing required packages:
     azure.eventhub: pip install azure-eventhub
     azure.identity: pip install azure-identity
     azure.keyvault: pip install azure-keyvault

"""

import os
from azure.eventhub import EventData, EventHubProducerClient
from azure.identity import EnvironmentCredential, ClientSecretCredential
from azure.keyvault.secrets import SecretClient

 
fully_qualified_namespace = "<Eventhub-namespace>.servicebus.windows.net"
eventhub_name = "<entityName>"

#To access Azure Key vault with another service principal, user can use a different script or manually set the environment variable. 
os.environ["AZURE_TENANT_ID"] = "<Tenant ID for KeyVault service principal>"
os.environ["AZURE_CLIENT_ID"] = "<Client/APP ID for KeyVault service principal>"
os.environ["AZURE_CLIENT_SECRET"] = "<Client secret for KeyVault service principal>"


def fetchEHCredientials():
    keyVaultName = "<keyVault-name>"
    KVUri = f"https://{keyVaultName}.vault.azure.net"
    
    print(f"Fetching EH credientials from KeyVault: {keyVaultName}")
    #key-vault stores Credentials for Service-principal which has a sender role (Azure Servicebus Data Sender) in the given eventhub.
    
    
    keyVaultAppcredential =  EnvironmentCredential()
    
    KeyVaultclient = SecretClient(vault_url=KVUri, credential=keyVaultAppcredential)
    
    
    SecretName = ["AZURE-TENANT-ID","AZURE-CLIENT-ID", "AZURE-CLIENT-SECRET" ]
    EHappRegcred = [KeyVaultclient.get_secret(i).value for i in SecretName]
    
    
    eventhubAppCredential = ClientSecretCredential(tenant_id= EHappRegcred[0], client_id= EHappRegcred[1], client_secret= EHappRegcred[2])
    
    print("Credentials fetched.")
    
    return eventhubAppCredential


def EventhubSender(eventhubAppCredential):
    
    print("Initiating sender client..")
    #Creating a Eventhub producer client using ServicePrincipal credentials
    producer = EventHubProducerClient(fully_qualified_namespace=fully_qualified_namespace,
                                  eventhub_name=eventhub_name,
                                  credential=eventhubAppCredential)

    with producer:
        event_data_batch = producer.create_batch()
       
        try:
            event_data_batch.add(EventData('Message inside EventBatchData'))
        except ValueError:
           
            print("error")
        producer.send_batch(event_data_batch)
    
    print('One Batch sent successfully.')
    
    
if __name__ == '__main__':
    
    print("Starting..")
    EHCred = fetchEHCredientials()
    EventhubSender(EHCred)
    print("End")
