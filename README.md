# CF-DDNS

Simple DDNS script using Cloudflare API to update a domain's IPv4 and IPv6 addresses.

## How to use

Download the ddns script (ddns.sh), download .env.example and rename it to .env (in the same folder)
Run ```chmod +x ddns.sh``` to make the script executable
Run the script

Reccomended: Add the script to your cronjobs for automatic updating.

## Helpful information

How to get API token: [Cloudflare Documentation](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)
How to get Account and Zone ID: [Cloudflare Documentation](https://developers.cloudflare.com/fundamentals/account/find-account-and-zone-ids/)
