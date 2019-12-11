#On choisit une debian
FROM debian:buster-slim

#MAINTAINER Netman "github@diouxx.be"

#Ne pas poser de question à l'installation
ENV DEBIAN_FRONTEND noninteractive

# Install apache2, php7 and modules
RUN set -eux; \
	#\
	#savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y  \
      apache2 \
      php \
      php-mysql \
      php-ldap \
      php-xmlrpc \
      php-imap \
      php-curl \
      php-gd \
      php-mbstring \
      php-xml \
      php-apcu-bc \
      php-cas \
      php-json \
      php-iconv \
      php-xmlrpc \
      curl \
      cron \
      wget \
      jq \
      supervisor \
   ; \
#	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	\
	rm -r /var/lib/apt/lists/*; \
# smoke test \
	apache2 -v ;\
# get latest GLPI
   curl -s https://api.github.com/repos/glpi-project/glpi/releases/latest \
   | grep "browser_download_url.*tgz" \
   | cut -d : -f 2,3 \
   | tr -d \" \ 
   | wget -qi - ; \
# " \
   tar -xzf *.tgz -C /var/www/html/ ;\
   rm -Rf *.tgz; \
   chown -R www-data:www-data /var/www/html/glpi; \
   \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

#Modification du vhost par défaut
#RUN echo "<VirtualHost *:80>\n\tDocumentRoot /var/www/html/glpi\n\n\t<Directory /var/www/html/glpi>\n\t\tAllowOverride All\n\t\tOrder Allow,Deny\n\t\tAllow from all\n\t</Directory>\n\n\tErrorLog /var/log/apache2/error-glpi.log\n\tLogLevel warn\n\tCustomLog /var/log/apache2/access-glpi.log combined\n</VirtualHost>" > /etc/apache2/sites-available/000-default.conf && \
#   echo "*/2 * * * * www-data /usr/bin/php /var/www/html/glpi/front/cron.php &>/dev/null" >> /etc/cron.d/glpi && \
#   echo "date.timezone = \"$TIMEZONE\"" > /etc/php/7.3/apache2/conf.d/timezone.ini; && \
#   a2enmod rewrite && service apache2 restart && service apache2 stop

#Exposition des ports
EXPOSE 80 443

#ADD glpi.cron /etc/cron.d/glpi
#ADD glpi.http /etc/apache2/sites-available/000-default.conf

ADD supervisor /etc/supervisor

ENTRYPOINT ["supervisord"]
CMD ["-c", "/etc/supervisor/supervisord.conf"]

# ENTRYPOINT ["/usr/sbin/apache2ctl","-D","FOREGROUND"]

