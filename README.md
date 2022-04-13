# subdomain-nginx
Bash script to create a subdomain for nginx and basic php and nginx configuration
## How to use it
make the file executable, so it can be run from a terminal
```sh
chown +x subdomain.sh
```
Use it passing 2 arguments, subdomain and domain like this:
```sh
./subdomain.sh mysubdomain mydomain.com
```
this will create mysubdomain.mydomain.com
