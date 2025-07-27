FROM ubuntu:22.04
LABEL maintainer="support@punctiq.com" \
      org.opencontainers.image.title="Itcommunity OpenLDAP" \
      org.opencontainers.image.version="1.0.0" \
      org.opencontainers.image.description="OpenLDAP installation, simple boilerplate ready to use LDAP implementation." \
      org.opencontainers.image.source="https://punctiq.com" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.documentation="https://secure-doc.punctiq.com/"


ENV DEBIAN_FRONTEND=noninteractive

# Prevent slapd from starting/configuring during install
RUN echo "exit 101" > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Install OpenLDAP and tools
RUN apt-get update && \
    apt-get install -y slapd ldap-utils slapd-contrib && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Cleanup policy-rc.d
RUN rm -f /usr/sbin/policy-rc.d

# Add entrypoint script
COPY bootstrap/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 389 636

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
