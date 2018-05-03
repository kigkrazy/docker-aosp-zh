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
ENV JDK_DOWNLOAD_URL http://bridsys.com/downloads/java/jdk-6u45-linux-x64.bin
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
        # oracle-java6-installer oracle-java6-set-default #oracle unsupport, so delete it
        pngcrush schedtool xsltproc zip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add repo tool
RUN curl $REPO_DOWNLOAD_URL -o /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

# install java6 by ftp
RUN curl $JDK_DOWNLOAD_URL -o /usr/local/jdk-6u45-linux-x64.bin
WORKDIR /usr/local
RUN chmod 755 /usr/local/jdk-6u45-linux-x64.bin
RUN /usr/local/jdk-6u45-linux-x64.bin
RUN rm -rf /usr/local/jdk-6u45-linux-x64.bin
RUN echo 'export JAVA_HOME=/usr/local/jdk1.6.0_45' >> /etc/profile
RUN echo 'export JAVA_BIN=/usr/local/jdk1.6.0_45/bin' >> /etc/profile
RUN echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile
RUN echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
RUN echo 'export JAVA_HOME JAVA_BIN PATH CLASSPATH' >> /etc/profile
RUN rm -rf /usr/local/jdk-6u45-linux-x64.bin
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

# Improve rebuild performance by enabling compiler cache
ENV USE_CCACHE 1
ENV CCACHE_DIR /tmp/ccache
