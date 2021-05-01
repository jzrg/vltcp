#!/bin/sh

# Download and install xray
mkdir /tmp/xray
curl -L -H "Cache-Control: no-cache" -o /tmp/xray/xray.zip https://github.com/jzrg/vv/raw/main/Xray-linux-64.zip
unzip /tmp/xray/xray.zip -d /tmp/xray
install -m 755 /tmp/xray/xray /usr/local/bin/xray

# Remove temporary directory
rm -rf /tmp/xray

# xray new configuration
install -d /usr/local/etc/xray
cat << EOF > /usr/local/etc/xray/config.json
{
  "log" : {
    "access": "/var/log/v2ray/access.log",
    "error": "/var/log/v2ray/error.log",
    "loglevel": "warning"
  },
  "inbound": {
    "port": $PORT,
    "listen": "127.0.0.1",
    "protocol": "VLESS",
    "settings": {
      "clients": [
        {
          "id": "$UUID",
          "level": 1,
          "alterId": 64
        }
      ]
    },
   "streamSettings":{
      "network": "ws",
      "wsSettings": {
           "path": "/"
      }
   }
  },
  "outbound": {
    "protocol": "freedom",
    "settings": {}
  },
  "outboundDetour": [
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
  ],
  
  
	"inboundDetour":[
	   {
			"port": 443,
			"listen": "0.0.0.0",
			"protocol": "vless",
			"settings": {
			   "clients": [
				{
				  "id": "$UUID",
				  "alterId": 64
				}
			  ]
			},
			"streamSettings": {
			  "network": "tcp",
			  "tcpSettings": {
					"connectionReuse": true,
					"header": {
					  "type": "http",
					  "request": {
							"version": "1.1",
							"method": "GET",
							"path": ["/"],
							"headers": {
							  "Host": ["api-digital.maxis.com.my"], 
							  "User-Agent": [
									"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36",
													"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14A456 Safari/601.1.46"
							  ],
							  "Accept-Encoding": ["gzip, deflate"],
							  "Connection": ["keep-alive"],
							  "Pragma": "no-cache"
							}
					  },
					  "response": {
							"version": "1.1",
							"status": "200",
							"reason": "OK",
							"headers": {
							  "Content-Type": ["application/octet-stream", "application/x-msdownload", "text/html", "application/x-shockwave-flash"],
							  "Transfer-Encoding": ["chunked"],
							  "Connection": ["keep-alive"],
							  "Pragma": "no-cache"
							}
					  }
					}
			  }
			}
		}
	]
  
  
  
  "routing": {
    "strategy": "rules",
    "settings": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "127.0.0.0/8",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        }
      ]
    }
  }
}
EOF

# Run xray
/usr/local/bin/xray -config /usr/local/etc/xray/config.json
