FROM opensuse/tumbleweed:latest

#The choice of base image is mostly due to license issues and size.

LABEL base_image=opensuse
LABEL purpose=geoserver
RUN zypper in -y unzip wget java-11-openjdk-headless

ENV JAVA_HOME /etc/alternatives/jre
ENV GEOSERVER_VERSION 2.16.2
ENV NGDBC_VER 2.4.70

#Get the java driver for SAP HANA
WORKDIR /root
RUN wget --no-verbose "https://repo1.maven.org/maven2/com/sap/cloud/db/jdbc/ngdbc/${NGDBC_VER}/ngdbc-${NGDBC_VER}.jar"

#Get Geoserver
WORKDIR /geoserver
RUN wget --no-verbose "https://freefr.dl.sourceforge.net/project/geoserver/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip"
RUN unzip *.zip && rm -f *.zip

WORKDIR /root

# This command identifies the current geotool version from the file name
# /geoserver/geoserver-2.16.1/webapps/geoserver/WEB-INF/lib/gt-jdbc-22.2.jar => 22.2
RUN echo $(find /geoserver -name "gt-jdbc-*.jar" | grep -v postgis | cut -d '-' -f 5 | sed -e 's/\.jar//') > /root/GEOTOOLS_VER.txt
RUN cat /root/GEOTOOLS_VER.txt
# After the version is identified, fetch the corresponding geotool jdbc module for SAP HANA from a mavem mirror
RUN wget --no-verbose https://repo.boundlessgeo.com/main/org/geotools/jdbc/gt-jdbc-hana/$(</root/GEOTOOLS_VER.txt)/gt-jdbc-hana-$(</root/GEOTOOLS_VER.txt).jar

#place the two jar in the plugin folder
RUN mv *.jar $(dirname $(find /geoserver -name "gt-jdbc-*.jar" | head -1))

#set the GEOSERVER_HOME variable
ENV GEOSERVER_HOME /geoserver/geoserver-${GEOSERVER_VERSION}

CMD ${GEOSERVER_HOME}/bin/startup.sh 

EXPOSE 8080
