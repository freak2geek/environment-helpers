# scripts

This repository implements utilities to support the implementation or adoption of scripts for your projects, such us environment initialization, checkers and more.

## Usage

Import and use the helpers by running the next command in your shell scripts.

``` bash
source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/freak2geek/scripts/master/dist/index.sh)"
```

## API

The helpers available are for:

- Brew
- Dnsmasq
- Docker
- Git
- Git Flow
- Meteor
- Meteor lerna
- Meteor m (mongo manager)
- Meteor yarn
- sudo nopasswd
- Zsh

All these groups contain the next kind of helpers:

- `setup[PROGRAM]` to install the program, any other dependency and configure

- `purge[PROGRAM]` to uninstall the program, any other dependency and remove the configurations

- `check[PROGRAM]` to just check the program setup

- `install[PROGRAM]` to just install program

- `uninstall[PROGRAM]` to just uninstall program

- `config[PROGRAM]` to just configure program

### Dnsmasq

- DNSMASQ_DOMAIN - `["dev"]`
- DNSMASQ_HOST - `["127.0.0.1"]`

### Git Flow

Variables: 

Git Flow names configuration
- GITFLOW_BUGFIX - `["bugfix/"]`
- GITFLOW_FEATURE - `["feature/"]`
- GITFLOW_RELEASE - `["release/"]`
- GITFLOW_HOTFIX - `["hotfix/"]`
- GITFLOW_SUPPORT - `["support/"]`
- GITFLOW_VERSIONTAG - `[""]`
- GITFLOW_MASTER - `["master"]`
- GITFLOW_DEVELOP - `["develop"]`

### Meteor m

Variables: 

- MONGO_VERSION - The mongo version - `["stable"]`
- MONGO_CONF - Path to the mongo configuration file - `["/etc/mongodb.conf"]`
- MONGO_DBPATH - Path to the folder where the data is stored - `["/data/db"]`
- MONGO_LOGPATH - Path to the file where the logs are stored - `["/var/log/mongod.log"]`
- MONGO_PORT - Port to use for the master instance - `[27017]`
- MONGO_REPLICA - Name of the replica set - `["rs0"]`
- MONGO_R1_DBPATH - Path to the folder where the replica one data is stored - `["/data/db-rs0-0"]`
- MONGO_R2_DBPATH - Path to the folder where the replica two data is stored - `["/data/db-rs0-1"]`
- MONGO_R1_LOGPATH - Path to the file where the logs of the replica one are stored - `["/var/log/mongod-rs0-0.log"]`
- MONGO_R2_LOGPATH - Path to the file where the logs of the replica two are stored - `["/var/log/mongod-rs0-1.log"]`
- MONGO_R1_PORT - Port to use for the R1 instance - `[27018]`
- MONGO_R2_PORT - Port to use for the R2 instance - `[27019]`

## Contribute

- Implement helpers as modules within the `src` folder

- Build the distribution script by running `./build.sh`
