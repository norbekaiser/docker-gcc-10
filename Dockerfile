FROM debian:stable-slim
#GCC Arguments
ARG GCC_MAJOR_VERSION=10
ARG GCC_MINOR_VERSION=3
ARG GCC_PATCH_VERSION=0
#Updating the Base Image
RUN DEBIAN_FRONTEND=noninteractiv apt-get update
RUN DEBIAN_FRONTEND=noninteractiv apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y ca-certificates apt-transport-https
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y git curl wget
#Downloading GCC Source
RUN git clone --depth=1 --branch releases/gcc-${GCC_MAJOR_VERSION}.${GCC_MINOR_VERSION}.${GCC_PATCH_VERSION} https://github.com/gcc-mirror/gcc gcc-src
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y git tar lbzip2 bzip2
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y build-essential flex bison gperf autoconf perl texinfo  autotools-dev  automake
RUN du -sh gcc-src 
RUN cd gcc-src && ./contrib/download_prerequisites
RUN cd gcc-src && rm -rf .git
RUN cd gcc-src && mkdir build && cd build && ../configure \
	--enable-languages=c,c++,fortran,go \
	--disable-multilib \
	--program-suffix=-${GCC_MAJOR_VERSION} \
	--prefix=/usr
RUN cd gcc-src && make -C build -j -l $(nproc)
RUN cd gcc-src && make -C build install
RUN echo '/usr/lib64' > /etc/ld.so.conf.d/gcc-10.conf
RUN DEBIAN_FRONTEND=noninteractiv apt-get remove -y gcc gcc-8
RUN DEBIAN_FRONTEND=noninteractiv apt-get autoremove -y
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y make binutils
RUN ls -al /usr/bin/gc*
RUN rm -rf gcc-src
RUN ldconfig -v
#CMake Arguments
ARG CMAKE_MAJOR_VERSION=3
ARG CMAKE_MINOR_VERSION=18
ARG CMAKE_PATCH_VERSION=1
#Downloading CMAKE
RUN git clone --depth=1 --branch v${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION} https://gitlab.kitware.com/cmake/cmake.git cmake-src
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y  libssl-dev librhash-dev zlib1g-dev libcurl4-openssl-dev libexpat1-dev libarchive-dev libjsoncpp-dev libuv1-dev
RUN cd cmake-src && CC=/usr/bin/gcc-10 CXX=/usr/bin/g++-10 ./bootstrap --system-libs -- -DCMAKE_BUILD_TYPE:STRING=Release
RUN cd cmake-src && make
RUN cd cmake-src && make install
RUN rm -rf cmake-src
#Adding Libs but removing devel libs
RUN DEBIAN_FRONTEND=noninteractiv apt-get install -y libssl1.1 librhash0 zlib1g libcurl4 libexpat1 libarchive13 libjsoncpp1 libuv1
RUN DEBIAN_FRONTEND=noninteractiv apt-get remove -y libssl-dev librhash-dev zlib1g-dev libcurl4-openssl-dev libexpat1-dev libarchive-dev libjsoncpp-dev
#Ninja Arguments
#ARG NINJA_MAJOR_VERSION=1
#ARG NINJA_MINOR_VERSION=10
#ARG NINJA_PATCH_VERSION=0
#Downloading NINJA
#UN DEBIAN_FRONTEND=noninteractiv apt-get install -y git
#UN git clone --depth=1 --branch v${NINJA_MAJOR_VERSION}.${NINJA_MINOR_VERSION}.${NINJA_PATCH_VERSION} https://github.com/ninja-build/ninja.git ninja-src
#UN cd ninja-src && cmake -Bbuild-cmake -H.
#UN cd ninja-src && cmake --build build-cmake
#Cleaning Up
RUN DEBIAN_FRONTEND=noninteractiv apt-get clean
