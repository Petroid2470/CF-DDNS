# fun-modifications

This branch has some modifications i made to the script for fun, like reducing the number of lines (or making it *technically* a one-liner).

**ddns_old.sh** is the original DDNS script, **ddns.sh** is the one with lower line count (and a bit unreadable), **ddns_1l.sh** is me making it a one-liner for the funny, and **ddns_with_args.sh** has arguments to skip IPv4 or IPv6 if needed.

Treat this branch as experimental and non-functional. If you really want something that works, just use the main branch


---

# CF-DDNS

Simple DDNS script using Cloudflare API to update a domain's IPv4 and IPv6 addresses.

## How to use

- Download the ddns script (ddns.sh)

- Download .env.example and rename it to .env (in the same folder)

- Edit the .env with the values that are required

- Run ```chmod +x ddns.sh``` to make the script executable

- Run the script

---


Recommended: Add the script to your cron jobs for automatic updating.


## Helpful information

How to get API token: [Cloudflare Documentation](https://developers.cloudflare.com/fundamentals/api/get-started/create-token/)

How to get Account and Zone ID: [Cloudflare Documentation](https://developers.cloudflare.com/fundamentals/account/find-account-and-zone-ids/)
