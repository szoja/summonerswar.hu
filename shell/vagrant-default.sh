#!/bin/sh
sudo wget http://repo.mysql.com/mysql-apt-config_0.3.2-1debian7_all.deb
sudo dpkg -i mysql-apt-config_0.3.2-1debian7_all.deb
sudo apt-get update
echo mysql-server mysql-server/root_password select "greg666" | debconf-set-selections
echo mysql-server mysql-server/root_password_again select "greg666" | debconf-set-selections
sudo apt-get install -y mysql-server apache2 php5 libapache2-mod-php5 php5-mysql php5-dev
VHOST=$(cat <<EOF
<VirtualHost *:80>
	DocumentRoot "/vagrant/www"
	ServerName localhost
	<Directory "/vagrant/www">
		AllowOverride All
	</Directory>
</VirtualHost>
EOF
)
echo "${VHOST}" > /etc/apache2/sites-enabled/000-default
sudo a2enmod rewrite
sudo service apache2 restart
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sudo service mysql restart
sudo apt-get install php5-gd
sudo apt-get install curl libcurl3 libcurl3-dev php5-curl
sudo apt-get clean