FROM lsiobase/alpine:3.11

# set version label
MAINTAINER Sebastian Robinson sebastian@podtwo.com

RUN \
 echo "**** install packages ****" && \
 apk upgrade && \
 apk add --no-cache  build-base automake autoconf libtool curl findutils jq openssl zlib zlib-dev unrar unzip p7zip python python-dev python3 python3-dev rsync git tar transmission-cli transmission-daemon 

COPY torrentverify.patch /tmp/

RUN \
 echo "**** install torrentiverify ****" && \
 cd /tmp/ && \
 git clone https://github.com/Wintermute0110/torrentverify.git && \
 patch -p0 <torrentverify.patch && \ 
 cp -r -p /tmp/torrentverify/torrentverify.py /usr/bin/ && \
 chmod a+rx /usr/bin/torrentverify.py 

RUN \
 echo "**** install PDMameUpdate ****" && \
 pip3 install --upgrade pip; pip3 install --no-cache-dir pipenv  && \
 cd /tmp/ && \
 git clone https://djib.fr/djib/PDMameUpdate.git && \
 cd /tmp/PDMameUpdate/ && \
 pipenv install --three --system --deploy --clear && \
 cp -r -p /tmp/PDMameUpdate/PDMameUpdate.py /usr/bin/ && \
 chmod a+rx /usr/bin/PDMameUpdate.py

RUN \
 echo "**** install trrntzip ****" && \
 cd /tmp/ && \
 git clone https://github.com/hydrogen18/trrntzip.git && \
 cd /tmp/trrntzip && \
 ./autogen.sh && \
 ./configure && \
 make && \
 make install

RUN \
 echo "**** install third party themes ****" && \
 curl -o /tmp/combustion.zip -L "https://github.com/Secretmapper/combustion/archive/release.zip" && \
 unzip /tmp/combustion.zip -d / && \
 mkdir -p /tmp/twctemp && \
 TWCVERSION=$(curl -sX GET "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
 curl -o /tmp/twc.tar.gz -L "https://github.com/ronggang/transmission-web-control/archive/${TWCVERSION}.tar.gz" && \
 tar xf /tmp/twc.tar.gz -C /tmp/twctemp --strip-components=1 && \
 mv /tmp/twctemp/src /transmission-web-control && \
 mkdir -p /kettu && \
 curl -o /tmp/kettu.tar.gz -L "https://github.com/endor/kettu/archive/master.tar.gz" && \
 tar xf /tmp/kettu.tar.gz -C /kettu --strip-components=1

RUN \	
 echo "**** cleanup ****" && \
 rm -rf /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413
VOLUME /config /data
