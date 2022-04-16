# subdomain-nginx
Bash script to create or delete a domain for nginx and basic php and nginx configuration
## How to use it
make the file executable, so it can be run from a terminal
```sh
chown +x subdomain.sh
```
Adding a domain
```sh
./subdomain.sh add mydomain.com
```
Removing a domain
```sh
./subdomain.sh remove mydomain.com
```
After removing domain it will ask if you also want to remove the files(located in /var/www/mydomain.com and its own folder)
## To use it globally
If you want to use it globally, move the script to your $PATH folder. To find your $PATH folder execute:
```sh
echo $PATH
```