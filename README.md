# Drupal 8
The preferred way to manage Drupal 8 sites is to use composer, and the Drupal Composer project helps integrate Drupal core with composer.

This repository provides a quick start wrapper around Drupal Composer and includes common configuration and recommended modules for Deeson Drupal 8 projects.

Quick-start projects use composer for dependency management, including Drupal core, contrib and 3rd party libraries. The contents of docroot/ should be considered expendable during development and can be recompiled from the contents of the repository.

We use [Docker](https://docs.docker.com/engine/installation/) and [Docker compose](https://docs.docker.com/compose/install/) for managing local development and this repository comes with some default configuration for working with Docker. You are of course free to use alternatives, but additional configuration may be required.

For drush to work with Docker, you'll need to add the following line to your `/etc/hosts` file:
127.0.0.1 docker.local

## Creating a new Drupal site

You do not need to clone this repo, our quick start is checked out using composer.

First you need to [install composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx).

Then you can create a new project using composer, keep the project name short and without punctuation (e.g. myproject)

```bash
composer create-project teamdeeson/d8-quickstart <project-name> --stability dev --no-interaction
```

You should now create a new git repository, and commit all files not excluded by the .gitignore file.

```bash
git init
git add .
git commit -m "Created the project."
```

### Required configuration
You should check through all of the services and settings files and make any required amendments. The following amendments need to be made at a minimum:

`.env:` Add your project name in here, use the same one as used with composer (e.g. myproject)

`src/settings/environment.inc:` Configure your domain names

`src/settings/01-core.settings.inc:` Configure a hash salt. See [http://drupalhashsalt.com/](http://drupalhashsalt.com/)

`src/settings/02-shield.settings.inc:` Configure basic-auth access details to protect your dev sites.

## Build and install
At Deeson we use Makefiles to orchestrate any additional tasks such as building dependencies and running tests.

This ensures we have a universal mechanism for task running across all of our projects.

The project can be built using the included Makefile.

```bash
make
```
will build the project based on the assumed environment. This will create the `docroot/` folder and build your website.

You can specify the environment explicitly with the ENVIRONMENT variable which will add or remove dev dependencies:

```bash
make build ENVIRONMENT=dev
```

```bash
make build ENVIRONMENT=prod
```

You can also safely remove your docroot at any point if you need to:

```bash
make clean
```

Once you have run the build for the first time, you can setup and run your Docker environment using the following command.

```
make docker-up
```

You should now be able to access a vanilla Drupal site at http://localhost

You can now run the Drupal installation, either through the interface or from the command line using:

```bash
make install
```
will install the site and associated configuration. You will be prompted to optionally perform a site install. If you proceed this will erase your existing site database.

You can stop the docker environment at any time using the command below:

```
make docker-down
```

Your site files and database will be stored outside of docker in the `.persist` hidden directory.

## Managing dependencies with composer
All of your dependencies should be managed through composer. This includes any off-the-shelf code such as Drupal core, contrib modules and themes, and any 3rd party libraries.

### To add a module (e.g. redirect):
```bash
composer require drupal/redirect
```

### To update a module (e.g. redirect):
```bash
composer update drupal/redirect
```

### To update Drupal core:
```bash
composer update drupal/core --with-dependencies
```

**You should commit your composer.lock file to the repository as this will guarantee that any subsequent builds will use the same exact version of all
your dependencies.**

For further details, see the Drupal Composer project documentation:

https://github.com/drupal-composer/drupal-project#composer-template-for-drupal-projects

Composer project usage guide:

https://getcomposer.org/doc/01-basic-usage.md

## XDebug

You need to run `sudo ifconfig lo0 alias 10.254.254.254` before xdebug connections will work. This is usually required each time you log-in to your development machine, but is safe to run periodically.

## Running tests

This repository contains the starting point for running both Behat and PHPUnit test suites as well as Drupal coding standards checks with PHPCS.

PHPUnit tests should be defined within you custom modules, in the tests/ sub-directory.

Behat tests should be defined in the behat-tests directory in the project root.

```bash
make test
```
will run all of the Project's automated tests.

## Project structure

### behat-tests/
This contains all of the Behat tests for your project.

### config/
This contains Drupal's CMI configuration files.

### docroot/
This directory contains compiled content and should not normally be committed to your repository.

### drush/
This contains your drush site aliases file(s).

### src/
This contains all of your project source code. As follows:

#### src/frontend/
For all your front end needs. This makes use of our front end setup, you can find out how here : https://github.com/teamdeeson/deeson-webpack-config

#### src/modules/
This is where you place your custom modules.

Anything within `src/modules/` will be made available in `docroot/modules/custom/`

#### src/services/
You can define your services YAML files here.

#### src/settings/
This contains the Drupal site settings, extracted from settings.php as per:
http://handbook.deeson.co.uk/development/drupal8/#settings-file-configuration

This has been moved from either sites/default/settings/ or sites/conf/ mentioned in the blog post.

settings.php will be made available in `docroot/sites/default/`. All other files will be included in-place by settings.php.

#### src/themes/
This is where you place your custom theme(s).

Anything within `src/themes/` will be made available in `docroot/themes/custom/`

##### src/themes/deeson_frontend_framework
The default hook up between drupal and src/frontend. Your theme can either inherit from this or follow the instructions from https://github.com/teamdeeson/deeson-webpack-config to do it yourself (its not tricky).

### scripts/
This is for any compilation or deployment scripts you may want to add.

These need to be included in your settings file in the usual way:

```php
$settings['container_yamls'][] = dirname(DRUPAL_ROOT) . '/src/services/development.services.yml';
```

### vendor/
This is the composer vendor directory, which contains project dependencies, tools and libraries. This should be excluded from your repository.

### web/
This and `docroot/` are symlinked to the same location for wider compatibility and should also be excluded from your repository.

# Helpful Docker commands

You can use the docker-compose tool as a shortcut for common docker commands. To run a command within one of the containers you can use:
```bash
docker-compose exec <container-name> <command>
```
For example to start a mysql client on the database container (mariadb) run:
```bash
docker-compose exec mariadb mysql
```

You can also use the more standard docker commands.

To list the active Docker instances run the following in the project root directory:

```bash
docker-compose ps
```

To get a bash terminal inside the PHP container you can use the following:

```bash
docker-compose exec php
```

To import an exported site database into the database container (if you don't have pv installed you can do so with `brew install pv`):

```bash
pv database_export_filename.sql | docker exec -i a7162120bee8 mysql -udrupal -pdrupal drupal
```
Replace the hash with the instance hash for the docker instance you want to get a terminal prompt for. You can find out that using the `docker ps` command to list active instances.

# Known issues

`ERROR: Network proxy declared as external, but could not be found. Please create the network manually using 'docker network create proxy' and try again.`

The project you are using is dependent on a traefik proxy which allows multiple docker sites to be run together. Instructions for adding and running the proxy (which must be started before you run make docker-start) can be found here: https://bitbucket.org/deesongroup6346/d4d-traefik-proxy
