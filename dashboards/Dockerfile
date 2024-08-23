FROM ubuntu:latest

# Install required packages including curl and tar
RUN apt-get update && \
    apt-get install -y curl tar && \
    #* Creating non-root user for compliance
    groupadd -g 1001 powerpipe && \
    useradd -u 1001 --create-home --shell /bin/bash --gid powerpipe powerpipe

# Set environment variables
ENV USER_NAME=powerpipe
ENV GROUP_NAME=powerpipe
ENV POWERPIPE_TELEMETRY=none

WORKDIR /home/$USER_NAME/mod

# Download and install PowerPipe
RUN curl -LO https://github.com/turbot/powerpipe/releases/download/v0.3.1/powerpipe.linux.amd64.tar.gz \
  && tar xvzf powerpipe.linux.amd64.tar.gz \
  && mv powerpipe /usr/local/bin/powerpipe \
  && rm -rf powerpipe.linux.amd64.tar.gz

# Copy mod directory and set permissions
COPY mod.pp /home/${USER_NAME}/mod.pp
RUN chown -R ${USER_NAME}:${GROUP_NAME} /home/${USER_NAME}/mod

# Run as unprivileged user
USER $USER_NAME
ENV USER=$USER_NAME
RUN powerpipe mod install

# Copy and set up entrypoint
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/bin/bash", "/entrypoint.sh" ]
CMD [ "/usr/local/bin/powerpipe", "server", "--listen", "local" ]
