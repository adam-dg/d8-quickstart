# Drupal 8
The preferred way to manage Drupal 8 sites is to use composer, and the Drupal Composer project helps integrate Drupal core with composer.

This repository provides a quick start wrapper around Drupal Composer and includes common configuration and recommended modules for Deeson Drupal 8 projects.

Quick-start projects use composer for dependency management, including Drupal core, contrib and 3rd party libraries. The contents of docroot/ should be considered expendable during development and can be recompiled from the contents of the repository.

We use [vdd](http://handbook.deeson.co.uk/development/vdd/) for managing local development and this repository comes with some default configuration for working with VDD. You are of course free to use alternatives, but additional configuration may be required.

## Creating a new Drupal site

First you need to [install composer](https://getcomposer.org/doc/00-intro.md#installation-linux-unix-osx).

Then you can create a new project using composer:

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

`src/settings/settings.php:` Configure your domain names and VDD location

`src/settings/01-core.settings.inc:` Configure a hash salt.

`src/settings/02-shield.settings.inc:` Configure basic-auth access details to protect your dev sites.

`drush/example.site.aliases.drushrc.php:` Create a site.aliases.drushrc.php from the example provided and configure your local environment.

`behat.yml` Configure your vdd URL

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

Once you have run the build, you can run the Drupal installation:

```bash
make install
```
will install the site and associated configuration. You will be prompted to optionally perform a site install. If you proceed this will erase your existing site database.

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
If you are using a different toolset for your front-end components this is where it should be. We use NPM and Gulp to compile our SCSS and Javascript, and to generate fonts and icon-sets.

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