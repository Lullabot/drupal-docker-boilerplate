FROM mysql:5.7.12

RUN { \
		echo 'max_allowed_packet=250M'; \
	} >> /etc/mysql/my.cnf

VOLUME /var/lib/mysql
