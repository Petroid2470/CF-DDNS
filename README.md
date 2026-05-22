# CF-DDNS

Simple DDNS script using Cloudflare API to update a domain's IPv4 and IPv6 addresses.

## How to use

- Install `jq` and `curl`

- Download the ddns script (ddns.sh)

- Download .env.example and rename it to .env (in the same folder)

- Edit the .env with the values that are required

- Run ```chmod +x ddns.sh``` to make the script executable

- Run the script

- (Optional): Add `--ignore-ipv4` or `--ignore-ipv6` to bypass updating that record type.

---


Recommended: Add the script to your cron jobs for automatic updating.


## Helpful information

How to get API token: [Cloudflare Documentation](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

How to get Account and Zone ID: [Cloudflare Documentation](https://developers.cloudflare.com/fundamentals/account/find-account-and-zone-ids/)
