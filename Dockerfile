FROM ubuntu:latest

RUN apt-get -y update
RUN apt-get -y install curl
RUN curl -sL https://deb.nodesource.com/setup | sudo bash -
RUN apt-get -y install    \
  nodejs build-essential  \
  imagemagick             \
  # vips compilation
  gobject-introspection libglib2.0-dev libjpeg-turbo8-dev libpng12-dev \
  libwebp-dev libtiff5-dev libexif-dev libxml2-dev libmagickwand-dev

WORKDIR /tmp
RUN \
  curl -O http://www.vips.ecs.soton.ac.uk/supported/7.42/vips-7.42.0.tar.gz && \
  tar zvxf vips-7.42.0.tar.gz && \
  cd vips-7.42.0 && \
  ./configure --enable-debug=no --enable-docs=no --enable-cxx=yes --without-python --without-orc --without-fftw --without-gsf $1 && \
  make && \
  make install && \
  ldconfig

RUN apt-get autoremove && \
    apt-get autoclean && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY . /app

RUN cd /app; npm install

EXPOSE 8080

ENTRYPOINT /app/node_modules/coffee-script/bin/coffee /app/cluster.coffee
