//'By using the following materials or sample code you agree to be bound by the license terms below 
//'and the Microsoft Partner Program Agreement the terms of which are incorporated herein by this reference. 
//'These license terms are an agreement between Microsoft Corporation (or, if applicable based on where you 
//'are located, one of its affiliates) and you. Any materials (other than sample code) we provide to you 
//'are for your internal use only. Any sample code is provided for the purpose of illustration only and is 
//'not intended to be used in a production environment. We grant you a nonexclusive, royalty-free right to 
//'use and modify the sample code and to reproduce and distribute the object code form of the sample code, 
//'provided that you agree: (i) to not use Microsoft’s name, logo, or trademarks to market your software product 
//'in which the sample code is embedded; (ii) to include a valid copyright notice on your software product in 
//'which the sample code is embedded; (iii) to provide on behalf of and for the benefit of your subcontractors 
//'a disclaimer of warranties, exclusion of liability for indirect and consequential damages and a reasonable 
//'limitation of liability; and (iv) to indemnify, hold harmless, and defend Microsoft, its affiliates and 
//'suppliers from and against any third party claims or lawsuits, including attorneys’ fees, that arise or result 
//'from the use or distribution of the sample code."  

//Pre-requisite: Following nuget packages needs to be installed
//Microsoft.Azure.EventHubs
//Microsoft.Azure.EventHubs.Processor


//This code will help to onsume multiple event hub data from single eventhubconsumer.py 


from flask import Flask
from azure.eventhub import EventData, EventHubConsumerClient, EventHubProducerClient
import threading
import logging

logger = logging.getLogger("azure.eventhub")
logging.basicConfig(level=logging.INFO)


connection_str1 = 'Endpoint=sb://[EventHubNamespace].servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=xxxxxxxxxxx'
eventhub_name1 = 'ns8002'
client = EventHubProducerClient.from_connection_string(connection_str1, eventhub_name=eventhub_name1)
receiverClient = EventHubConsumerClient.from_connection_string(connection_str1,'test2', eventhub_name=eventhub_name1)


connection_str2 = 'Endpoint=sb://[EventHubNamespace].servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=xxxxxxxxx'
eventhub_name2 = 'ns8003'
client2 = EventHubProducerClient.from_connection_string(connection_str2, eventhub_name=eventhub_name2)
receiverClient2 = EventHubConsumerClient.from_connection_string(connection_str2, 'test2', eventhub_name=eventhub_name2)



app = Flask(__name__)

def on_event1(partition_context, event):
   logger.info(event)
   partition_context.update_checkpoint(event)
    
def on_event2(partition_context, event):
    logger.info(event)
    partition_context.update_checkpoint(event)

# send a few test messages
@app.route("/send")
def sendEvents():
    
    event_data_batch = client.create_batch()
    for i in range(5):
        event_data_batch.add(EventData('message from ns8002'))
    with client:
        client.send_batch(event_data_batch)
        
    event_data_batch = client2.create_batch()
    for i in range(5):
        event_data_batch.add(EventData('message from ns8003'))
    with client2:
        client2.send_batch(event_data_batch)   
    
    return "Done sending the Events!"

def readAsync1():
    with receiverClient :
          receiverClient.receive(
            on_event=on_event1, 
            starting_position="-1",  # "-1" is from the beginning of the partition.
             partition_id='0'
        )

def readAsync2():
     with receiverClient2 :
         receiverClient2.receive(
            on_event=on_event2, 
            starting_position="-1",  # "-1" is from the beginning of the partition.
             partition_id='0'
        )
        
@app.route("/getAsync")
def getAsync():   
    thread1 = threading.Thread(target=readAsync1 )
    thread2 = threading.Thread(target=readAsync2 )
    thread1.start()
    thread2.start()
    thread1.join()
    thread2.join()
    
    return "done"
    

    
if __name__ == "__main__":
    app.run()
