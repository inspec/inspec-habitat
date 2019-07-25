#!/bin/bash

# Install Habitat
if [ ! -e "/bin/hab" ]; then
  curl https://raw.githubusercontent.com/habitat-sh/habitat/master/components/hab/install.sh | sudo bash
  yes | hab --version
  hab pkg install core/hab-sup --binlink
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

if [ ! -f /etc/systemd/system/habitat.service ]; then
  cat << EOF > /etc/systemd/system/habitat.service
  [Unit]
  Description=The Habitat Supervisor
  After=network.target

  [Service]
  ExecStart=/bin/hab sup run
  Restart=always
  RestartSec=5

  [Install]
  WantedBy=default.target
EOF

systemctl start habitat
systemctl enable habitat
fi

# Install and start two services
echo "Installing and starting core/httpd"
hab pkg install "core/httpd"
hab svc load "core/httpd"

echo "Installing and starting core/memcached"
hab pkg install "core/memcached"
hab svc load "core/memcached"

# Install at least two releases of the same version of a package
hab pkg install core/libiconv/1.14/20161031044856
hab pkg install core/libiconv/1.14/20180608141251

# As a side effect of above, glibc got installed at v2.27 and v2.22
