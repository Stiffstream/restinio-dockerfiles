FROM archlinux/base:latest

# Prepare build environment
RUN pacman -Sy --noconfirm gcc \
	&& pacman -Sy --noconfirm ruby rubygems rake \
	&& pacman -Sy --noconfirm wget \
	&& pacman -Sy --noconfirm mercurial

RUN pacman -Sy --noconfirm tar gzip unzip

RUN gem install Mxx_ru

ARG hgrev=tip

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& hg clone https://bitbucket.com/sobjectizerteam/restinio \
	&& cd restinio \
	&& hg up -r $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& export PATH=${PATH}:~/.gem/ruby/2.6.0/bin \
	&& cd /tmp/restinio \
	&& mxxruexternals

RUN echo "*** Getting CMake ***" \
	&& pacman -Sy --noconfirm cmake make

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
 	&& mkdir cmake_build \
 	&& cd cmake_build \
 	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release .. \
 	&& cmake --build . --config Release \
 	&& cmake --build . --target test \
	&& cmake --build . --target install

