#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:16.04

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

RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties   
RUN add-apt-repository ppa:openjdk-r/ppa
# Keep the dependency list as short as reasonable
RUN apt-get update && \
    apt-get install -y bc bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk3.0-dev libxml2-utils lzop sudo \
        openjdk-8-jdk \
        pngcrush schedtool xsltproc zip zlib1g-dev graphviz && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl $REPO_DOWNLOAD_URL -o /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

# set bash env
RUN echo "export REPO_URL=$REPO_URL_ENV" >> /root/.bashrc
RUN echo '. /etc/profile' >> /root/.bashrc
RUN echo 'export AOSP_ROOT=/usr/local/aosp' >> /root/.bashrc
RUN echo 'export PATH=$PATH:${AOSP_ROOT}/out/host/linux-x86/bin' >> /root/.bashrc

# All builds will be done by user aosp
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/usr/local/aosp"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /usr/local/aosp
