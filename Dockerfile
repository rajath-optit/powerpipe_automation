FROM ubuntu:latest
 
# Install dependencies
RUN apt-get update && \
    apt-get install -y curl tar && \
    groupadd -g 1001 powerpipe && \
    useradd -u 1001 --create-home --shell /bin/bash --gid powerpipe powerpipe
 
# Environment variables
ENV USER_NAME=powerpipe
ENV GROUP_NAME=powerpipe
ENV POWERPIPE_TELEMETRY=none
 
WORKDIR /home/$USER_NAME
 
# Install Powerpipe
RUN curl -LO https://github.com/turbot/powerpipe/releases/download/v0.3.1/powerpipe.linux.amd64.tar.gz && \
    tar xvzf powerpipe.linux.amd64.tar.gz && \
    mv powerpipe /usr/local/bin/powerpipe && \
    rm -rf powerpipe.linux.amd64.tar.gz
 
# Install Steampipe
RUN curl -LO https://steampipe.io/install/steampipe.sh && \
    sh steampipe.sh && \
    rm -f steampipe.sh
 
# Switch to the non-root user
USER powerpipe
 
# Install AWS plugin for Steampipe as the non-root user
RUN steampipe plugin install aws
