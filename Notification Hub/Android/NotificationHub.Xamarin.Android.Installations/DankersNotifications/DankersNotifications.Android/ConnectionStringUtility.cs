using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Android.App;
using Android.Content;
using Android.OS;
using Android.Runtime;
using Android.Views;
using Android.Widget;
using System.Security.Cryptography;
using System.Text;
using System.Globalization;
using System.Web;

namespace DankersNotifications.Droid
{
    public  class ConnectionStringUtility
    {
        public string Endpoint { get; private set; }
        public string SasKeyName { get; private set; }
        public string SasKeyValue { get; private set; }

        public ConnectionStringUtility(string connectionString)
        {
            //Parse Connectionstring
            char[] separator = { ';' };
            string[] parts = connectionString.Split(separator);
            for (int i = 0; i < parts.Length; i++)
            {
                if (parts[i].StartsWith("Endpoint"))
                    Endpoint = "https" + parts[i].Substring(11);
                if (parts[i].StartsWith("SharedAccessKeyName"))
                    SasKeyName = parts[i].Substring(20);
                if (parts[i].StartsWith("SharedAccessKey"))
                    SasKeyValue = parts[i].Substring(16);
            }
        }
        public string createToken(string resourceUri, string keyName, string key)
        {
            TimeSpan sinceEpoch = DateTime.UtcNow - new DateTime(1970, 1, 1);
            var week = 60 * 60 * 24 * 10;
            var expiry = Convert.ToString((int)sinceEpoch.TotalSeconds + week);
            string stringToSign = HttpUtility.UrlEncode(resourceUri) + "\n" + expiry;
            HMACSHA256 hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key));
            var signature = Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(stringToSign)));
            var sasToken = String.Format(CultureInfo.InvariantCulture, "SharedAccessSignature sr={0}&sig={1}&se={2}&skn={3}", HttpUtility.UrlEncode(resourceUri), HttpUtility.UrlEncode(signature), expiry, keyName);
            return sasToken;
        }
    }

   
}