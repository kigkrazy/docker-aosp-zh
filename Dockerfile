#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

MAINTAINER kigkrazy <kigkrazy@gmail.com>

# Setup for Java
RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
        >> /etc/apt/sources.list.d/webupd8.list && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
    echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

# Keep the dependency list as short as reasonable
RUN apt-get update && \
    apt-get install -y bc bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop \
        oracle-java6-installer oracle-java6-set-default \
        pngcrush schedtool xsltproc zip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
#change `repo` download mirror to TUNA
RUN curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

# All builds will be done by user aosp
RUN useradd --create-home aosp
ADD gitconfig /home/aosp/.gitconfig
ADD ssh_config /home/aosp/.ssh/config
RUN chown aosp:aosp /home/aosp/.gitconfig
# add REPO_URL env
RUN echo "export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'" >> /home/aosp/.bashrc

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

# Improve rebuild performance by enabling compiler cache
ENV USE_CCACHE 1
ENV CCACHE_DIR /tmp/ccache

# Work in the build directory, repo is expected to be init'd here
USER aosp
WORKDIR /aosp
