# environment-helpers

This repository implements utilities to support the implementation or adoption of scripts for your projects, such us environment initialization, checkers and more.

## API

The helpers available are for:

- Brew
- Git
- Git Flow
- Meteor
- Meteor m (mongo manager)
- Meteor yarn

All these groups contain the next kind of helpers:

- `setup[PROGRAM]` to install the program, any other dependency and configure

- `purge[PROGRAM]` to uninstall the program, any other dependency and remove the configurations

- `check[PROGRAM]` to just check the program setup

- `install[PROGRAM]` to just install program

- `uninstall[PROGRAM]` to just uninstall program

- `config[PROGRAM]` to just configure program

### Git Flow

Parameters: 

bugfix, feature, release, hotfix, support, versiontag, master, develop - Git Flow names configuration

### Meteor m

Parameters: 

version - Mongo version to install/config/use/remove

mongoConf - Path to the mongo configuration file

dbpath - Path to the folder where the data is stored

logpath - Path to the file where the logs are stored
