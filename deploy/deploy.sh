#!/bin/bash
# Deploy on the VPS: ssh root@<vps> 'bash /root/web/api-codigos-postales/deploy/deploy.sh'
set -euo pipefail

# mise lives here and is only on PATH for an interactive root shell.
export PATH=/root/.local/bin:$PATH
export BUNDLE_SILENCE_ROOT_WARNING=1

cd /root/web/api-codigos-postales

echo "Pulling latest changes..."
git pull --ff-only

echo "Installing Ruby and gems..."
mise trust --quiet .
mise install
mise exec -- bundle config set --local deployment true
mise exec -- bundle config set --local without 'development test'
mise exec -- bundle install --quiet

echo "Running migrations..."
set -a
. /etc/api-codigos-postales/env
set +a
mise exec -- bundle exec rake db:migrate

echo "Updating service files..."
for unit in api-codigos-postales.service sepomex-update.service sepomex-update.timer; do
  ln -sf "/root/web/api-codigos-postales/deploy/$unit" "/etc/systemd/system/$unit"
done
systemctl daemon-reload
systemctl enable --quiet api-codigos-postales.service sepomex-update.timer

echo "Restarting app..."
systemctl restart api-codigos-postales.service
systemctl start sepomex-update.timer
systemctl --no-pager --lines=0 status api-codigos-postales.service
