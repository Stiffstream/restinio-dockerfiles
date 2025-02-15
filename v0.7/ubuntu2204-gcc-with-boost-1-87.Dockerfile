FROM ubuntu:22.04

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ ruby \
    wget libpcre2-dev libpcre3-dev pkg-config \
	 libssl-dev \
	 git \
    libtool \
	 cmake
RUN gem install Mxx_ru

RUN echo "*** Downloading Boost ***" \
	&& cd /tmp \
	&& wget https://sourceforge.net/projects/boost/files/boost/1.87.0/boost_1_87_0.tar.bz2

RUN echo "*** Building Boost ***" \
	&& cd /tmp \
	&& tar xaf boost_1_87_0.tar.bz2 \
	&& cd boost_1_87_0 \
	&& ./bootstrap.sh --with-libraries=system,regex \
	&& ./b2 install

ARG hgrev=HEAD

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& git clone https://github.com/stiffstream/restinio \
	&& cd restinio \
	&& git checkout $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& cd /tmp/restinio \
	&& mxxruexternals

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
 	&& mkdir cmake_build \
 	&& cd cmake_build \
 	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release .. \
		-DRESTINIO_ASIO_SOURCE=boost \
		-DRESTINIO_DEP_BOOST_ASIO=system \
 	&& cmake --build . --config Release --parallel 2 \
 	&& cmake --build . --target test \
	&& cmake --build . --target install

