#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

MAINTAINER kigkrazy <kigkrazy@gmail.com>

# Some url config
# TUNA is for china
ENV REPO_DOWNLOAD_URL https://mirrors.tuna.tsinghua.edu.cn/git/git-repo
# google is fo other contries
#ENV REPO_DOWNLOAD_URL https://commondatastorage.googleapis.com/git-repo-downloads/repo
#ENV JDK_DOWNLOAD_URL http://bridsys.com/downloads/java/jdk-6u45-linux-x64.bin
ENV REPO_URL_ENV 'https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'


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
        openjdk-7-jdk \
        pngcrush schedtool xsltproc zip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl $REPO_DOWNLOAD_URL -o /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

# set bash env
RUN echo "export REPO_URL=$REPO_URL_ENV" >> ~/.bashrc
RUN echo '. /etc/profile' >> ~/.bashrc
RUN echo 'export AOSP_ROOT=/usr/local/aosp' >> /.bashrc
RUN echo 'export PATH=$PATH:${AOSP_ROOT}/out/host/linux-x86/bin' >> /.bashrc
WORKDIR /

# config git and ssh
ADD gitconfig /root/.gitconfig
ADD ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/usr/local/aosp"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /usr/local/aosp
