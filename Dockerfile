FROM amazonlinux:latest

RUN  yum group install -y "Development Tools"

ADD centos.repo.txt /etc/yum.repos.d/centos.repo
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7

RUN yum install -y \
  wget \
  libX11-devel.x86_64 \
  pixman-devel.x86_64 \
  libdrm-devel.x86_64 \
  mesa-libGL-devel.x86_64 \
  openssl-devel.x86_64 \
  xorg-x11-xtrans-devel.noarch \
  libXfont2-devel.x86_64 \
  libxkbfile-devel.x86_64 \
  libpciaccess-devel.x86_64 \
  xorg-x11-utils \
  libXtst-devel.x86_64 \
  libjpeg-turbo-devel.x86_64 \
  libxml2-devel \
  libxslt-devel \
  python3-devel \
  libepoxy-devel \
  libvncserver-devel


WORKDIR /app

RUN wget https://www.x.org/archive/individual/data/xkeyboard-config/xkeyboard-config-2.29.tar.gz && \
  tar -xzf xkeyboard-config-2.29.tar.gz && \
  cd /app/xkeyboard-config-2.29 && \
  export LD_LIBRARY_PATH=/usr/local/lib; \
  export PKG_CONFIG_PATH=/usr/local/share/pkgconfig:/usr/local/lib/pkgconfig; \
  ./configure \
    --prefix=/usr \
    --with-xkb-base=/var/task/xkb && \
  make && make install


RUN wget https://www.x.org/archive/individual/xserver/xorg-server-1.20.8.tar.gz && \
  tar -xzf xorg-server-1.20.8.tar.gz && \
  cd /app/xorg-server-1.20.8 && \
  ./configure \
    --prefix=/usr/local \
    --enable-glamor=no \
    --with-xkb-path=/var/task/xkb \
    --with-xkb-output=/tmp \
    --with-xkb-bin-directory=/var/task/bin && \
  make && make install

RUN wget https://www.x.org/releases/individual/app/xkbcomp-1.4.3.tar.gz && \
  tar -xzf xkbcomp-1.4.3.tar.gz && \
  cd /app/xkbcomp-1.4.3 && \
  ./configure \
    --prefix=/usr \
    --with-xkb-config-root=/var/task/xkb && \
    make -j8 && make install


RUN wget https://github.com/LibVNC/x11vnc/archive/0.9.16.tar.gz -O x11vnc.tar.gz && \
  tar xzf x11vnc.tar.gz && \
  cd x11vnc-0.9.16/ && \
  autoreconf -fiv && \
  ./configure \
    --prefix=/usr/local && \
  make -j8 && make install

RUN wget http://sourceforge.net/projects/fluxbox/files/fluxbox/1.3.7/fluxbox-1.3.7.tar.xz -O fluxbox.tar.xz && \
  tar xJf fluxbox.tar.xz && \
  cd fluxbox-1.3.7 && \
  ./configure \
    --prefix=/usr/local && \
    make -j8 && make install


WORKDIR /app
RUN mkdir -p /var/task/bin
RUN ln -s /usr/bin/xkbcomp /var/task/bin/xkbcomp

ADD bin/run-x11.sh /app/bin/
CMD /app/bin/run-x11.sh
