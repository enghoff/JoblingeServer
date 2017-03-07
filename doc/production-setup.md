# Setting up a production machine for Joblinge


## About this guide:
This document's purpose is to guide on how to setup a whole production environment for the Joblinge project on a Ubuntu 14.04 Server.

## Hardware recommendations:
- At least 1GB of RAM
- At least 20GB of Disk
- Intel(R) Xeon(R) CPU 2.40GHz or superior.

## Add the deployer user
We'll add the `deployer` account to the group with sudo abilities.

    sudo adduser deployer
    sudo adduser deployer sudo
    su deployer

## Ensure the server has enough swap memory
Check if the system has enough swap avalaible (should be about twice the size of RAM) with

    sudo swapon -s

If there's not enough swap (it might have none), add it with

    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile

Verify it with sudo swapon -s

## Ruby/NodeJS
The first step is to install some dependencies for Ruby.

    sudo apt-get update
    sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libffi-dev

We also need NodeJS to compile assets, to install it now:

    curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
    sudo apt-get install -y nodejs

Next we're going to be installing Ruby using rbenv:

    cd
    git clone git://github.com/sstephenson/rbenv.git .rbenv
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    exec $SHELL

    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    exec $SHELL

    git clone https://github.com/sstephenson/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

    rbenv install 2.2.2
    rbenv global 2.2.2
    ruby -v

Add the rbenv-vars plugin to handle environment variables

    git clone https://github.com/rbenv/rbenv-vars.git $(rbenv root)/plugins/rbenv-vars

Now we tell Rubygems not to install the documentation for each package locally and then install Bundler

    echo "gem: --no-ri --no-rdoc" > ~/.gemrc
    gem install bundler

## Install Nginx and Passenger

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
    sudo apt-get install -y apt-transport-https ca-certificates

    # Add Passenger APT repository
    sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
    sudo apt-get update

    # Install Passenger & Nginx
    sudo apt-get install -y nginx-extras passenger


So now we have Nginx and passenger installed. We can manage the Nginx webserver by using the service command:

    sudo service nginx start

Open up the server's IP address in your browser to make sure that nginx is up and running.
The service command also provides some other methods such as restart and stop that allow you to easily restart and stop your webserver.

Next, we'll edit the nginx base configuration file. Besides these instrucctions, there's an example for this file at `doc/example_nginx/nginx.conf`.

    sudo vim /etc/nginx/nginx.conf

Here, find the lines corresponding to passenger, uncomment then and add the `deployer` path to passenger_ruby

    ##
    # Phusion Passenger config
    ##
    # Uncomment it if you installed passenger or passenger-enterprise
    ##

    passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
    passenger_ruby /home/deployer/.rbenv/shims/ruby;

Create the server configuration for joblinge (examples available at `doc/example_nginx/joblinge.conf` , `doc/example_nginx/joblinge_with_ssl.conf`)

    sudo vim /etc/nginx/sites-available/joblinge

and copy this inside:

    server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;
        # if there are multiple servers, add your host, such as joblinge.de;
        server_name localhost;

        add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";

        passenger_enabled on;
        rails_env    production;
        root         /home/deployer/joblinge/current/public;

        # redirect server error pages to the static page /50x.html
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }


Add this configuration to the list of enabled servers as a symlink and restart nginx:

    cd /etc/nginx/sites-enabled
    sudo rm default
    sudo ln -s ../sites-available/joblinge .
    sudo /etc/init.d/nginx restart

  To test for configuration syntax errors, run `sudo nginx -t`


## Setting up PostgreSQL

Postgres 9.3 is available in the Ubuntu repositories and we can install it like so:

    sudo apt-get install postgresql postgresql-contrib libpq-dev

Next we need to setup our postgres user: (in our example, we create the user `deployer`)

    sudo -u postgres createuser deployer -s
    sudo -u postgres psql

And we will set its password from the postgres console. The password you type in here will be the one to put in the .rbenv-vars file later on this guide.

    postgres=# \password deployer
    postgres=# \q


### Setting up SSL
It is recommended to setup SSL in Nginx too. You will need to have your SSL certificates and to refer to them from the `server` command inside of the `/etc/nginx/sites-enabled/joblinge` adding these lines:

    listen 443 default ssl;
    ssl_certificate     /etc/nginx/certificates/myssl.crt;
    ssl_certificate_key /etc/nginx/certificates/myssl.key;


## Configuring the application (first deploy)

At this point the main services on which the application depend on should be installed, up and running.

