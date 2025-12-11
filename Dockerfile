FROM alpine/ansible:latest

ARG VERSION

LABEL org.opencontainers.image.title="Ansible Docker"
LABEL org.opencontainers.image.description="Clean and disposable Docker environment for executing Ansible CLI commands and playbooks without heavy local installation"
LABEL org.opencontainers.image.source="https://github.com/danylo829/ansible-docker"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.version=$VERSION

RUN apk add --no-cache py3-pip \
	&& python3 -m pip install --upgrade --no-cache-dir --break-system-packages pip setuptools wheel

# Create non-root user (defaults to 1000:1000) for better SSH compatibility
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN addgroup -g ${GROUP_ID} ansible \
	&& adduser -D -u ${USER_ID} -G ansible -h /home/ansible ansible \
	&& mkdir -p /home/ansible/.ssh /home/ansible/.ansible /home/ansible/.cache/pip \
	&& chown -R ansible:ansible /home/ansible

WORKDIR /playbooks

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER ansible

ENV PATH="/home/ansible/.local/bin:${PATH}"

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
