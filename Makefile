all: update

update:
	cd docroot \
		&& drush updb -y
