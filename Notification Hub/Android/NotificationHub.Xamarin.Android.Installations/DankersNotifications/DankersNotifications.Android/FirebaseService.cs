using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using Android.App;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Support.V4.App;
using Android.Views;
using Android.Widget;
using Firebase.Iid;
using Firebase.Messaging;
using Newtonsoft.Json;
using WindowsAzure.Messaging;
using Xamarin.Forms;

namespace DankersNotifications.Droid
{
    //[Service(Name = "{PackageName}.MyFirebaseMessagingServiceClassName")]
    [Service(Name = "com.sample.notificationhubsample.FirebaseService")]
    [IntentFilter(new[] { "com.google.firebase.MESSAGING_EVENT" })]

    public class FirebaseService : FirebaseMessagingService
    {
        public static string FCMTemplateBody { get; set; } = "{\"data\":{\"message\":\"$(messageParam)\"}}";
        public static string NotificationHubName { get; set; } = "{Notification Hub Name}";
        public static string ListenConnectionString { get; set; } = "{Your NH connection string}";
        public static string[] SubscriptionTags { get; set; } = { "default" };
        public static string CHANNEL_ID = "my_channel_01";
        public static string name = "Yogs Notification";
        public static string NotificationName = "Yogs Software";

        //public  void OnTokenRefresh()
        // {
        //    var token = FirebaseInstanceId.Instance.Token;
        //    SendRegistrationToServer(token);
        // }
        public async override void OnNewToken(string token)
        {
            base.OnNewToken(token);
            Console.WriteLine("NEW_TOKEN", token);
             await SendRegistrationToServer(token);
        }

        public async Task<HttpStatusCode> SendRegistrationToServer(string token)
        {
            ConnectionStringUtility connectionSaSUtil = new ConnectionStringUtility(ListenConnectionString);

            DeviceInstallation deviceInstallation = new DeviceInstallation();
            deviceInstallation.installationId = "demo123";
            deviceInstallation.pushChannel = token;
            deviceInstallation.platform = "GCM";
            deviceInstallation.tags = SubscriptionTags;

            string hubResource = "installations/" + deviceInstallation.installationId + "?";
            string apiVersion = "api-version=2015-04";

            // Determine the targetUri that we will sign
            string uri = connectionSaSUtil.Endpoint + NotificationHubName + "/" + hubResource + apiVersion;

            //=== Generate SaS Security Token for Authorization header ===
            // See https://msdn.microsoft.com/library/azure/dn495627.aspx
            string SasToken = connectionSaSUtil.createToken(connectionSaSUtil.Endpoint, connectionSaSUtil.SasKeyName, connectionSaSUtil.SasKeyValue);

            using (var httpClient = new HttpClient())
            {
                string json = JsonConvert.SerializeObject(deviceInstallation);

                httpClient.DefaultRequestHeaders.Add("Authorization", SasToken);

                var response = await httpClient.PutAsync(uri, new StringContent(json, System.Text.Encoding.UTF8, "application/json"));
                return response.StatusCode;
            }
        }

        public override void OnMessageReceived(RemoteMessage message)
        {
            base.OnMessageReceived(message);
            string messageBody = string.Empty;
            if (message.GetNotification() != null)
            {
                messageBody = message.GetNotification().Body;
            }
            else
            {
                messageBody = message.Data.Values.First();
            }
            try
            {
                MessagingCenter.Send(messageBody, "Update");
            }
            catch (Exception e)
            { }
            SendLocalNotification(messageBody);
        }

        void SendLocalNotification(string body)
        {

            var intent = new Intent(this, typeof(MainActivity));
            var pendingIntent = PendingIntent.GetActivity(this, 0, intent, PendingIntentFlags.OneShot);
            //var notificationManager = (NotificationManager)GetSystemService(NotificationService);
            if (Build.VERSION.SdkInt < BuildVersionCodes.O)
            {
                // Notification channels are new in API 26 (and not a part of the
                // support library). There is no need to create a notification
                // channel on older versions of Android.
                return;
            }
            var notificationBuilder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .SetContentTitle(NotificationName)
                .SetSmallIcon(Resource.Drawable.ic_launcher)
                .SetContentText(body)
                .SetAutoCancel(true)
                .SetShowWhen(false)
                .SetContentIntent(pendingIntent);
            var notificationManager = NotificationManager.FromContext(this);
            notificationManager.Notify(0, notificationBuilder.Build());
        }

    }

    public class DeviceInstallation
    {
        public string installationId { get; set; }
        public string platform { get; set; }
        public string pushChannel { get; set; }
        public string[] tags { get; set; }
    }
}

    