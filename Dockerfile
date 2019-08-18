FROM bitnami/java:1.8 as java

FROM bitnami/php-fpm:7.3 as php

# Arguments for build
ARG JNLP_PROTOCOL_OPTS
ARG JENKINS_AGENT
ARG JENKINS_URL
ARG JENKINS_AGENT_WORKDIR
ARG JENKINS_SECRET
ARG JENKINS_AGENT_NAME
ARG JENKINS_AGENT_VERSION
ARG JENKINS_SECRET_LIST
ARG JENKINS_HOSTNAME

# ENV substitution
ENV JENKINS_AGENT_VERSION=${JENKINS_AGENT_VERSION:-3.29}
ENV JENKINS_AGENT=${JENKINS_AGENT:-/usr/share/jenkins/slave.jar}

# Update
RUN apt-get -y update

# Install git, ps, etc
RUN apt-get install -y procps git curl jq

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add deploy group and user
RUN groupadd -g 1002 deploy && \
    useradd -u 1002 -g 1002 deploy

# Merge Docker images
COPY --from=java /opt/bitnami /opt/bitnami

# Add java path
ENV PATH="/opt/bitnami/java/bin:${PATH}"

# Run container as deploy user (will use jenkins user TODO)
USER deploy

# Build JENKINS_SECRET then run Jenkins
CMD export JENKINS_AGENT_NAME="$(echo ${JENKINS_AGENT_NAME} | cut -d . -f1)"; \
    export JENKINS_HOSTNAME="$(echo ${JENKINS_HOSTNAME} | cut -d . -f1)"; \
    # Download Jenkins slave agent 
    curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar; \
    https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${JENKINS_AGENT_VERSION}/remoting-${JENKINS_AGENT_VERSION}.jar; \
    && chmod 755 /usr/share/jenkins; \
    && chmod 644 /usr/share/jenkins/slave.jar; \
    if [ -z "${JENKINS_SECRET}" ]; then \
      if [ -z "${JENKINS_SECRET_LIST}" ]; then \
        :; else \
        export JENKINS_SECRET="$(echo ${JENKINS_SECRET_LIST} | jq -r .${JENKINS_HOSTNAME})"; \
      fi; else \
      :; \
    fi; \
    if [ -z "${JENKINS_AGENT_NAME}" ]; then \
      :; else \
      java "${JNLP_PROTOCOL_OPTS}" \
      -cp "${JENKINS_AGENT}" hudson.remoting.jnlp.Main -headless \
      -url "${JENKINS_URL}" \
      -workDir "${JENKINS_AGENT_WORKDIR}" "${JENKINS_SECRET}" \
      "${JENKINS_AGENT_NAME}"; \
    fi
