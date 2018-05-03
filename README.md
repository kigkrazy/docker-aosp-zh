Android Open Source Project Docker Build Environment
====================================================

Minimal build environment for AOSP with handy automation wrapper scripts.

how to start ?
----------
Exmple for create an aosp 4.x  build environment.
1. Create docker image.
```
# in project dir
# create docker image
docker build -t aosp:builder -f Dockerfile-aosp-4.x .
```
2. Create aosp source directory, and ccache directory.
```
mkdir -p /usr/local/aosp
mkdir -p /tmp/ccache
```
3. Create and run contain.
```
docker run -it --name aosp-contain -v /usr/local/aosp:/usr/local/aosp -v /tmp/ccache:/tmp/ccache aosp:builder
```
4. download aosp source.
```
# now you go into contain shell
cd /usr/local/aosp
# you can change the branch, look at https://source.android.com/source/build-numbers#source-code-tags-and-builds
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b android-4.4.4_r1
repo sync
```

Tested
------
* Android Kitkat `android-4.4.4_r1`
