# syntax=docker/dockerfile:1
FROM fedora:41

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

COPY files/etc /etc

RUN <<EOF
  # Configure systemd
  rm -f /lib/systemd/system/multi-user.target.wants/*
  rm -f /etc/systemd/system/*.wants/*
  rm -f /lib/systemd/system/local-fs.target.wants/*
  rm -f /lib/systemd/system/sockets.target.wants/*udev*
  rm -f /lib/systemd/system/sockets.target.wants/*initctl*
  rm -f /lib/systemd/system/basic.target.wants/*
  rm -f /lib/systemd/system/anaconda.target.wants/*

  # Install software for representative system
  dnf -y update
  dnf -y install initscripts \
                 libselinux \
                 libselinux-utils \
                 policycoreutils \
                 python3 \
                 python3-libselinux \
                 selinux-policy \
                 selinux-policy-targeted \
                 sudo
  dnf clean all

  sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

  # Create the ansible user
  groupadd ansible
  useradd --create-home --gid ansible --shell /bin/bash ansible
EOF

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
