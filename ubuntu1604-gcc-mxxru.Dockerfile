FROM ubuntu:16.04

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

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
	&& MXX_RU_CPP_TOOLSET=gcc_linux ruby build.rb --mxx-cpp-release

