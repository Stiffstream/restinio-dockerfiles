FROM debian:10

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ ruby \
    wget libpcre2-dev libpcre3-dev pkg-config \
	 libboost-all-dev \
	 libssl-dev \
	 git \
    libtool
RUN gem install Mxx_ru

ARG hgrev=HEAD

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& git clone https://github.com/stiffstream/restinio \
	&& cd restinio \
	&& git checkout $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& cd /tmp/restinio \
	&& mxxruexternals

RUN echo "*** Getting CMake ***" \
	&& apt-get update \
	&& apt-get -y install cmake

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release .. \
	&& cmake --build . --config Release \
	&& cmake --build . --target test \
	&& cmake --build . --target install

