FROM ubuntu:18.04

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ ruby \
    wget libpcre2-dev libpcre3-dev pkg-config \
	 libboost-all-dev \
	 libssl-dev \
	 git \
    libtool
RUN gem install Mxx_ru

RUN apt-get -y install tree

RUN echo "*** Getting CMake ***" \
	&& apt-get update \
	&& apt-get -y install cmake


ARG deps_path=/tmp/deps
#ARG expected_lite_ver=2dc251509466c60626bb709b288cf6751fc65271
ARG expected_lite_ver=v0.5.0
ARG optional_lite_ver=v3.5.0
ARG string_view_lite_ver=v1.6.0
ARG variant_lite_ver=v2.0.0
ARG fmt_ver=8.1.1
ARG catch2_ver=v2.13.9

RUN echo "*** Setting up expected-lite ***" \
	&& cd /tmp \
	&& git clone https://github.com/martinmoene/expected-lite \
	&& cd expected-lite \
	&& git checkout $expected_lite_ver \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DEXPECTED_LITE_OPT_BUILD_TESTS=OFF . \
	&& cmake --build . --config Release --target install

RUN echo "*** Setting up optional-lite ***" \
	&& cd /tmp \
	&& git clone https://github.com/martinmoene/optional-lite \
	&& cd optional-lite \
	&& git checkout $optional_lite_ver \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DOPTIONAL_LITE_OPT_BUILD_TESTS=OFF . \
	&& cmake --build . --config Release --target install

RUN echo "*** Setting up string-view-lite ***" \
	&& cd /tmp \
	&& git clone https://github.com/martinmoene/string-view-lite \
	&& cd string-view-lite \
	&& git checkout $string_view_lite_ver \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DSTRING_VIEW_LITE_OPT_BUILD_TESTS=OFF . \
	&& cmake --build . --config Release --target install

RUN echo "*** Setting up variant-lite ***" \
	&& cd /tmp \
	&& git clone https://github.com/martinmoene/variant-lite \
	&& cd variant-lite \
	&& git checkout $variant_lite_ver \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DVARIANT_LITE_OPT_BUILD_TESTS=OFF . \
	&& cmake --build . --config Release --target install

RUN echo "*** Setting up fmt ***" \
	&& cd /tmp \
	&& git clone https://github.com/fmtlib/fmt \
	&& cd fmt \
	&& git checkout $fmt_ver \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DFMT_TEST=OFF \
		-DFMT_MODULE=OFF \
		-DFMT_INSTALL=ON . \
	&& cmake --build . --config Release --target install

RUN echo "*** Setting up catch2 ***" \
	&& cd /tmp \
	&& git clone https://github.com/catchorg/catch2 \
	&& cd catch2 \
	&& git checkout $catch2_ver \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DCATCH_BUILD_TESTING=OFF \
		-DCATCH_INSTALL_DOCS=OFF \
		-DCATCH_INSTALL_HELPERS=OFF .. \
	&& cmake --build . --config Release --target install

ARG hgrev=HEAD

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& git clone https://github.com/stiffstream/restinio \
	&& cd restinio \
	&& git checkout $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& cd /tmp/restinio \
	&& mxxruexternals && echo "done"

RUN tree $deps_path

# libhttp_parser
RUN apt-get -qq -y install libhttp-parser-dev

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
	&& rm -rf restinio/third_party/expected-lite \
	&& rm -rf restinio/third_party/optional-lite \
	&& rm -rf restinio/third_party/string-view-lite \
	&& rm -rf restinio/third_party/variant-lite \
	&& rm -rf fmt \
	&& rm -rf fmt_mxxru \
	&& rm -rf catch2 \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_PREFIX_PATH=$deps_path \
		-DRESTINIO_USE_EXTERNAL_EXPECTED_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_OPTIONAL_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_STRING_VIEW_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_VARIANT_LITE=ON \
		-DRESTINIO_FIND_DEPS=ON \
		-DRESTINIO_FMT_HEADER_ONLY=OFF \
		-DRESTINIO_USE_EXTERNAL_HTTP_PARSER=ON \
		-DRESTINIO_SAMPLE=OFF \
		-DRESTINIO_INSTALL_SAMPLES=OFF \
		-DRESTINIO_BENCH=OFF \
		-DRESTINIO_INSTALL_BENCHES=OFF \
		.. \
	&& cmake --build . --config Release \
	&& cmake --build . --target test \
	&& cmake --build . --target install

