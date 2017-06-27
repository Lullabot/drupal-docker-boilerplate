<?php 
/**
 * @file
 * Site aliases for Docker site.
 */
/**
 * The Docker container
 */
$aliases['container'] = array (
  'root' => '/var/www/html/web',
  'uri' => $_SERVER['COMPOSE_PROJECT_NAME'] . '.docker.localhost:8000',
  'path-aliases' => array(
    '%private' => '/var/www/private/files/private',
  ),
);

/**
 * The source for Docker db and files.
 *
 * Fill out information here about a site that will serve to supply the db
 * and files that will be used in this Docker container.
 */
$aliases['source'] = array (
  'root' => '/var/www/example.com/web',
  'uri' => 'http://example.com',
  'remote-host' => 'example.com',
  'path-aliases' => array(
    '%private' => '/var/www/example.com/private/files',
  ),
);
