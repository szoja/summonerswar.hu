#!/bin/sh

# Temp dirs
mkdir /var/temp
chmod -R 777 /var/temp
cd /var/temp


# MySQL 5.6 package download
wget http://repo.mysql.com/mysql-apt-config_0.2.1-1debian7_all.deb
dpkg -i mysql-apt-config_0.2.1-1debian7_all.deb

# debian php repo
# /etc/apt/sources.list

#deb http://packages.dotdeb.org jessie all
#deb-src http://packages.dotdeb.org jessie all

#deb http://packages.dotdeb.org wheezy all
#deb-src http://packages.dotdeb.org wheezy all

#deb http://packages.dotdeb.org squeeze all
#deb-src http://packages.dotdeb.org squeeze all


#
# Install package
#

#deb http://packages.dotdeb.org wheezy-php56 all
#deb-src http://packages.dotdeb.org wheezy-php56 all


# --------------------------------------------------------
# Apache, Mysql, PHP..
# --------------------------------------------------------

apt-get update
# Set pass...
echo mysql-server mysql-server/root_password select "greg666" | debconf-set-selections
echo mysql-server mysql-server/root_password_again select "greg666" | debconf-set-selections
# Apache, php, mysql
apt-get install -y apache2
apt-get install -y php5 libapache2-mod-php5
apt-get install -y mysql-server-5.6
apt-get install -y php5-mysql
apt-get install -y curl libcurl3 libcurl3-dev php5-curl
apt-get install -y php5-json
apt-get install -y php5-gd
apt-get install -y php5-mcrypt

# SSL self signed

apt-get install openssl
mkdir -p /etc/ssl/localcerts
openssl req -new -x509 -days 365 -nodes -out /etc/ssl/localcerts/apache.pem -keyout /etc/ssl/localcerts/apache.key
chmod 600 /etc/ssl/localcerts/apache*
a2enmod ssl

#
# Virtual hosts config
#

mkdir /vagrant/www/dev.summonhenge.com
mkdir /home/www/dev.summonhenge.com/htdocs
mkdir /home/www/dev.summonhenge.com/logs
mkdir /home/www/dev.summonhenge.com/cgi-bin

touch /etc/apache2/sites-available/dev.summonhenge.com

VHOST=$(cat <<EOF

#
#  dev.summonhenge.com (/etc/apache2/sites-available/dev.summonhenge.com)
#

<VirtualHost *:80>
	ServerName dev.summonhenge.com
	ServerAdmin szatyormail@gmail.com
	
	# Indexes + Directory Root.
	DirectoryIndex index.php
	DocumentRoot "/vagrant/www/dev.summonhenge.com/htdocs"
		
	# CGI Directory
    ScriptAlias /cgi-bin/ /vagrant/www/dev.summonhenge.com/cgi-bin/
    <Location /cgi-bin>
            Options +ExecCGI
    </Location>
	
	<Directory "/vagrant/www/dev.summonhenge.com/htdocs">
		AllowOverride All
	</Directory>
	
	# Logfiles
    ErrorLog  /vagrant/www/dev.summonhenge.com/logs/error.log
    CustomLog /vagrant/www/dev.summonhenge.com/logs/access.log combined
	
</VirtualHost>

<VirtualHost *:443>
	ServerName dev.summonhenge.com
	ServerAdmin szatyormail@gmail.com
	
	SSLEngine On
	SSLCertificateFile /etc/ssl/localcerts/apache.pem
	SSLCertificateKeyFile /etc/ssl/localcerts/apache.key
	
	# Indexes + Directory Root.
	DirectoryIndex index.php
	DocumentRoot "/vagrant/www/dev.summonhenge.com/htdocs"
	
	# CGI Directory
    ScriptAlias /cgi-bin/ /vagrant/www/dev.summonhenge.com/cgi-bin/
    <Location /cgi-bin>
            Options +ExecCGI
    </Location>
		
	<Directory "/vagrant/www/dev.summonhenge.com/htdocs">
		AllowOverride All
	</Directory>
	
	# Logfiles
    ErrorLog  /vagrant/www/dev.summonhenge.com/logs/error.log
    CustomLog /vagrant/www/dev.summonhenge.com/logs/access.log combined
	
</VirtualHost>

EOF
)

echo "${VHOST}" > /etc/apache2/sites-available/dev.summonhenge.com

# enable the site
# enable rewrite module
a2ensite dev.summonhenge.com
a2enmod rewrite
# restart apache service
service apache2 restart
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
service mysql restart

#
# Composer Install
# 

curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
# if you're installing as root or privileged account, don't leave the permissions on default 777
chmod 755 /usr/local/bin/composer
composer install