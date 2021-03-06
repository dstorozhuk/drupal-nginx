#!/usr/bin/env bash

set -e

if [[ -n "${DEBUG}" ]]; then
  set -x
fi

nginxExec() {
    docker-compose -f test/docker-compose.yml exec --user=82 nginx "${@}"
}

docker-compose -f test/docker-compose.yml up -d

nginxExec make check-ready -f /usr/local/bin/actions.mk

echo "Checking Drupal endpoints"
echo -n "Checking / page... "
nginxExec curl -I "localhost" | grep '302 Found'
echo -n "authorize.php...   "
nginxExec curl -I "localhost/authorize.php" | grep '302 Found'
echo -n "cron.php...        "
nginxExec curl -I "localhost/cron.php" | grep '302 Found'
echo -n "index.php...       "
nginxExec curl -I "localhost/index.php" | grep '302 Found'
echo -n "install.php...     "
nginxExec curl -I "localhost/install.php" | grep '200 OK'
echo -n "update.php...      "
nginxExec curl -I "localhost/update.php" | grep '302 Found'
echo -n "xmlrpc.php...      "
nginxExec curl -I "localhost/xmlrpc.php" | grep '302 Found'
echo -n ".htaccess...       "
nginxExec curl -I "localhost/.htaccess" | grep '404 Not Found'
echo -n "favicon.ico...     "
nginxExec curl -I "localhost/favicon.ico" | grep '200 OK'
echo -n "robots.txt...      "
nginxExec curl -I "localhost/robots.txt" | grep '200 OK'
echo -n "drupal.js...       "
nginxExec curl -I "localhost/misc/drupal.js" | grep '200 OK'
echo -n "druplicon.png...   "
nginxExec curl -I "localhost/misc/druplicon.png" | grep '200 OK'

echo -n "Checking non existing php endpoint... "
nginxExec curl -I "localhost/non-existing.php" | grep '404 Not Found'
echo -n "Checking user-defined internal temporal redirect... "
nginxExec curl -I "localhost/redirect-internal-temporal" | grep '302 Moved Temporarily'
echo -n "Checking user-defined internal permanent redirect... "
nginxExec curl -I "localhost/redirect-internal-permanent" | grep '301 Moved Permanently'
echo -n "Checking user-defined external redirect... "
nginxExec curl -I "localhost/redirect-external" | grep '302 Moved Temporarily'

docker-compose -f test/docker-compose.yml down
