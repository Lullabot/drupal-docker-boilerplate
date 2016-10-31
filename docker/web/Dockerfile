FROM php:5.6.26-apache

RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev libldap2-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
    && docker-php-ext-install gd mbstring opcache pdo pdo_mysql pdo_pgsql zip ldap

RUN apt-get update && apt-get install -y \
        openssh-client \
        rsync \
        parallel \
        mysql-client \
        git \
        supervisor \
        ocaml

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
RUN mkdir -p /var/www/html/drupal-docroot
RUN sed -i 's/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/drupal-docroot/g' /etc/apache2/sites-available/000-default.conf

RUN a2enmod rewrite

RUN mkdir -p /root/unison
COPY unison-2.48.4 /root/unison
WORKDIR /root/unison
RUN  make UISTYLE=text
WORKDIR /root

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/composer
ENV PATH /root/.composer/vendor/bin:$PATH
RUN composer global require drush/drush

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN { \
        echo 'xdebug.remote_enable=1'; \
        echo 'xdebug.remote_port=9000'; \
        # Getting the right setting here can be tricky...
        # Currently only option #3 works, so find your local IP, uncomment that line and add it in.
        # 1:
        #echo 'xdebug.remote_connect_back=On'; \
        # 2: Run /sbin/ip route|awk '/default/ { print $3 }' inside the container to check whether 172.17.0.1 is the
        # value of your host's IP within the container.
        #echo 'xdebug.remote_host=172.17.0.1'; \
        # 3: Run ifconfig on your host machine to get it's network IP
        #echo 'xdebug.remote_host=10.0.1.11'; \
        echo 'xdebug.profiler_enable=0'; \
        echo 'xdebug.profiler_enable_trigger=1'; \
        echo 'xdebug.profiler_output_name = "cachegrind.out.%t-%s"'; \
        echo 'xdebug.profiler_output_dir = "/tmp/xdebug_profiler"'; \
        echo 'xdebug.profiler_append=1'; \
    } >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shsutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN { \
        echo 'memory_limit=1024M'; \
        echo 'max_input_vars = 5000'; \
        echo 'max_execution_time = 360'; \
        echo 'max_input_time = 120'; \
    } > /usr/local/etc/php/conf.d/global.ini

RUN touch /usr/local/etc/php/php.ini

WORKDIR /var/www/html

VOLUME /var/www/html
VOLUME /root/.ssh
VOLUME /root/xdebug_profiler
VOLUME /tmp/syncdb

CMD ["/usr/bin/supervisord"]
