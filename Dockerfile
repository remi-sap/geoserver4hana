FROM openjdk:8u342-jre-slim-buster
#The choice of base image is mostly due to license issues and size.

LABEL maintainer="Remi Astier<remi.astier@sap.com>"

LABEL purpose=geoserver
RUN apt-get update && apt-get -y install wget unzip fontconfig libfreetype6

#ENV JAVA_HOME /etc/alternatives/jre
ENV GEOSERVER_VERSION=2.21.1 \
    NGDBC_VER=2.9.16 \
    GEOTOOLS_VER=24.2
ENV GEOSERVER_HOME="/geoserver"
ENV GEOSERVER_DATA_DIR="${GEOSERVER_HOME}/data_dir"
ENV GEOSERVER_CSRF_DISABLED=true

#Get Geoserver and java driver for SAP HANA
WORKDIR /geoserver
RUN wget --no-verbose "https://freefr.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip" \
  && wget --no-verbose "https://repo1.maven.org/maven2/com/sap/cloud/db/jdbc/ngdbc/${NGDBC_VER}/ngdbc-${NGDBC_VER}.jar" \
  && unzip -q *.zip && rm -f *.zip \
  && mv ngdbc*.jar $(dirname $(find /geoserver/webapps -name "gt-jdbc-postgis*.jar" | head -1)) \
  && wget --no-verbose "https://repo.osgeo.org/repository/release/org/geotools/jdbc/gt-jdbc-hana/${GEOTOOLS_VER}/gt-jdbc-hana-${GEOTOOLS_VER}.jar" \
  && mv gt-jdbc-hana-${GEOTOOLS_VER}.jar $(dirname $(find /geoserver/webapps -name "ngdbc*.jar" | head -1)) \
  && mkdir -p ${GEOSERVER_DATA_DIR} /geoserver/dlplugins

#install extensions
RUN wget --no-verbose "https://freefr.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip" -P /geoserver/dlplugins \
  && wget --no-verbose "https://freefr.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-monitor-plugin.zip" -P /geoserver/dlplugins  \
  && cd /geoserver/dlplugins \
  && (ls -1 *.zip | while read f; do unzip -q -o $f ; done)  \
  && mv *.jar $(dirname $(find /geoserver/webapps -name "ngdbc*.jar" | head -1)) \
  && cd /geoserver && rm -rf /geoserver/dlplugins

CMD ${GEOSERVER_HOME}/bin/startup.sh 

EXPOSE 8080
