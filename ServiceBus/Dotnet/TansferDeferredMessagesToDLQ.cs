/*Install Microsoft.Azure.ServiceBus nuget package -> this is depreciated by receives all critical & security updates. 
Reason to use this package: Message object supports MessageState enum (Active, Deferred, Scheduled), required for validating the state of peeked messages 
https://docs.microsoft.com/en-us/dotnet/api/microsoft.azure.servicebus.messagestate?view=azure-dotnet
*/

using System.Threading.Tasks;
using System;
using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using System.Collections.Generic;

namespace ConsoleApp1
{
    class Program
    {
        static string connectionString = "<ServiceBus-Connection-String>";
        static string queueName = "<Queue-Name>";
        //static string topicName = "<Topic-Name>";
        // static string subcriptionName = "<Subscription-Name>";
        
        static void Main(string[] args)
        {
            int maxMessageCount = 100;

            while (true)
            {
                List<long> DeferredMessageSeqNo = DeferMessagesInQueueAsync(maxMessageCount).GetAwaiter().GetResult();

                if (DeferredMessageSeqNo.Count != 0)
                {
                    ReadDeferred(DeferredMessageSeqNo).GetAwaiter().GetResult();
                }
                else
                {
                    break;
                }
            }
            Console.WriteLine("============ All deferred message processed ==========\n");
            Console.ReadKey();
        }
                
        static async Task<List<long>> DeferMessagesInQueueAsync(int maxMessages)
        {
            Console.WriteLine("============ Pulling Sequence Numbers for deferred messages =============");

            List<long> listOfSeqNumbersToDeffer = new List<long>();

            var receiver = new MessageReceiver(connectionString, queueName, ReceiveMode.PeekLock);
            //var subscriptionReceiver = new MessageReceiver(connectionString, EntityNameHelper.FormatSubscriptionPath(topicName, subscriptionName), ReceiveMode.PeekLock); // For topic-subscription
            
            var msgList = await receiver.PeekAsync(maxMessages);

                foreach (var msg in msgList)
                { 
                    Console.WriteLine($"Deferred Message - messageId: {msg.MessageId} \t SequenceNumber: {msg.SystemProperties.SequenceNumber} \t State : {msg.SystemProperties.State}");
                    if (msg.SystemProperties.State == MessageState.Deferred)
                    {
                        listOfSeqNumbersToDeffer.Add(msg.SystemProperties.SequenceNumber);
                    }
                    
                }
            await receiver.CloseAsync();
            
            Console.WriteLine($"DefferedMessages count in this iteration: {listOfSeqNumbersToDeffer.Count}");
            Console.WriteLine("============ Task completed ==========\n");
            return listOfSeqNumbersToDeffer;
        }

        static async Task ReadDeferred(List<long> seqNolist)
        {
            Console.WriteLine("============ Starting defer receiver task==========");
            var receiver = new MessageReceiver(connectionString, queueName, ReceiveMode.PeekLock);
            // var subscriptionReceiver = new MessageReceiver(connectionString, EntityNameHelper.FormatSubscriptionPath(topicName, subscriptionName), ReceiveMode.PeekLock); // For topic-subscription

            var defmsgList = await receiver.ReceiveDeferredMessageAsync(seqNolist);

            foreach (var msg in defmsgList)
            {
                if (msg != null)
                {
                    Console.WriteLine($"Received deferred messageId: {msg.MessageId} \t SequenceNumber: {msg.SystemProperties.SequenceNumber}");
                    //_ = receiver.CompleteAsync(msg.SystemProperties.LockToken); // To complete and remove the message.

                    Console.WriteLine($"MessageID: {msg.MessageId} dead-lettered!");
                    _ = receiver.DeadLetterAsync(msg.SystemProperties.LockToken); // Make sure you have enabled dead lettering on Messasge expiration over entity.
                }
            }
            await receiver.CloseAsync();
            Console.WriteLine("============ task completed ==========\n");

        }
    }
}
