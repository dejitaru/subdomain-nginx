#!/bin/bash
#
# Bash script for subdomain in nginx

#Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

#Variables
NGINX_SITES_AVAILABLE='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
WEB_PATH='/var/www'

# Sanity check.
[ $(id -g) != "0" ] && die "Script must be running as root."
[ $# != "2" ] && die "Usage: $(basename $0) subDomainName mainDomainName"

ok "Creating the config files for your subdomain."

# Create the Nginx config file.
cat > $NGINX_SITES_AVAILABLE/$1 <<EOF
server {
    server_name $1.$2;
    root        $WEB_PATH/$1.$2/public_html;

    # Logs
    access_log $WEB_PATH/$1.$2/logs/access.log;
    error_log  $WEB_PATH/$1.$2/logs/error.log;

    index index.php index.html index.htm;
    client_max_body_size 12M;

    location / {
        try_files $uri $uri/ /index.html;
    }
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
        fastcgi_index index.php;
        include fastcgi.conf;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }

}
EOF

# Create {public,log} directories.
mkdir -p $WEB_PATH/$1.$2/{public_html,logs}

# Create index.html file.
cat > $WEB_PATH/$1.$2/public_html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <title>$1.$2</title>
    <meta charset="utf-8" />
</head>
<body>
    <h1>subdomain $1.$2<h1>
    <p>$(date +%Y)</p>
</body>
</html>
EOF

# Change the folder permissions
chown -R $USER:$WEB_USER $WEB_PATH/$1.$2

# symbolic link to enable site
ln -s $NGINX_SITES_AVAILABLE/$1.$2 $NGINX_SITES_ENABLED/$1.$2

# Restart the Nginx server to apply.
read -p "Restart nginx to apply changes? (y/n): " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  /etc/init.d/nginx restart;
fi

ok "Subdomain created $1.$2."