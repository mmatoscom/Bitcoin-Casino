FROM  ubuntu:xenial

# deal with installation warnings
ENV TERM xterm
ENV DEBIAN_FRONTEND=noninteractive

RUN curl -s "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh" | /bin/bash

# litecoin deps
RUN apt-get update \
    && apt-get install -y \
    software-properties-common \
    wget \
    make \
    apache2 \
    php \
    php-dev \ 
    php-mysql \
    libapache2-mod-php \ 
    php-curl \
    php-json \
    php-common \ 
    php-mbstring \ 
    composer \
    php \
    mysql-server \
    git

# create a non-root user
RUN adduser --disabled-login --gecos "" tester

# litecoin
WORKDIR /home/tester
ENV FILE litecoin-0.18.1-x86_64-linux-gnu.tar.gz
RUN wget \
    --no-check-certificate \
    https://download.litecoin.org/litecoin-0.18.1/linux/${FILE}

RUN ls -lart . > ls && cat ls 
RUN tar xvf ${FILE}

RUN mv litecoin-0.18.1/bin/* /usr/bin
RUN rm -rf ${FILE}

# copy the testnet-box files into the image
ADD . /home/tester/litecoin-testnet-box

# make tester user own the litecoin-testnet-box
RUN chown -R tester:tester /home/tester/litecoin-testnet-box 

RUN rm -rf /var/www/html/* && git clone https://github.com/mmatoscom/Bitcoin-Casino.git /var/www/html/
# COPY ./php.ini /etc/php/7.2/apache2/php.ini
# COPY ./slc.conf /etc/apache2/sites-available/slc.conf
# COPY ./apache2.conf /etc/apache2/apache2.conf
WORKDIR /home/tester/litecoin-testnet-box
RUN rm -rfv /etc/apache2/sites-enabled/*.conf
RUN ln -s /etc/apache2/sites-available/slc.conf /etc/apache2/sites-enabled/slc.conf
RUN a2enmod rewrite
EXPOSE 80 443 20001 20011
ENTRYPOINT litecoind
# CMD ["apachectl","-D","FOREGROUND"]
USER tester