FROM debian:12

ENV DEBIAN_FRONTEND=noninteractive

# COPY pakcages list
COPY deploy/packages.txt /tmp/packages.txt
COPY deploy/remove_carriage.sh /tmp/remove_carriage.sh
RUN bash /tmp/remove_carriage.sh /tmp/packages.txt

# ugrade and install packages
RUN apt update
RUN apt install -y `cat /tmp/packages.txt`
RUN rm /tmp/packages.txt
RUN make-ssl-cert generate-default-snakeoil
RUN usermod --append --groups ssl-cert www-data

# cron
COPY deploy/crontab /etc/cron.d/crontab
RUN bash /tmp/remove_carriage.sh /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab
RUN crontab /etc/cron.d/crontab

# env & debug settings
ARG DEBUG="FALSE"
ENV DEBUG="$DEBUG"
ENV PYTHONOPTIMIZE="$DEBUG"

COPY deploy/debug_config.sh /tmp/debug_config.sh
RUN bash /tmp/remove_carriage.sh /tmp/debug_config.sh
RUN bash /tmp/debug_config.sh

# certificates and ssh keys
RUN mkdir -p /root/.ssh
COPY deploy/rsa_pub/*.pub /root/.ssh/
RUN cat /root/.ssh/*.pub > /root/.ssh/authorized_keys
COPY deploy/bashrc.sh /root/.bashrc
COPY deploy/ssh_config /etc/ssh/ssh_config
RUN bash /tmp/remove_carriage.sh /root/.bashrc
RUN bash /tmp/remove_carriage.sh /etc/ssh/ssh_config

# nginx & php configuration
COPY deploy/sites.conf /etc/nginx/sites-available/
COPY deploy/nginx.conf /etc/nginx/
RUN rm /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/sites-available/sites.conf /etc/nginx/sites-enabled/sites.conf 
COPY deploy/starter.sh /starter.sh
RUN bash /tmp/remove_carriage.sh /starter.sh
RUN echo 'auto_prepend_file = /var/www/private/auto_prepend.php' >> /etc/php/8.2/fpm/php.ini
RUN echo 'variables_order = "EGPCS"' >> /etc/php/8.2/fpm/php.ini
RUN echo 'reques_order = "GP"' >> /etc/php/8.2/fpm/php.ini
RUN cp /etc/php/8.2/fpm/php.ini /etc/php/8.2/cli/php.ini
WORKDIR /

RUN rm -rf /var/www/*
COPY application /var/www
RUN find /var/www/ -name "*.php" -exec bash /tmp/remove_carriage.sh {} \;
RUN find /var/www/ -name "*.js" -exec bash /tmp/remove_carriage.sh {} \;
RUN find /var/www/ -name "*.css" -exec bash /tmp/remove_carriage.sh {} \;
RUN find /var/www/ -name "*.sh" -exec bash /tmp/remove_carriage.sh {} \;
RUN find /var/www/ -name "*.py" -exec bash /tmp/remove_carriage.sh {} \;
RUN find /var/www/ -name "*.sh" -exec bash /tmp/remove_carriage.sh {} \;
RUN chown -R www-data:www-data /var/www

RUN date -u +"%Y%m%d%H%M%S" > '/var/www/private/timestamp.txt'

EXPOSE 22
EXPOSE 80
EXPOSE 443

CMD bash /starter.sh
