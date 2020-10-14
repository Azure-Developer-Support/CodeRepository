using Microsoft.Azure.ServiceBus;
using Microsoft.Extensions.Configuration;
using Microsoft.ServiceFabric.Actors;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsumerService
{
    public class Helper
    {
        private static readonly string connectionString = string.Empty;
        private static readonly Lazy<QueueClient> queueClient = null;
        private static Message message = null;

        static Helper()
        {
            // Get config settings from AppSettings
            IConfigurationBuilder builder = new ConfigurationBuilder().AddJsonFile("appsettings.json")
                                                                    .AddJsonFile("appsettings.Development.json");
            IConfigurationRoot configuration = builder.Build();

            // read the ServiceBus connection string
            connectionString = configuration["SBConnectionString"];

            // initialize SB QueueClient object
            queueClient = new Lazy<QueueClient>(
                () => new QueueClient(connectionString, "applogs")
            );
            message = new Message
            {
                ContentType = "text/plain"
            };
        }

        public static async Task LogMessage(string label, string rawMessage)
        {
            message.Label = label;
            message.Body = Encoding.UTF8.GetBytes(rawMessage);

            await queueClient.Value.SendAsync(message)
                            .ConfigureAwait(false);
        }
    }
}
