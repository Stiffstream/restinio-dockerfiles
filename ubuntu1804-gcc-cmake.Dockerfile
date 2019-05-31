FROM ubuntu:18.04

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ ruby \
    wget libpcre2-dev libpcre3-dev pkg-config \
	 libboost-all-dev \
	 libssl-dev \
	 mercurial \
    libtool
RUN gem install Mxx_ru

ARG hgrev=tip

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& hg clone https://bitbucket.com/sobjectizerteam/restinio \
	&& cd restinio \
	&& hg up -r $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& cd /tmp/restinio \
	&& mxxruexternals

RUN echo "*** Getting CMake ***" \
	&& apt-get -y install cmake

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release .. \
	&& cmake --build . --config Release \
	&& cmake --build . --target test

