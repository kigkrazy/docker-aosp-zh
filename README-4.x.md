### build aosp-4.x
----
1. Create docker image.
```
# in project dir
docker build -t aosp:4.x -f Dockerfile-4.x .
```
2. Create aosp source directory, and ccache directory.
```
mkdir -p /usr/local/aosp
mkdir -p /tmp/ccache
```
3. Create and run contain.
```
docker run -it --name aosp-4.x -v /usr/local/aosp:/usr/local/aosp -v /tmp/ccache:/tmp/ccache aosp:4.x
```
4. download aosp source.
```
# now you go into contain shell
cd /usr/local/aosp
# you can change the branch, look at https://source.android.com/source/build-numbers#source-code-tags-and-builds
repo init -u https://aosp.tuna.tsinghua.edu.cn/platform/manifest -b android-4.4.4_r1
repo sync
```
