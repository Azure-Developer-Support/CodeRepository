
import asyncio
from azure.servicebus.aio import ServiceBusClient 
from azure.servicebus import ServiceBusMessage

SERVICEBUS_CONNECTION_STR = "<SAS-Connection-String>"
ENTITY_NAME = "<Topic-Name/Queue-Name>"


async def send_single_message(client,entity_name):

    async with client:
        # print("Sender client created")
        
        #for Topic
        sender = client.get_topic_sender(entity_name)
        
        #for Queue replace above `sender` with the following:
        #sender = client.get_queue_sender(entity_name) 
        
        async with sender:
            message = ServiceBusMessage("Single Message")
            while True:
                await sender.send_messages(message)
                # print("sent")
        
async def Sender_clients(connection_string, entity_name):

    concurrent_sender = 50 #can increase this count

    client = ServiceBusClient.from_connection_string(connection_string)

    senderclients = [send_single_message(client,entity_name) for _ in range(concurrent_sender)]
    
    await asyncio.gather(*senderclients)

if __name__ == '__main__':
    asyncio.run(Sender_clients(SERVICEBUS_CONNECTION_STR,ENTITY_NAME))
