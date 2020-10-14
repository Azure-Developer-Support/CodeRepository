using Microsoft.Azure.ServiceBus;
using Microsoft.Azure.ServiceBus.Core;
using Microsoft.Extensions.Configuration;
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace SBClient
{
    class Program
    {
        private static readonly string connectionString = string.Empty;
        private static readonly Lazy<QueueClient> queueClient = null;

        static Program()
        {
            // Get config settings from AppSettings
            IConfigurationBuilder builder = new ConfigurationBuilder().AddJsonFile("appsettings.json")
                                                                    .AddJsonFile("appsettings.Development.json");
            IConfigurationRoot configuration = builder.Build();

            // read ServiveBus connection string
            connectionString = configuration["SB-CONNECTION-STRING"];

            queueClient = new Lazy<QueueClient>(
                () => new QueueClient(connectionString, "applogs")
            );
        }

        static async Task Main(string[] args)
        {
            var cts = new CancellationTokenSource();
            var receiveTask = ReceiveMessagesAsync(connectionString, "applogs", cts.Token);

            await Task.WhenAll(
                Task.Delay(2000),
                receiveTask
                );
        }

        private static async Task ReceiveMessagesAsync(string connectionString, string queueName, CancellationToken cancellationToken)
        {
            var receiver = new MessageReceiver(connectionString, queueName, ReceiveMode.PeekLock);

            // If the cancellation token is triggered, we close the receiver, which will trigger 
            // the receive operation below to return null as the receiver closes.
            cancellationToken.Register(() => receiver.CloseAsync());

            Console.WriteLine("Receiving message from Queue...");

            while (!cancellationToken.IsCancellationRequested)
            {
                try
                {
                    var message = await receiver.ReceiveAsync();

                    if (message != null)
                    {
                        if (message.Label != null)
                        {
                            Console.WriteLine($"LABEL - {message.Label}");
                            Console.WriteLine($"BODY - {Encoding.UTF8.GetString(message.Body)}");

                            // Now that we're done with "processing" the message, we tell the broker about that being the
                            // case. The MessageReceiver.CompleteAsync operation will settle the message transfer with 
                            // the broker and remove it from the broker. 
                            await receiver.CompleteAsync(message.SystemProperties.LockToken);
                        }
                    }
                    else
                    {
                        // If the message does not meet our processing criteria, we will deadletter it, meaning
                        // it is put into a special queue for handling defective messages. The broker will automatically
                        // deadletter the message, if delivery has been attempted too many times. 
                        await receiver.DeadLetterAsync(message.SystemProperties.LockToken);//, "ProcessingError", "Don't know what to do with this message");
                    }
                }
                catch (ServiceBusException e)
                {
                    if (!e.IsTransient)
                    {
                        // When any kind of messaging exception occurs and that exception is 
                        // not transient, meaning that things will not get better if we retry 
                        // the operation, then we "log" and rethrow for external handling. 
                        // Otherwise we'll absorb the exception (you might want to log it for 
                        // monitoring purposes) and keep going.
                        Console.WriteLine(e.Message);
                        throw;
                    }
                }
            }

            await receiver.CloseAsync();
        }
    }
}
