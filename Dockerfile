FROM bitnami/java:1.8 as java

FROM bitnami/php-fpm:7.3 as php

# Update
RUN apt-get -y update

# Install git, ps, etc
RUN apt-get install -y procps git curl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add deploy group and user
RUN groupadd -g 1002 deploy && \
    useradd -u 1002 -g 1002 deploy

# Copy Jenkins slave agent
RUN mkdir -p /usr/share/jenkins
COPY ./slave.jar /usr/share/jenkins

# Merge images
COPY --from=java /opt/bitnami /opt/bitnami

ENV PATH="/opt/bitnami/java/bin:${PATH}"

# Run container as deploy user not root
USER deploy
