#!/bin/bash

#symfony app with nginx deployment example
sudo -u deploy git --git-dir /opt/deploy/project.git fetch upstream master
if [ $? -eq 0 ]; then
    echo "[INFO] Fetched tags from upstream"
else
    echo "[ERROR] failed to fetch tags from upstream"
    exit 1;
fi

sudo rm -rf /opt/sites/project/archive/prev/*
if [ $? -eq 0 ]; then
    echo "[INFO] cleaned up backup folder"
else
    echo "[ERROR] failed to clean up backup folder"
    exit 1;
fi

sudo cp -r /opt/sites/project/archive/curr/. /opt/sites/project/archive/prev/
if [ $? -eq 0 ]; then
    echo "[INFO] Backed up previous release"
else
    echo "[ERROR] failed to back up previous release"
    exit 1;
fi

sudo chown -R deploy.www-data /opt/sites/project/archive/prev
if [ $? -eq 0 ]; then
    echo "[INFO] Checking config on new release"
else
    echo "[ERROR] Config check on new release failed"
    exit 1;
fi

sudo ln -sf ../sites-available/example.mn-prev /etc/nginx/sites-enabled/example.mn
if [ $? -eq 0 ]; then
    echo "[INFO] Enabled example.mn-prev"
else
    echo "[ERROR] failed to enable example.mn-prev"
    exit 1;
fi

sudo nginx -t
if [ $? -eq 0 ]; then
    echo "[INFO] Nginx config check succeeded"
else
    echo "[ERROR] failed to check nginx config"
    exit 1;
fi

sudo service nginx reload
if [ $? -eq 0 ]; then
    echo "[INFO] Nginx reloaded to use prev folder"
else
    echo "[ERROR] failed to reload nginx to use prev folder"
    exit 1;
fi

sudo -u deploy git --work-tree=/opt/sites/project/archive/curr --git-dir=/opt/deploy/project.git checkout -f upstream/$1
if [ $? -eq 0 ]; then
    echo "[INFO] Updated new release on folder (version: $1)"
else
    echo "[ERROR] failed to update new release on folder"
    exit 1;
fi

sudo -u deploy composer2 install --ignore-platform-reqs -d /opt/sites/project/archive/curr
if [ $? -eq 0 ]; then
    echo "[INFO] Installed packages with composer install"
else
    echo "[ERROR] failed to composer install"
    exit 1;
fi

sudo -u deploy php7.2 /opt/sites/project/archive/curr/bin/console cache:clear --env=prod --no-debug --no-warmup
if [ $? -eq 0 ]; then
    echo "[INFO] Checking config on new release"
else
    echo "[ERROR] Config check on new release failed"
    exit 1;
fi

sudo -u deploy php7.2 /opt/sites/project/archive/curr/bin/console cache:warmup --env=prod
if [ $? -eq 0 ]; then
    echo "[INFO] Checking config on new release"
else
    echo "[ERROR] Config check on new release failed"
    exit 1;
fi

sudo chmod -R 775 /opt/sites/project/archive/curr/var/cache/prod
if [ $? -eq 0 ]; then
    echo "[INFO] Checking config on new release"
else
    echo "[ERROR] Config check on new release failed"
    exit 1;
fi

sudo chown -R deploy.www-data /opt/sites/project/archive/curr
if [ $? -eq 0 ]; then
    echo "[INFO] Checking config on new release"
else
    echo "[ERROR] Config check on new release failed"
    exit 1;
fi

sudo ln -sf ../sites-available/example.mn-curr /etc/nginx/sites-enabled/example.mn
if [ $? -eq 0 ]; then
    echo "[INFO] Enabled example.mn-curr"
else
    echo "[ERROR] failed to enable example.mn-curr"
    exit 1;
fi

sudo nginx -t
if [ $? -eq 0 ]; then
    echo "[INFO] Nginx config check succeeded"
else
    echo "[ERROR] failed to check nginx config"
    exit 1;
fi

sudo service nginx reload
if [ $? -eq 0 ]; then
    echo "[INFO] Nginx reloaded to use curr folder"
else
    echo "[ERROR] failed to reload nginx to use curr folder"
    exit 1;
fi
