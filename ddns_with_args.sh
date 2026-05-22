#!/bin/bash
set -e

# Gets Cloudflare API stuff from .env
cd "$(dirname "$0")" || exit 1
source .env
# Argument stuff
IGNORE_IPV4=false
IGNORE_IPV6=false

while [[ $# -gt 0 ]]; do
  case "$1" in 
    --ignore-ipv4)
    IGNORE_IPV4=true
    shift
    ;;
    --ignore-ipv6)
    IGNORE_IPV6=true
    shift
    ;;
    *)
    echo "Unknown option: $1"
    exit 1
    ;;
  esac
done

if [[ "IGNORE_IPV4" == true && "IGNORE_IPV6" == true ]]; then
  echo "Both IP types are ignored, script will exit."
  exit 1
fi
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
curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=$1" -H "Authorization: Bearer $API_TOKEN"| jq -r --arg domain "$DOMAIN" '.result[] | select(.name==$domain) | .id'
}
RECORD_ID_V4=$(get_record "A")
RECORD_ID_V6=$(get_record "AAAA")
# exit if there are no records
if [[ -z "$RECORD_ID_V4" && -z "$RECORD_ID_V6" ]]; then
  echo -e "Couldn't find any Record IDs for $DOMAIN.\nCheck the DOMAIN entry in the .env or create an A and/or AAAA record in the Cloudflare Dashboard."
  exit 1
fi

update_record() {
local ip_version="$1"; local ip="$2"; local last_ip="$3"; local record_id="$4"; local ip_type="$5"; local ignore="$6"

if [[ "$ignore" == false ]]; then
  if [[ -n "$ip" ]]; then
    if [[ "$last_ip" != "$ip" ]]; then
      if [[ -n "$record_id" ]]; then
        RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$record_id"\
        -H "Authorization: Bearer $API_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"$ip_type\",\"name\":\"$DOMAIN\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":$PROXIED}")
        if echo "$RESPONSE" | grep -q "\"success\":true"; then
          sed -i "s/^LAST_$ip_version=.*/LAST_$ip_version=\"$ip\"/" .env
          echo "The $ip_version address ($ip) was updated on the domain $DOMAIN in Cloudflare succesfully."
        else
          echo "Can't update $ip_version!. Response: $RESPONSE"
        fi
        else
    echo -e "$ip_version Record ID for $DOMAIN couldn't be found.\nCheck the DOMAIN entry in the .env or create an $ip_type record in the Cloudflare Dashboard for that domain."
      fi
    else 
     echo "Same $ip_version as before ($ip), no need to update."
    fi
   else
    echo "Couldn't get $ip_version address."
    sed -i "s/^LAST_$ip_version=.*/LAST_$ip_version=\"$ip\"/" .env
  fi
fi
}
update_record "IPV4" "$IPV4" "$LAST_IPV4" "$RECORD_ID_V4" "A" "$IGNORE_IPV4"
update_record "IPV6" "$IPV6" "$LAST_IPV6" "$RECORD_ID_V6" "AAAA" "$IGNORE_IPV6"
