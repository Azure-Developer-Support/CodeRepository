import os, uuid
from azure.identity import DefaultAzureCredential
from azure.storage.queue import QueueServiceClient, QueueClient, QueueMessage, BinaryBase64DecodePolicy, BinaryBase64EncodePolicy

# Update the account name
account_name = ''

print("Azure Queue storage - Python quickstart sample")
# Create a unique name for the queue
queue_name = "quickstartqueues-" + str(uuid.uuid4())
account_url = "https://"+ account_name +".queue.core.windows.net"
default_credential = DefaultAzureCredential()
# Create the QueueClient object
# We'll use this object to create and interact with the queue
# For Authetication mechanism please refer https://learn.microsoft.com/en-us/azure/storage/queues/storage-quickstart-queues-python?tabs=passwordless%2Croles-azure-portal%2Cenvironment-variable-windows%2Csign-in-azure-cli#code-examples

queue_client = QueueClient(account_url, queue_name=queue_name ,credential=default_credential)
print("Azure Queue storage created with name :" + queue_name)
queue_service = QueueServiceClient(account_url, queue_name=queue_name ,credential=default_credential)

# Retrieve logging properties
logging_properties = queue_service.get_service_properties()
print(logging_properties)
print(logging_properties["hour_metrics"])
print(logging_properties["minute_metrics"])
print(logging_properties["analytics_logging"])
