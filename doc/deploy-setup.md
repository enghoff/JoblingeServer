# Setting up a deployment environment
## About this guide:

This document's purpose is to guide on how to setup a whole deployment environment for the Joblinge project.

## General dependencies
This tutorial assumes that the user has a *NIX machine with the following tools installed:
* git
* ruby 2.2.2
* ssh
* postgreSQL

The installation of these tools are out of this guide's scope. However, tutorials on how to set them up on your particular machine are easy to find online.


## Pulling the code
In order to deploy the application you need to pull the most up to date version of the code from the git-backed beanstalk repository. You need, of course, to have access to it first.

To clone the repository simply run:

```bash
git clone https://ranj.git.beanstalkapp.com/877_joblinge_backend.git
```

## Installing the gems
Once you have successfuly pulled the code `cd` into the rails directory

```
cd 877_joblinge_backend/
```

and install all the gems by running:

```
bundle install
```

## Capistrano
All the deployment is managed by Capistrano, a useful remote multi-server automation tool.

The configuration files for the deploy are located at

* `877_joblinge_backend/Capfile`
* `877_joblinge_backend/config/deploy.rb`
* `877_joblinge_backend/config/deploy/production.rb`

This configuration assumes:

* There is an entry on the ssh config file pointing to the joblinge server (see "Setting up ssh configuration")
* The joblinge server has been provisioned following the production setup instructions.
* The backend application assets are hosted at 'backend/assets' on the production server (see 'Backend path and assets' on the production setup instructions)
* The joblinge repository has an authorized `deployer` user, whose credentials are known to the person executing the deploy (there will be a password prompt). The code is hosted at `https://ranj.git.beanstalkapp.com/877_joblinge_backend.git`


## Setting up ssh configuration

This tutorial assumes that you are using a *NIX like machine and that you have a public/private key already and that they are called `id_rsa` and `id_rsa.pub`  and placed in `~/.ssh/`

If you need help generating your `id_rsa` keys check in the links below.

You start by editing your `~/.ssh/config` file and adding the following entry, changing the `HostName` and `User` to the appropiate values.

```
#http://www.picky-ricky.com/2009/01/ssh-keys-with-capistrano.html
ForwardAgent yes
# to prevent SSH connections timing out. This will poll the server every 60".
Host *
  ServerAliveInterval 500
  ServerAliveCountMax 30
  KeepAlive yes

Host joblinge
  HostName HOST_NAME
  User deployer
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile ~/.ssh/id_rsa
  IdentitiesOnly yes
```

Then we need to add your public key in the server. If your machine has the `ssh-copy-id` command available, just run

    ssh-copy-id deployer@HOST_NAME

If not, access the machine via ssh with your user, and copy-paste your `id_rsa.pub` in `~/.ssh/authorized_keys`. If this file does not yet exist, you can follow these steps:

```bash
cd ~/
mkdir .ssh
chmod 700 .ssh
cd .ssh
touch authorized_keys
chmod 600 authorized_keys
```

To copy-paste you `id_rsa.pub` you can follow these steps (replacing your username and IP where it corresponds), from your local machine:

```
cd ~/.ssh
scp id_rsa.pub deployer@HOST_NAME:~/mykey
ssh deployer@HOST_NAME
cd ~/
cat mykey >> .ssh/authorized_keys
rm mykey
```

Now you should be able to run `ssh joblinge`

**links**

* [Generating SSH Keys](https://help.github.com/articles/generating-ssh-keys/)

## Deploying

Now that you have the code, all the gems installed and your ssh properly configured, you are ready to use Capistrano.

First, `cd` into the rails directory

`cd 877_joblinge_backend`

and from here you will be able to run any Capistrano command.

With this line we deploy the latest version of the master branch

    bundle exec cap production deploy

You will be prompted for `git_https_username` and `git_https_password`. For the username you can leave the default: `deployer`, and you'll need to type the correct password that is not included in this document.

A complete list of commands can be listed by running: `bundle exec cap -T`
