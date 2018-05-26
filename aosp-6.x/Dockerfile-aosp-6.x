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

RUN apt-get update
RUN apt-get install -y software-properties-common python-software-properties   
RUN add-apt-repository ppa:openjdk-r/ppa
# Keep the dependency list as short as reasonable
RUN apt-get update && \
    apt-get install -y bc bison bsdmainutils build-essential curl \
        flex g++-multilib gcc-multilib git gnupg gperf lib32ncurses5-dev \
        lib32readline-gplv2-dev lib32z1-dev libesd0-dev libncurses5-dev \
        libsdl1.2-dev libwxgtk2.8-dev libxml2-utils lzop \
        openjdk-8-jdk \
        pngcrush schedtool xsltproc zip zlib1g-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl $REPO_DOWNLOAD_URL -o /usr/local/bin/repo
RUN chmod 755 /usr/local/bin/*

# set bash env
RUN echo "export REPO_URL=$REPO_URL_ENV" >> /root/.bashrc
RUN echo '. /etc/profile' >> /root/.bashrc
RUN echo 'export AOSP_ROOT=/usr/local/aosp' >> /root/.bashrc
RUN echo 'export PATH=$PATH:${AOSP_ROOT}/out/host/linux-x86/bin' >> /root/.bashrc
WORKDIR /

# Install latest version of JDK
# See http://source.android.com/source/initializing.html#setting-up-a-linux-build-environment
#WORKDIR /tmp
#RUN curl -O http://mirrors.kernel.org/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jre-headless_8u45-b14-1_amd64.deb && \
#    curl -O http://mirrors.kernel.org/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jre_8u45-b14-1_amd64.deb && \
#    curl -O http://mirrors.kernel.org/ubuntu/pool/universe/o/openjdk-8/openjdk-8-jdk_8u45-b14-1_amd64.deb && \
#    sum=`shasum ./openjdk-8-jre-headless_8u45-b14-1_amd64.deb | awk '{ print $1 }'` && \
#    [ $sum == "e10d79f7fd1b3d011d9a4910bc3e96c3090f3306" ] || \
#      ( echo "Hash mismatch. Problem downloading openjdk-8-jre-headless" ; exit 1; ) && \
#    sum=`shasum ./openjdk-8-jre_8u45-b14-1_amd64.deb | awk '{ print $1 }'` && \
#    [ $sum == "1e083bb952fc97ab33cd46f68e82688d2b8acc34" ] || \
#      ( echo "Hash mismatch. Problem downloading openjdk-8-jre" ; exit 1; ) && \
#    sum=`shasum ./openjdk-8-jdk_8u45-b14-1_amd64.deb | awk '{ print $1 }'` && \
#    [ $sum == "772e904961a2a5c7d2d129bdbcfd5c16a0fab4bf" ] || \
#      ( echo "Hash mismatch. Problem downloading openjdk-8-jdk" ; exit 1; ) && \
#    dpkg -i *.deb && \
#    apt-get -f install && \
#    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# All builds will be done by user aosp
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/usr/local/aosp"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /usr/local/aosp
