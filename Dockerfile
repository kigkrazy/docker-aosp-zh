#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:14.04

MAINTAINER kigkrazy <kigkrazy@gmail.com>

# Setup for Java
#RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" \
#        >> /etc/apt/sources.list.d/webupd8.list && \
#    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
#    echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections



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

#ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
#change `repo` download mirror to TUNA
RUN curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

# install java6 by ftp
RUN curl http://bridsys.com/downloads/java/jdk-6u45-linux-x64.bin -o /usr/local/jdk-6u45-linux-x64.bin
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
RUN echo '. /etc/profile' >> ~/.bashrc

# All builds will be done by user aosp
RUN useradd --create-home aosp
ADD gitconfig /home/aosp/.gitconfig
ADD ssh_config /home/aosp/.ssh/config
RUN chown aosp:aosp /home/aosp/.gitconfig
# add REPO_URL env
RUN echo "export REPO_URL='https://mirrors.tuna.tsinghua.edu.cn/git/git-repo/'" >> /home/aosp/.bashrc

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/usr/local/aosp"]

# Improve rebuild performance by enabling compiler cache
ENV USE_CCACHE 1
ENV CCACHE_DIR /tmp/ccache

# Work in the build directory, repo is expected to be init'd here
#USER aosp
#WORKDIR /usr/local/aosp
