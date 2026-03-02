# Debian 13 w/systemd for molecule testing

# SPDX-License-Identifier: MIT
# SPDX-FileCopyrightText: 2026 Zack Williams <zdw@zackofalltrades.com>

FROM debian:13

ENV LC_ALL=C
ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         bash \
         iproute2 \
         python3 \
         procps \
         sudo \
         systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -f \
      /etc/systemd/system/*.wants/* \
      /lib/systemd/system/local-fs.target.wants/* \
      /lib/systemd/system/multi-user.target.wants/* \
      /lib/systemd/system/sockets.target.wants/*initctl* \
      /lib/systemd/system/sockets.target.wants/*udev* \
      /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
      /lib/systemd/system/systemd-update-utmp* \
    && echo exit 0 > /usr/sbin/policy-rc.d \
    && ln -s /lib/systemd/system /sbin/init \
    && systemctl set-default multi-user.target

STOPSIGNAL SIGRTMIN+3

VOLUME [ "/sys/fs/cgroup" ]
ENTRYPOINT ["/lib/systemd/systemd"]
