#This sample python program is not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without a warranty of any kind. Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including
#, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages


import asyncio
from azure.servicebus.aio import ServiceBusClient 
from azure.servicebus import ServiceBusSubQueue
from datetime import datetime
import pytz
from dateutil.relativedelta import relativedelta

NAMESPACE_CONNECTION_STR = "<Connection-String>"
QUEUE_NAME = "<entity-name>"  # For Topic subscription, you can use below commented variables.

# TOPIC_NAME = "TOPIC_NAME"
# SUBSCRIPTION_NAME = "SUBSCRIPTION_NAME"

TARGET_DATE = datetime.now(tz=pytz.UTC) + relativedelta(months=-2)  # "-2" month old datetime from now. 

print(TARGET_DATE)

async def dlq_receiver(servicebus_client,queue_name):

        async with servicebus_client:
            
            receiver = servicebus_client.get_queue_receiver(queue_name,sub_queue=ServiceBusSubQueue.DEAD_LETTER) # use below for topic-subscription DLQ receiver client.  
            # receiver = servicebus_client.get_subscription_receiver(topic_name=TOPIC_NAME, subscription_name=SUBSCRIPTION_NAME, sub_queue=ServiceBusSubQueue.DEAD_LETTER)
            
            print("EntityPath: "+receiver.entity_path)

            async with receiver:
                while(True):
                    received_msgs = await receiver.receive_messages(max_wait_time=5, max_message_count=10)
                    
                    if(len(received_msgs)!=0 and received_msgs[0].enqueued_time_utc<TARGET_DATE):    
                        for msg in received_msgs:
                            print("Processed message EnqueuedDatetime: "+ str(msg.enqueued_time_utc) +" sequenceNo.: " + str(msg.sequence_number))
                            await receiver.complete_message(msg)
                    else:
                        print("completed!")
                        return

async def dlq_multiple_client(connection_string, queue_name):

    # Can increase this count to run more receiver clients.
    concurrent_receivers = 5 

    client = ServiceBusClient.from_connection_string(connection_string)

    receiver_clients = [dlq_receiver(client, queue_name) for _ in range(concurrent_receivers)]
    await asyncio.gather(*receiver_clients)


if __name__ == '__main__':
    asyncio.run(dlq_multiple_client(NAMESPACE_CONNECTION_STR,QUEUE_NAME))
