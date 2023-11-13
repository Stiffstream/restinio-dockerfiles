FROM ubuntu:22.04

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ \
    wget pkg-config \
	 libssl-dev \
	 git \
    libtool \
	 cmake

# Setting up RESTinio dependencies.

# http-parser
RUN apt-get -qq -y install libhttp-parser-dev

## Catch2 is necessary if RESTinio is configured with RESTINIO_FIND_DEPS.
#ARG catch2_ver=2.13.9
#RUN echo "*** Obtaining Catch2 ***" \
#	&& cd /tmp \
#	&& wget -O catch-v${catch2_ver}.tar.gz https://github.com/catchorg/Catch2/archive/refs/tags/v${catch2_ver}.tar.gz \
#	&& tar xaf catch-v${catch2_ver}.tar.gz \
#	&& cd Catch2-${catch2_ver} \
#	&& mkdir cmake_build \
#	&& cd cmake_build \
#	&& cmake -DCMAKE_INSTALL_PREFIX=/tmp/libs \
#		-DCATCH_BUILD_TESTING=OFF \
#		-DCATCH_ENABLE_WERROR=OFF \
#		-DCATCH_INSTALL_DOCS=OFF \
#		-DCATCH_INSTALL_HELPERS=OFF \
#		.. \
#	&& cmake --build . --config Release --target install

# fmtlib is required for RESTinio.
ARG fmtlib_ver=8.1.1
RUN echo "*** Obtaining fmtlib ***" \
	&& cd /tmp \
	&& wget -O fmtlib-v${fmtlib_ver}.tar.gz https://github.com/fmtlib/fmt/archive/${fmtlib_ver}.tar.gz \
	&& tar xaf fmtlib-v${fmtlib_ver}.tar.gz \
	&& cd fmt-${fmtlib_ver} \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=/tmp/libs \
		-DFMT_TEST=OFF \
		.. \
	&& cmake --build . --config Release --target install

# Standalone Asio is required.
ARG asio_ver=1-21-0
RUN echo "*** Obtaining Asio ***" \
	&& cd /tmp \
	&& wget -O asio-v${asio_ver}.tar.gz https://github.com/chriskohlhoff/asio/archive/asio-${asio_ver}.tar.gz \
	&& tar xaf asio-v${asio_ver}.tar.gz \
	&& ls -lA \
	&& cd asio-asio-${asio_ver} \
	&& mkdir /tmp/libs/include/asio \
	&& cp -r asio/include/* /tmp/libs/include/asio

# Obtaining and building RESTinio.
ARG restinio_ver=0.6.16
RUN echo "*** Obtaining RESTinio ***" \
	&& cd /tmp \
	&& wget -O restinio-v${restinio_ver}.tar.gz https://github.com/Stiffstream/restinio/archive/refs/tags/v.${restinio_ver}.tar.gz \
	&& tar xaf restinio-v${restinio_ver}.tar.gz \
	&& ls -lA \
	&& cd restinio-v.${restinio_ver}/dev \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=/tmp/libs \
		-DRESTINIO_USE_EXTERNAL_HTTP_PARSER=ON \
		-DRESTINIO_FIND_DEPS=ON \
		-DRESTINIO_TEST=OFF \
		-DRESTINIO_SAMPLE=OFF \
		-DRESTINIO_ALLOW_SOBJECTIZER=OFF \
		-DRESTINIO_FMT_HEADER_ONLY=OFF \
		-DRESTINIO_SAMPLE=OFF -DRESTINIO_INSTALL_SAMPLES=OFF \
		-DRESTINIO_BENCH=OFF -DRESTINIO_INSTALL_BENCHES=OFF \
		.. \
	&& cmake --build . --config Release --target install

RUN ls -rlA /tmp/libs/**/*

