FROM archlinux:latest

# Prepare build environment
RUN pacman -Sy --noconfirm gcc \
	&& pacman -Sy --noconfirm ruby rubygems rake \
	&& pacman -Sy --noconfirm wget \
	&& pacman -Sy --noconfirm git \
	&& pacman -Sy --noconfirm openssl

RUN pacman -Sy --noconfirm libffi

RUN pacman -Sy --noconfirm tar gzip unzip

RUN echo "*** Getting CMake ***" \
	&& pacman -Sy --noconfirm cmake make

RUN pacman -Sy --noconfirm fakeroot sudo

RUN echo "*** Create non_root user***" \
	&& useradd non_root \
	&& mkdir /home/non_root \
	&& chown -R non_root:non_root /home/non_root \
	&& echo 'non_root ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
	&& echo 'root ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN echo "*** Installing SObjectizer ***" \
	&& cd /home/non_root \
	&& sudo -u non_root git clone https://aur.archlinux.org/sobjectizer.git \
	&& cd sobjectizer \
	&& ls \
	&& sudo -u non_root makepkg

RUN cd /home/non_root/sobjectizer \
	&& ls \
	&& pacman -U --noconfirm sobjectizer-5.8.1.1-1-x86_64.pkg.tar.zst

RUN \
	export GEM_HOME="$(ruby -e 'puts Gem.user_dir')" \
	&& export PATH="$PATH:$GEM_HOME/bin" \
	&& gem install Mxx_ru

ARG hgrev=HEAD

RUN echo "*** Downloading RESTinio ***" \
	&& cd /tmp \
	&& git clone https://github.com/stiffstream/restinio \
	&& cd restinio \
	&& git checkout $hgrev

RUN echo "*** Extracting RESTinio's Dependencies ***" \
	&& export GEM_HOME="$(ruby -e 'puts Gem.user_dir')" \
	&& export PATH="$PATH:$GEM_HOME/bin" \
	&& cd /tmp/restinio \
	&& mxxruexternals \
	&& rm -r dev/so_5

RUN echo "*** Building RESTinio ***" \
	&& cd /tmp/restinio/dev \
 	&& mkdir cmake_build \
 	&& cd cmake_build \
 	&& cmake -DCMAKE_INSTALL_PREFIX=target -DCMAKE_BUILD_TYPE=Release .. \
		-DRESTINIO_DEP_SOBJECTIZER=system \
		-DRESTINIO_SOBJECTIZER_LIB_LINK_NAME=so_s.5.8.1.1 \
 	&& cmake --build . --config Release \
 	&& cmake --build . --target test \
	&& cmake --build . --target install

