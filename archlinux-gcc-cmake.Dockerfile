FROM archlinux/base:latest

# Prepare build environment
RUN pacman -Sy --noconfirm gcc \
	&& pacman -Sy --noconfirm ruby rubygems rake \
	&& pacman -Sy --noconfirm wget \
	&& pacman -Sy --noconfirm git \
	&& pacman -Sy --noconfirm openssl

RUN pacman -Sy --noconfirm libffi

RUN pacman -Sy --noconfirm tar gzip unzip

RUN pacman -Sy --noconfirm boost

RUN gem install Mxx_ru

RUN echo "*** Getting CMake ***" \
	&& pacman -Sy --noconfirm cmake make

ARG hgrev=HEAD

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& git clone https://github.com/stiffstream/restinio \
	&& cd restinio \
	&& git checkout $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& export PATH=${PATH}:~/.gem/ruby/2.7.0/bin \
	&& cd /tmp/restinio \
	&& mxxruexternals

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
 	&& mkdir cmake_build \
 	&& cd cmake_build \
 	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release .. \
 	&& cmake --build . --config Release \
 	&& cmake --build . --target test \
	&& cmake --build . --target install

