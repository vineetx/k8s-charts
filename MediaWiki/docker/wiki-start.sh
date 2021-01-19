#!/bin/bash

VERSION_MAJOR_WIKI=1.35
VERSION_MINOR_WIKI=1
SRC_WIKI=https://releases.wikimedia.org/mediawiki/${VERSION_MAJOR_WIKI}/mediawiki-${VERSION_MAJOR_WIKI}.${VERSION_MINOR_WIKI}.tar.gz
TAR_WIKI=mediawiki-${VERSION_MAJOR_WIKI}.${VERSION_MINOR_WIKI}.tar.gz
FOLDER_NAME_WIKI=mediawiki
FOLDER_WIKI=mediawiki/
FOLDER_WEB=/var/www/html/

#check if TLS_REQCERT is present
if !(grep -q "TLS_REQCERT" /etc/ldap/ldap.conf)
then
	echo "TLS_REQCERT isn't present"
        echo -e "TLS_REQCERT\tnever" >> /etc/ldap/ldap.conf
fi

#Check if MediaWiki is already installed by check folder
if [ "$(ls ${FOLDER_WEB}${FOLDER_WIKI})" ];
then
	echo "MediaWiki is already installed"
else
	#Download MediaWiki and change owner
	wget -P ${FOLDER_WEB} ${SRC_WIKI}
	tar -xzf ${FOLDER_WEB}${TAR_WIKI} -C ${FOLDER_WEB} --transform s/mediawiki-${VERSION_MAJOR_WIKI}.${VERSION_MINOR_WIKI}/${FOLDER_NAME_WIKI}/
	rm -Rf ${FOLDER_WEB}${TAR_WIKI}
	chown -R www-data:www-data ${FOLDER_WEB}${FOLDER_NAME_WIKI}

	#Change permission on images folder
	chown -R 544 ${FOLDER_WEB}${FOLDER_WIKI}images

fi

#Modify default apache virtualhost
echo -e "<VirtualHost *:80>\n\tDocumentRoot ${FOLDER_WEB}${FOLDER_NAME_WIKI}\n\n\t<Directory ${FOLDER_WEB}${FOLDER_NAME_WIKI}>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-${FOLDER_NAME_WIKI}.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-${FOLDER_NAME_WIKI}.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

#Enable rewrite module
a2enmod rewrite && service apache2 restart && service apache2 stop

#Launch apache2 foreground mode
/usr/sbin/apache2ctl -D FOREGROUND
