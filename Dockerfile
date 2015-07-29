FROM linuxserver/baseimage
MAINTAINER Mark Burford <sparklyballs@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root
ENV TERM screen


# add file required pre-compile stage
RUN mkdir -p /defaults
ADD defaults/ /defaults/

# set variable containing build dependencies
RUN buildDeps="automake \
gperf \
gettext \
libtool \
yasm \
autoconf \
libgcrypt20-dev \
cmake \
build-essential \
libflac-dev \
antlr3 \
libasound2-dev \
libplist-dev \
libmxml-dev \
zlib1g-dev \
libunistring-dev \
libantlr3c-dev \
git-core \
wget \
libavahi-client-dev \
libconfuse-dev" && \

# set variable containing runtime dependencies
runtimeDeps="libgcrypt20 \
libavahi-client3 \
libflac8 \
libogg0 \
supervisor \
libantlr3c-3.2-0 \
libasound2 \
libplist1 \
libmxml1 \
libunistring0 \
avahi-daemon \
libconfuse0" && \

# install build dependencies
mv defaults/excludes /etc/dpkg/dpkg.cfg.d/excludes && \
apt-get update -qq && \
apt-get install \
--no-install-recommends \
$buildDeps -qy && \

#fetch source for all the packages to compile
cd /tmp && \
wget http://curl.haxx.se/download/curl-7.43.0.tar.gz && \
wget http://taglib.github.io/releases/taglib-1.9.1.tar.gz && \
wget --no-check-certificate https://qa.debian.org/watch/sf.php/levent/libevent-2.1.5-beta.tar.gz && \
wget --no-check-certificate https://developer.spotify.com/download/libspotify/libspotify-12.1.51-Linux-x86_64-release.tar.gz && \
wget http://www.sqlite.org/sqlite-amalgamation-3.7.2.tar.gz && \
git clone https://github.com/FFmpeg/FFmpeg.git && \
git clone https://github.com/ejurgensen/forked-daapd.git && \

# build curl with ssl support for lastfm
cd /tmp && \
tar xvf curl-* && \
cd curl-* && \
./configure \
--prefix=/usr \
--with-ssl \
--with-zlib && \
make && \
make install && \

# build taglib
cd /tmp && \
tar xvf taglib-* && \
cd taglib-* && \
cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DCMAKE_RELEASE_TYPE=Release . && \
make && \
make install && \
ldconfig && \

# build libspotify
cd /tmp && \
tar xzf libspotify-* && \
cd libspotify-* && \
make install prefix=/usr/local && \

# configure and build libevent
cd /tmp && \
tar xvf libevent-* && \
cd libevent-*  && \
./configure && \
make && \
make install && \


# configure and build sqlite
cd /tmp && \
tar xvf sqlite-* && \
cd sqlite-* && \
mv /defaults/Makefile.in /defaults/Makefile.am . && \
./configure && \
make && \
make install && \
 

# configure and build ffmpeg
cd /tmp/FFmpeg && \
git checkout release/2.7 && \
./configure \
--prefix=/usr \
--enable-nonfree \
--disable-static \
--enable-shared \
--disable-debug && \

make && \
make install && \

# configure and build forked-daapd
cd /tmp/forked-daapd && \
git checkout 23.2 && \
autoreconf -i && \
./configure \
--enable-itunes \
--enable-mpd \
--enable-spotify \
--enable-lastfm \
--enable-flac \
--enable-musepack \
--prefix=/usr \
--sysconfdir=/etc \
--localstatedir=/var && \
make && \
make install && \
cd / && \

# clean build dependencies
apt-get purge --remove \
$buildDeps -y && \
apt-get autoremove -qy && \

# install runtime dependencies
apt-get install \
$runtimeDeps -qy && \

# cleanup
apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

#Adding Custom files
ADD init/ /etc/my_init.d/

RUN chmod -v +x /etc/service/*/run && chmod -v +x /etc/my_init.d/*.sh

#Adding abc user
RUN useradd -u 911 -U -s /bin/false abc && usermod -G users abc

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]


# Volums and Ports
VOLUME /config /music
EXPOSE 3689




