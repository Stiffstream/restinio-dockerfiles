FROM ubuntu:18.04

# Prepare build environment
RUN apt-get update && \
    apt-get -qq -y install gcc g++ ruby \
    wget libpcre2-dev libpcre3-dev pkg-config \
	 libssl-dev \
	 git \
    libtool
RUN gem install Mxx_ru

RUN echo "*** Downloading Boost ***" \
	&& cd /tmp \
	&& wget https://sourceforge.net/projects/boost/files/boost/1.66.0/boost_1_66_0.tar.bz2

RUN echo "*** Building Boost ***" \
	&& cd /tmp \
	&& tar xaf boost_1_66_0.tar.bz2 \
	&& cd boost_1_66_0 \
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
	&& echo "MxxRu::Cpp::composite_target do; global_define 'RESTINIO_USE_BOOST_ASIO'; \
  default_runtime_mode( MxxRu::Cpp::RUNTIME_RELEASE ); \
  MxxRu::enable_show_brief; \
  global_obj_placement MxxRu::Cpp::PrjAwareRuntimeSubdirObjPlacement.new( \
    'target', MxxRu::Cpp::PrjAwareRuntimeSubdirObjPlacement::USE_COMPILER_ID ); \
	end" > local-build.rb \
	&& LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib MXX_RU_CPP_TOOLSET=gcc_linux RESTINIO_USE_BOOST_ASIO=shared ruby build.rb --mxx-cpp-release

