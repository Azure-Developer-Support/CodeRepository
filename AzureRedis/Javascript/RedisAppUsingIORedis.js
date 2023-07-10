const Redis = require("ioredis");
const fs = require('fs');
const path = require('path');

const cluster = new Redis.Cluster([
    {
      port : 6380,
      host : "xxx—your-redis-cache-host-name—xxx"    }
  ],
  { 
    scaleReads: 'all', 
    slotsRefreshTimeout: 50000, 
    enableReadyCheck: true, 
    redisOptions: { 
      tls: {
        ca: fs.readFileSync(path.resolve("DigiCertGlobalRootG2.crt.pem")),
        rejectUnauthorized: false
      },
      password: "xxx—your-redis-cache-key—xxx"
    }, 
    lazyConnect: true,
    maxRetriesPerRequest: 3,
    retryStrategy(times) {
      const delay = Math.min(times * 50, 2000);
      return delay;
    },       
    reconnectOnError(err) {
      // try to reconnect only when the error contains "READONLY"
      const targetError = "READONLY";
      if (err.message.includes(targetError)) {
        return true; 
      }
    },                
  });

cluster.set("today", "application");
cluster.get("today", (err, res) => {
  console.log(res);
});
