
'''
DISCLAIMER:
This sample python program is not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without a warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages
'''

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
