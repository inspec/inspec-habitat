#!/bin/bash

if [ ! -e "/bin/hab" ]; then
  curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
fi

if grep "hab" /etc/passwd > /dev/null; then
  echo "Hab user exists"
else
  useradd hab && true
fi

if grep "hab" /etc/group > /dev/null; then
  echo "Hab group exists"
else
  groupadd hab && true
fi

hab pkg install core/hab-sup core/hab-launcher
cp /tmp/kitchen/data/hab-sup.service /usr/lib/systemd/system/
systemctl start hab-sup
sleep 5

hab svc load core/nginx
hab svc start core/nginx
sleep 5

cp /tmp/kitchen/data/index.html /hab/svc/nginx/data/
