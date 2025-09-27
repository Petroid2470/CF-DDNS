#!/bin/bash
set -e
# Gets Cloudflare API stuff from .env
source .env

# Gets the IP with IPify, any other service will do if you want to change it
IPV4=$(curl -s http://api.ipify.org || true)
IPV6=$(curl -s http://api6.ipify.org || true)
# If cant find neither of the IPs, exit
if [[ -z "$IPV4" && -z "$IPV6" ]]; then
  echo "Can't find any IP, script will exit."
  exit 1
fi

# Get record IDs for IPv4 and IPv6 with the domain
RECORD_ID_V4=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=a" \
  -H "Authorization: Bearer $API_TOKEN" | jq -r --arg domain "$DOMAIN" '.result[] | select(.name==$domain) | .id')

RECORD_ID_V6=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=aaaa" \
  -H "Authorization: Bearer $API_TOKEN" | jq -r --arg domain "$DOMAIN" '.result[] | select(.name==$domain) | .id')

# If cant find neither of the Record IDs, exit
if [[ -z "$RECORD_ID_V4" && -z "$RECORD_ID_V6" ]]; then
  echo "Couldn't find any Record IDs for $DOMAIN. Check the DOMAIN entry in the .env or create an A or AAAA record in the Cloudflare Dashboard."
  exit 1
fi
#IPv4 Update
 if [[ -n "$IPV4" ]]; then
  if [[ "$LAST_IPV4" != "$IPV4" ]]; then
    if [[ -n "$RECORD_ID_V4" ]]; then
      RESPONSE_IPV4=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID_V4"\
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$IPV4\",\"ttl\":1,\"proxied\":$PROXIED}")
      if echo "$RESPONSE_IPV4" | grep -q "\"success\":true"; then
        sed -i "s/^LAST_IPV4=.*/LAST_IPV4=\"$IPV4\"/" .env
        echo "The IPv4 address ($IPV4) was updated on the domain $DOMAIN in Cloudflare succesfully."
      else
        echo "Can't update IPv4!. Response: $RESPONSE_IPV4"
      fi
      else
  echo "IPv4 Record ID for $DOMAIN couldn't be found. Check the DOMAIN entry in the .env or create an A record in the Cloudflare Dashboard for that domain."
    fi
  else 
   echo "Same IPv4 as before ($IPV4), no need to update."
  fi
 else
  echo "Couldn't get IPv4 address."
  sed -i "s/^LAST_IPV6=.*/LAST_IPV6=\"$IPV6\"/" .env
fi


#IPv6 update
 if [[ -n "$IPV6" ]]; then
  if [[ "$LAST_IPV6" != "$IPV6" ]]; then
    if [[ -n "$RECORD_ID_V6" ]]; then
      RESPONSE_IPV6=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID_V6"\
      -H "Authorization: Bearer $API_TOKEN" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"AAAA\",\"name\":\"$DOMAIN\",\"content\":\"$IPV6\",\"ttl\":1,\"proxied\":$PROXIED}")
      if echo "$RESPONSE_IPV6" | grep -q "\"success\":true"; then
        sed -i "s/^LAST_IPV6=.*/LAST_IPV6=\"$IPV6\"/" .env
        echo "The IPv6 address ($IPV6) was updated on the domain $DOMAIN in Cloudflare succesfully."
      else
        echo "Can't update IPv6!. Response: $RESPONSE_IPV6"
      fi
      else
  echo "IPv6 Record ID for $DOMAIN couldn't be found. Check the DOMAIN entry in the .env or create an AAAA record in the Cloudflare Dashboard for that domain."
    fi
  else 
   echo "Same IPv6 as before ($IPV6), no need to update."
  fi
 else
  echo "Couldn't get IPv6 address."
  sed -i "s/^LAST_IPV6=.*/LAST_IPV6=\"$IPV6\"/" .env
fi

# Im the god of spaghetti code and nested if statements
# Its not good but it works
# --Petroid