# syntax=docker/dockerfile:1
FROM fedora:41

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

COPY files/etc /etc

RUN <<EOF
  # Configure systemd
  rm --force /lib/systemd/system/multi-user.target.wants/*
  rm --force /etc/systemd/system/*.wants/*
  rm --force /lib/systemd/system/local-fs.target.wants/*
  rm --force /lib/systemd/system/sockets.target.wants/*udev*
  rm --force /lib/systemd/system/sockets.target.wants/*initctl*
  rm --force /lib/systemd/system/basic.target.wants/*
  rm --force /lib/systemd/system/anaconda.target.wants/*

  # Install software for representative system
  dnf --assumeyes update
  dnf --assumeyes install kernel-modules \
                  kernel-modules-extra \
                  initscripts \
                  libselinux \
                  libselinux-utils \
                  policycoreutils \
                  python3 \
                  python3-libdnf5 \
                  python3-libselinux \
                  selinux-policy \
                  selinux-policy-targeted \
                  sudo
  dnf clean all

  sed --in-place --expression='s/^\(Defaults\s*requiretty\)/#--- \1/' /etc/sudoers

  # Create the ansible user
  groupadd ansible
  useradd --create-home --gid ansible --shell /bin/bash ansible
EOF

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/lib/systemd/systemd"]
