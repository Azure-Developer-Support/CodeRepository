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
//Microsoft.Azure.ServiceBus

//This code will help to move data from one queue to another queue using transactions.

using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using System;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace MoveDataBetweenQueuesSample
{
    class MoveDataBetweenQueues
    {
        static string connectionString = "<NAMESPACE CONNECTION STRING>";
        static string queue1 = "TxnQueue1";
        static string queue2 = "TxnQueue2";
        static MessageSender queue1MessageSender;
        static MessageSender queue2MessageSender;
        static MessageReceiver queue1MessageReceiver;


        static async Task Main()
        {
            InitializeQueueClients();
            var key = 'y';
            while (key != 'n' && key != 'N')
            {
                Console.WriteLine($"Enter a message to send to {queue1}");
                var message = Console.ReadLine();
                Console.WriteLine($"Press any key to send the message to queue: {queue1}");
                Console.ReadKey();
                Console.WriteLine("Sending message...");
                await SendMessageAsync(queue1MessageSender, message);
                Console.WriteLine("Message sent successfully.\n");

                Console.WriteLine($"Press any key to transfer message from {queue1} to {queue2}");
                Console.ReadKey();
                Console.WriteLine("Transferring message...");
                await TransferMessageAsync();
                Console.WriteLine("Message transferred successfully.\n");

                Console.WriteLine("Do you want to repeat (y/n)");
                key = Console.ReadKey().KeyChar;
                Console.WriteLine();
            }

        }
        static async Task SendMessageAsync(MessageSender messageSender, string message)
        {
            await messageSender.SendAsync(new Message(Encoding.UTF8.GetBytes(message)));
        }

        private static async Task TransferMessageAsync()
        {
            var message = await queue1MessageReceiver.ReceiveAsync();
            if (message!=null)
            {
                using (var scope = new TransactionScope(TransactionScopeAsyncFlowOption.Enabled))
                {
                    try
                    {
                        await queue1MessageReceiver.CompleteAsync(message.SystemProperties.LockToken);
                        await queue2MessageSender.SendAsync(new Message(message.Body));
                        scope.Complete();
                        Console.WriteLine($"Message has been transferred from {queue1} to {queue2}");
                    }
                    catch (Exception ex)
                    {
                        scope.Dispose();
                        Console.WriteLine(ex);
                    }
                }
            }
        }

        private static void InitializeQueueClients()
        {
            var connection = new ServiceBusConnection(connectionString);
            queue1MessageSender = new MessageSender(connection, queue1, null);
            queue2MessageSender = new MessageSender(connection, queue2, viaEntityPath:queue1);
            queue1MessageReceiver = new MessageReceiver(connection, queue1);
        }
    }
}
