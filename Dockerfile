FROM debian:jessie

MAINTAINER Igor Afanasyev <igor.afanasyev@gmail.com>

# Serge version to install
ENV SERGE_VERSION master

# default command to run
# This will just make the container always idling
# so that we can run commands in it later
CMD /bin/sh -c "while true; do sleep 1; done"

# update package repo information
RUN apt-get -qq update

### Download and unpack Serge

# install wget and unzip utilities (be quiet; answer yes to all the questions)
RUN apt-get -qq -y install wget unzip

# switch to this directory
WORKDIR /usr/lib

# download required Serge version (be quiet; save to serge-<version>.zip)
RUN wget -q https://github.com/evernote/serge/archive/$SERGE_VERSION.zip -O serge-$SERGE_VERSION.zip

# unpack the archive (it will create /usr/lib/serge-<version> subfolder)
RUN unzip serge-$SERGE_VERSION.zip

# delete the archive, since it is no longer needed
RUN unlink serge-$SERGE_VERSION.zip

### Install system prerequisites and required Perl modules

# install build essentials to compile prerequisite Perl modules
# (be quiet; answer yes to all the questions)
RUN apt-get -qq -y install build-essential libssl-dev libexpat-dev

# install cpanm tool (package App::cpanminus) from CPAN
RUN cpan App::cpanminus

### Install Perl modules

# switch to app folder
WORKDIR /usr/lib/serge-$SERGE_VERSION

# install dependency Perl modules using cpanm
RUN cpanm --installdeps .

# run tests
RUN cpanm --test-only .

# clean temporary Build files
RUN ./Build distclean

### Create symlinks

# go back to the parent directory
WORKDIR /usr/lib

# map `/usr/lib/serge-<version>` folder to `/usr/lib/serge`
RUN ln -s serge-$SERGE_VERSION serge

# add symlink to `serge`
RUN ln -s /usr/lib/serge/bin/serge /usr/bin/serge
