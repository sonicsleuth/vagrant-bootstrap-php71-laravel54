#  Bootstrap.sh
#  Created 7/22/2017
#  Author: Richard Soares
#  Version: 1.2.1
#
#  Installs PHP 7.1 LAMP Stack with Composer and Laravel.
#
#  IMPORTANT:
#  After you provision this virtual box you must run the following 
#  command from your host machine (your physical computer) to make
#  the Laravel storage directory writeable.
#  run: chmod -R 777 /path-to-directory/laravel-site/storage
#
#  This file will provision a Virtual Box with the following:
#  - Laravel
#  - Apache
#  - MySQL - *update the default password, see below.
#  - PHP 7.1.*
#    > Imagick
#    > GD
#    > Curl
#    > PDO
#    > Mbstring
#    > XML
#    > Tokenizer (Built-in support for tokenizer is available as of PHP 4.3.0)
#
#  After your virtual machine starts for the first time,
#  it will be "provisioned". The provisioning process will
#  allow you to do additional setup tasks like installing
#  software, configuring services, etc.
#
#  This file will be executed during the provisioning process.
#
#  Simply type standard shell commands below as you would
#  normally run them in a terminal window.

# Define the root password to use when installing MySQL
mysqlpass=secret
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password '$mysqlpass' '
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password '$mysqlpass' '

# Upgrade Ubuntu so we are all secure.
sudo apt-get dist-upgrade

# Install ZIP for installing Laravel later.
sudo apt-get -y install zip
sudo apt-get -y install unzip

# Install PHP7.1 plus extensions
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update
sudo apt-get -y install apache2
sudo apt-get -y install mysql-server
sudo apt-get -y install php7.1
sudo apt-get -y install php7.1-mysql 
sudo apt-get -y install php7.1-curl 
sudo apt-get -y install php7.1-dev 
sudo apt-get -y install php7.1-gd 
sudo apt-get -y install php7.1-intl 
sudo apt-get -y install php7.1-mcrypt 
sudo apt-get -y install php7.1-json 
sudo apt-get -y install php7.1-opcache 
sudo apt-get -y install php7.1-bcmath 
sudo apt-get -y install php7.1-mbstring 
sudo apt-get -y install php7.1-soap 
sudo apt-get -y install php7.1-xml 
sudo apt-get -y install libapache2-mod-php7.1
sudo apt-get -y install php-imagick

# Restart Apache
sudo service apache2 restart 


if [ ! -h /var/www ]; 
then 
    # Update Apache
        # Add the default Apache user to the vagrant group
        sudo usermod -a -G vagrant www-data
        # Enable Apache2 ModRewrite for use in .htaccess files.
        sudo a2enmod rewrite
        # Update the VHOST file with Directory permissions.
        sudo sed -i.bak '/DocumentRoot/a <Directory "/var/www/html"''>\nRequire all granted\nAllow from all\nOrder allow,deny\nAllowOverride All\nOptions Indexes FollowSymLinks\n</Directory>\n' /etc/apache2/sites-available/000-default.conf
        # Update the main Apache2 Config to insure .htaccess can be read.
        sudo sed -i.bak 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf
        # Restart Apache2
        sudo service apache2 restart
    
    # Install Composer
    cd /vagrant
    sudo curl -sS https://getcomposer.org/installer | php
    
    # Install Laravel
    cd /vagrant
    php composer.phar create-project --prefer-dist laravel/laravel 'laravel-site'

    # Make Symlink from Virtual Machine 'html' web root to the Laravel 'public' web root on the Host machine.
    sudo rm -rf /var/www/html
    sudo ln -s /vagrant/laravel-site/public /var/www/html
    
    # Make Laravel /storage/ directory writable. It's holds cache and public upload files.
    # Make sure to add the following to the Vagrant file: config.vm.synced_folder ".", "/vagrant", :mount_options => ['dmode=774','fmode=775']
    cd /vagrant
    sudo chmod -R 777 /vagrant/laravel-site/storage
fi

# Upgrade all packages for security purposes.
sudo apt-get update
sudo apt-get upgrade