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
ARG expected_lite_ver=v0.4.0
ARG optional_lite_ver=v3.2.0
ARG string_view_lite_ver=v1.3.0
ARG variant_lite_ver=v1.2.2
ARG sobjectizer_ver=v5.5.24.4

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

RUN echo "*** Setting up SObjectizer ***" \
	&& cd /tmp \
	&& git clone https://github.com/eao197/so-5-5 \
	&& cd so-5-5/dev \
	&& git checkout $sobjectizer_ver \
	&& cmake -DCMAKE_INSTALL_PREFIX=$deps_path \
		-DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF \
		-DSOBJECTIZER_BUILD_STATIC=ON -DSOBJECTIZER_BUILD_SHARED=OFF . \
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

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
	&& rm -rf restinio/third_party/expected-lite \
	&& rm -rf restinio/third_party/optional-lite \
	&& rm -rf restinio/third_party/string-view-lite \
	&& rm -rf restinio/third_party/variant-lite \
	&& rm -rf so_5 \
	&& mkdir cmake_build \
	&& cd cmake_build \
	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_PREFIX_PATH=$deps_path \
		-DRESTINIO_USE_EXTERNAL_EXPECTED_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_OPTIONAL_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_STRING_VIEW_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_VARIANT_LITE=ON \
		-DRESTINIO_USE_EXTERNAL_SOBJECTIZER=ON \
		.. \
	&& cmake --build . --config Release \
	&& cmake --build . --target test \
	&& cmake --build . --target install

