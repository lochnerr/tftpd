FROM alpine:latest

LABEL MAINTAINER Richard Lochner, Clone Research Corp. <lochner@clone1.com> \
      org.label-schema.name = "tftpd" \
      org.label-schema.description = "Minimal tftp daemon container." \
      org.label-schema.vendor = "Clone Research Corp" \
      org.label-schema.usage = "https://linux.die.net/man/8/in.tftpd" \
      org.label-schema.vcs-url = "https://github.com/lochnerr/tftpd.git"

# A minimal tftp (Trivial File Transfer Protocol) serer.
#
# Volumes:
#  * /var/tftpboot - tftp data directory.
#
# Exposed ports:
#  * 69 - Trivial File Transfer Protocol
#
# Linux capabilities required:
#  * CAP_NET_BIND_SERVICE - Bind a socket to Internet domain privileged ports.

EXPOSE 69/udp

# Add packages.
RUN apk add --update --no-cache tftp-hpa

# Copy the local scripts.
COPY bin/* /usr/local/bin/

# Declare the volume(s) after setting up their content to preserve ownership.
VOLUME /var/tftpboot

# Set the container build date.
RUN . /etc/os-release; echo $(date +%y/%m/%d) Built for $PRETTY_NAME > /etc/container-build-date

# Run the daemon in the foreground.

# --foreground Runs the ftp server in the foreground.
# -R 4096:32767 solves problems with ARC firmware, and obsoletes
# the /proc/sys/net/ipv4/ip_local_port_range hack.
# --secure causes /var/tftpboot to be the root of the TFTP tree.
CMD ["in.tftpd", "--foreground", "-R", "4096:32767", "--secure", "/var/tftpboot"]

