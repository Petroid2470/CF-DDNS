#!/bin/bash
set -e
# Gets Cloudflare API stuff from .env
cd "$(dirname "$0")" || exit 1
source .env
# Gets the IP with IPify, any other service will do if you want to change it
IPV4=$(curl -s http://api.ipify.org || true)
IPV6=$(curl -s http://api6.ipify.org || true)
# If cant find neither of the IPs, exit
if [[ -z "$IPV4" && -z "$IPV6" ]]; then
  echo "Can't find any IP, script will exit."
  exit 1
fi

# Get record IDs with the domain
get_record() {
curl -s "https://api.cloudflare.com/client/v4/zones/$1/dns_records?type=$2" -H "Authorization: Bearer $API_TOKEN"| jq -r --arg domain "$DOMAIN" '.result[] | select(.name==$domain) | .id'
}
RECORD_ID_V4=$(get_record $ZONE_ID "A")
RECORD_ID_V6=$(get_record $ZONE_ID "AAAA")

if [[ -z "$RECORD_ID_V4" && -z "$RECORD_ID_V6" ]]; then
  echo -e "Couldn't find any Record IDs for $DOMAIN.\nCheck the DOMAIN entry in the .env or create an A and/or AAAA record in the Cloudflare Dashboard."
  exit 1
fi

update_record() {
 if [[ -n "$2" ]]; then
  if [[ "$3" != "$2" ]]; then
    if [[ -n "$5" ]]; then
      RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$6/dns_records/$5"\
      -H "Authorization: Bearer $4" \
      -H "Content-Type: application/json" \
      --data "{\"type\":\"$9\",\"name\":\"$7\",\"content\":\"$2\",\"ttl\":1,\"proxied\":$8}")
      if echo "$RESPONSE" | grep -q "\"success\":true"; then
        sed -i "s/^LAST_$1=.*/LAST_$1=\"$2\"/" .env
        echo "The $1 address ($2) was updated on the domain $7 in Cloudflare succesfully."
      else
        echo "Can't update $1!. Response: $RESPONSE"
      fi
      else
  echo "$1 Record ID for $7 couldn't be found. Check the DOMAIN entry in the .env or create an $9 record in the Cloudflare Dashboard for that domain."
    fi
  else 
   echo "Same $1 as before ($2), no need to update."
  fi
 else
  echo "Couldn't get $1 address."
  sed -i "s/^LAST_$1=.*/LAST_$1=\"$2\"/" .env
fi

}
update_record "IPV4" "$IPV4" "$LAST_IPV4" "$API_TOKEN" "$RECORD_ID_V4" "$ZONE_ID" "$DOMAIN" "$PROXIED" "A"
update_record "IPV6" "$IPV6" "$LAST_IPV6" "$API_TOKEN" "$RECORD_ID_V6" "$ZONE_ID" "$DOMAIN" "$PROXIED" "AAAA"
