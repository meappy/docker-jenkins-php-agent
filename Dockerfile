FROM bitnami/java:1.8 as java

FROM bitnami/php-fpm:7.3 as php

# Update
RUN apt-get -y update

# Install git, ps, etc
RUN apt-get install -y procps git curl jq

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

# Arguments for build
ARG JNLP_PROTOCOL_OPTS
ARG JENKINS_AGENT
ARG JENKINS_URL
ARG JENKINS_AGENT_WORKDIR
ARG JENKINS_SECRET
ARG JENKINS_AGENT_NAME
ARG JENKINS_SECRET_LIST
ARG HOSTNAME

# Build JENKINS_SECRET then run Jenkins
CMD if [ -z "${JENKINS_SECRET}" ]; then \
      if [ -z "${JENKINS_SECRET_LIST}" ]; then \
        :; else \
        JENKINS_SECRET="$(echo ${JENKINS_SECRET_LIST} | jq -r .${HOSTNAME})"; \
        java "${JNLP_PROTOCOL_OPTS}" \
        -cp "${JENKINS_AGENT}" hudson.remoting.jnlp.Main -headless \
        -url "${JENKINS_URL}" \
        -workDir "${JENKINS_AGENT_WORKDIR}" "${JENKINS_SECRET}" \
        "${JENKINS_AGENT_NAME}"; \
      fi; else \
      :; \
    fi