In this step you need to have correctly configured you deployment environment. Please refer to the appropriate (deployment) document for further instruction on how to do it if you haven't done it yet.

Now, we will deploy for the first time the application. However, it will not be able to run completely, but it will set up the appropriate folder structure in the server. See details of the deploy on the `deploy-setup.md` doc.

    bundle exec cap production deploy

Once it finishes, ssh into your production server and in the home directory of the deployer user you should find a new directory: `~/joblinge/shared`.
Here we will add our configuration files:

- /home/deployer/joblinge/shared/.rbenv-vars # See the *Environment Variables* section
- /home/deployer/joblinge/shared/config/settings.yml # See the *Game Settings*

After adding them, run `bundle exec cap production deploy` once more, it will still fail. Then go to the `/joblinge/releases/` folder and enter the directory containing the last deploy files (the name is similar to `20160516160347`). From there run

    bundle
    RAILS_ENV=production bundle exec rake db:create

This previous step is done to create the database. If the database was created by other means please skip it.

Once you have done it, deploy again:

    bundle exec cap production deploy

And everything should be working.


### Environment Variables (includes MAIL SERVER configuration)

add the following variables to a `.rbenv-vars` file at `/home/deployer/joblinge/shared`

    cd /home/deployer/joblinge/shared
    vim .rbenv-vars

    JOBLINGE_DB_NAME=
    JOBLINGE_DB_USERNAME=
    JOBLINGE_DB_PASSWORD=
    SECRET_KEY_BASE=

    JOBLINGE_HOST=
    JOBLINGE_EMAIL_ADDRESS=
    JOBLINGE_EMAIL_PORT=
    JOBLINGE_EMAIL_AUTHENTICATION=
    JOBLINGE_EMAIL_DOMAIN=
    JOBLINGE_EMAIL_USER=
    JOBLINGE_EMAIL_PASSWORD=
    JOBLINGE_EMAIL_DEFAULT_FROM=


* On `JOBLINGE_DB_PASSWORD`, add the password entered when configuring postgreSQL
* The `SECRET_KEY_BASE` is used to verify the integrity of signed cookies. Make sure the secret is at least 30 characters and all random, no regular words or you'll be exposed to dictionary attacks. Please add a reasonably long hash such as `b9aab28c21c3cd713b96027df51a10a3b26b2a02aa4c51521ec8d0a219044749b5f68821d6d1130253c9537094252ddaa06ca89844053453f0a8f8b44fd896ba`
* `JOBLINGE_HOSTED_ON_DOMAIN` is the domain of the server.
* `JOBLINGE_EMAIL_HOST`, etc. correspond to the mail server configuration.

### Game Settings

Edit the game settings configuration file

    cd /home/deployer/joblinge/shared/config
    vim settings.yml

Add the settings following the example from `config/settings.example.yml`

## Security measures:

### Strict-Transport-Security HTTP (HSTS)

1. open nginx server configuration (`/etc/nginx/sites-enabled/joblinge`)
2. search for the `server` block that listens to SSL, should look similar to this:
```
server {
#...
listen 443 ssl;
#...
}
```
3. add the following line: `add_header Strict-Transport-Security "max-age=31536000; includeSubdomains";`
4. finally restart nginx via:
```
sudo service nginx restart
```
or alternatively
```
sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start
```

However industry best practices indicate that it is better to not include this header in normal HTTP requests.
If your configuration presents a single `server` block with both `listen 80;` and `listen 443 ssl;` commands you should stop listening port 80 and create a redirection.

To do this start by removing the `listen 80;` command from your `server` block. Then you above your `server` block we will create a new one that should look like this:

```
server {
  listen 80;
  server_name localhost;
  return 301 https://$host$request_uri;
}
```

Make sure to use the same `server_name` as the one you had before.



**links**

* [Setting up HSTS in nginx](https://scotthelme.co.uk/setting-up-hsts-in-nginx/)

### Hide Technical Information in Web Banners

1. open nginx server configuration (`/etc/nginx/nginx.conf`)
2. search for the `http {`
3. add the following line inside: `more_clear_headers X-Powered-By Server;`
4. finally restart nginx via:
```
sudo service nginx restart
```
or alternatively
```
sudo /etc/init.d/nginx stop
sudo /etc/init.d/nginx start
```

**links**

* [NginxHttpHeadersMoreModule#more_clear_headers](http://wiki.nginx.org/NginxHttpHeadersMoreModule#more_clear_headers)
