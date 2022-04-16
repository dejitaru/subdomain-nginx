#!/bin/bash
#
# Bash script for subdomain in nginx

#Variables
NGINX_SITES_AVAILABLE='/etc/nginx/sites-available'
NGINX_SITES_ENABLED='/etc/nginx/sites-enabled'
WEB_PATH='/var/www'
MY_EMAIL='ventas@silo13.com'

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() { echo -e '\e[1;31m'$1'\e[m'; exit 1; }

add() {
    ok "adding  $1"
    # Create the Nginx config file.
    cat > $NGINX_SITES_AVAILABLE/$1 <<EOF
    server {
        server_name $2;
        root        $WEB_PATH/$1/public_html;

        # Logs
        access_log $WEB_PATH/$1/logs/access.log;
        error_log  $WEB_PATH/$1/logs/error.log;

        index index.php index.html index.htm;
        client_max_body_size 12M;

        location / {
            try_files \$uri \$uri/ /index.html;
        }
        location ~ \.php$ {
            try_files \$uri =404;
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
    mkdir -p $WEB_PATH/$1/{public_html,logs}
    # Create index.html file.
    cat > $WEB_PATH/$1/public_html/index.html <<EOF
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <title>$1</title>
        <meta charset="utf-8" />
    </head>
    <body>
        <h1>subdomain $1<h1>
        <p>$(date +%Y)</p>
    </body>
    </html>
EOF

    # Change the folder permissions
    chown -R $USER:$WEB_USER $WEB_PATH/$1

    # symbolic link to enable site
    ln -s $NGINX_SITES_AVAILABLE/$1 $NGINX_SITES_ENABLED/$1

    # Restart the Nginx server to apply.
    read -p "Restart nginx to apply changes? (y/n): " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
    /etc/init.d/nginx restart;
    fi
}

remove() {
    ok "removing  $1"
    rm $NGINX_SITES_ENABLED/$1
    rm $NGINX_SITES_AVAILABLE/$1

    read -p "Remove files (y/n): " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]; then
      rm -rf $WEB_PATH/$1/
    fi

    # Restart the Nginx server to apply.
    read -p "Restart nginx to apply changes? (y/n): " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
    /etc/init.d/nginx restart;
    fi
}

# Sanity check.
[ $(id -g) != "0" ] && die "Script must be running as root."
if [ "$1" == "add" ]; then
 add $2
elif [ "$1" == "remove" ]; then
 remove $2
else
 die "add or remove required"
fi
ok "completed"