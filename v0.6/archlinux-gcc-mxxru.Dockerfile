FROM archlinux:latest

# Prepare build environment
RUN pacman -Sy --noconfirm gcc \
	&& pacman -Sy --noconfirm ruby rubygems rake \
	&& pacman -Sy --noconfirm wget \
	&& pacman -Sy --noconfirm git \
	&& pacman -Sy --noconfirm openssl

RUN pacman -Sy --noconfirm tar gzip unzip

RUN pacman -Sy --noconfirm boost

RUN \
	export GEM_HOME="$(ruby -e 'puts Gem.user_dir')" \
	&& export PATH="$PATH:$GEM_HOME/bin" \
	&& gem install Mxx_ru

ARG hgrev=HEAD
ARG cppstd=cpp14

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& git clone https://github.com/stiffstream/restinio \
	&& cd restinio \
	&& git checkout $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& export GEM_HOME="$(ruby -e 'puts Gem.user_dir')" \
	&& export PATH="$PATH:$GEM_HOME/bin" \
	&& cd /tmp/restinio \
	&& mxxruexternals

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
	&& cp local-build.rb.example local-build.rb \
	&& MXX_RU_CPP_TOOLSET=gcc_linux RESTINIO_CPP_STD=$cppstd ruby build.rb --mxx-cpp-release

