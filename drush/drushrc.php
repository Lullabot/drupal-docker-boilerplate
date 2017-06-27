<?php

/**
 * Custom aliases.
 */
$options['shell-aliases']['syncfiles'] = '--verbose --yes rsync @docker.source:%files/ @docker.container:%files';
$options['shell-aliases']['syncprivate'] = '--verbose --yes rsync @docker.source:%private/ @docker.container:%private';
$options['shell-aliases']['syncdb'] = '--verbose --yes sql-sync @docker.source @docker.container --create-db';
