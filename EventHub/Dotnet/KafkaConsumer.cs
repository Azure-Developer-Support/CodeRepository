//DISCLAIMER
//The sample scripts are not supported under any Microsoft standard support program or service. The sample scripts are provided AS IS without warranty of any kind. 
//Microsoft further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
//The entire risk arising out of the use or performance of the sample scripts and documentation remains with you. In no event shall Microsoft, its authors, 
//owners of this repository or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever (including, without limitation,
//damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or inability 
//to use the sample scripts or documentation, even if Microsoft has been advised of the possibility of such damages.


using System;
using Confluent.Kafka;

class Program
{
    static void Main(string[] args)
    {
        var config = new ConsumerConfig
        {
            BootstrapServers = "<eventhub-namespace>.servicebus.windows.net:9093",
            SecurityProtocol = SecurityProtocol.SaslSsl,
            SaslMechanism = SaslMechanism.Plain,
            SaslUsername = "$ConnectionString",
            SaslPassword = "<connection-string>",
            // SslCaLocation = "/etc/ssl/certs/ca-certificates.crt", // Path to trusted root certificate file
            GroupId = "<consumer-group-name>",
            AutoOffsetReset = AutoOffsetReset.Earliest,
            // You can set other consumer properties here if needed  https://github.com/confluentinc/librdkafka/blob/master/CONFIGURATION.md
        };

        var topic = "<eventhub-name>";
        using (var consumer = new ConsumerBuilder<Ignore, string>(config).Build())
        {
            consumer.Subscribe(topic);

            while (true)
            {
                var result = consumer.Consume();
                Console.WriteLine($"Received message: {result.Message.Value}");
            }
        }
    }
}
