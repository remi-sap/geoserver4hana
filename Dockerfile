FROM openjdk:8u242-jre-stretch
#The choice of base image is mostly due to license issues and size.

LABEL purpose=geoserver
RUN apt-get -y install wget unzip

#ENV JAVA_HOME /etc/alternatives/jre
ENV GEOSERVER_VERSION=2.16.2 \
    NGDBC_VER=2.4.70
ENV GEOSERVER_HOME=/geoserver/geoserver-${GEOSERVER_VERSION}

#Get the java driver for SAP HANA
WORKDIR /root
RUN wget --no-verbose "https://repo1.maven.org/maven2/com/sap/cloud/db/jdbc/ngdbc/${NGDBC_VER}/ngdbc-${NGDBC_VER}.jar"

#Get Geoserver
WORKDIR /geoserver
RUN wget --no-verbose "https://freefr.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip"
RUN unzip -q *.zip && rm -f *.zip

WORKDIR /root

# This command identifies the current geotool version from the file name
# /geoserver/geoserver-2.16.2/webapps/geoserver/WEB-INF/lib/gt-jdbc-22.2.jar => 22.2
RUN echo $(find /geoserver -name "gt-jdbc-*.jar" | grep -v postgis | cut -d '-' -f 5 | sed -e 's/\.jar//') > /root/GEOTOOLS_VER.txt \
    && echo "Geo tools version: $(cat /root/GEOTOOLS_VER.txt)"

# After Geotool version is identified, fetch the corresponding jdbc module for SAP HANA from a maven mirror
#web site is down
#RUN wget --no-verbose https://repo.boundlessgeo.com/main/org/geotools/jdbc/gt-jdbc-hana/$(cat /root/GEOTOOLS_VER.txt)/gt-jdbc-hana-$( cat /root/GEOTOOLS_VER.txt).jar
ADD gt-jdbc-hana-22.2.jar /root
ADD gt-jdbc-22.2.jar /root

# Also get Extension to add protocols such as Mapbox Vector (application/vnd.mapbox-vector-tile	)
RUN wget --no-verbose "https://netix.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-vectortiles-plugin.zip"
RUN unzip -q *.zip && rm -f *.zip

#place the two jar in the plugin folder (WEB-INF/lib)
RUN mv *.jar $(dirname $(find /geoserver -name "gt-jdbc-*.jar" | head -1))

RUN ls -al /geoserver

CMD ${GEOSERVER_HOME}/bin/startup.sh 

EXPOSE 8080
