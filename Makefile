ROOT_DIR=${PWD}
RUN_DESTRUCTIVE?=false
ENVIRONMENT?=vdd
DRUSH_ARGS?=-y --nocolor
DRUSH_CMD?=${ROOT_DIR}/vendor/bin/drush @$(ENVIRONMENT)
DRUSH?=${DRUSH_CMD} $(DRUSH_ARGS)
COMPOSER?=$(which composer)

# Build by default.
default: build

# Build for the current environment.
build: build-${ENVIRONMENT}

# Environment aliases.
build-vdd: build-local
build-dev: build-local

# Build dependencies for dev environments.
build-local:
	${COMPOSER} install
# Build dependencies for prod environment.
build-prod:
	${COMPOSER} install --no-dev --prefer-dist --ignore-platform-reqs

# Run automated tests
test:

# Run the tests on VDD.
test-local:

# Deploy to hosting. Builds prod dependencies first. Tests MUST pass.
deploy:	build-prod test
	if $(RUN_DESTRUCTIVE); then ./scripts/deploy.sh; else exit 1; fi

# Cleanup
clean:
	rm -Rf ./docroot ./vendor ./web

# Installation script
install: install-${ENVIRONMENT}
# Do nothing. Don't re-install prod.
install-prod:
# Local installation
install-vdd:
	cd docroot && ${DRUSH_CMD} site-install || echo 'Skipping site installation.'
	cd docroot && ${DRUSH} cim

# Do stuff to Drupal now it's in a live environment.
post-deploy:
	# No master yet :-( .
	cd docroot && $(DRUSH) cim sync
	cd docroot && $(DRUSH) updb
	cd docroot && $(DRUSH) cr
	cd docroot && $(DRUSH) cc css-js

