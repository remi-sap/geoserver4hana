# geoserver4hana
Docker image of Geoserver with plugin for SAP HANA.

It consists of GeoServer version 2.21.1 with two extensions:
 * SAP HANA database plugin [tutorial on docs.geoserver.org](https://docs.geoserver.org/latest/en/user/community/hana/index.html)
 * [Vector Tiles Extension](https://docs.geoserver.org/latest/en/user/extensions/vectortiles/install.html)
 * [Monitoring Extension](https://docs.geoserver.org/latest/en/user/extensions/monitoring/index.html)

Pull the image with

```docker pull remiremi/geoserver4hana```

Start it on port 8080 with

```
mkdir /tmp/geoserver_data
docker run -d -it -p 8080:8080/tcp -v /tmp/geoserver_data:/geoserver/data_dir remiremi/geoserver4hana
```

Then connect to the web page at [http://localhost:8080/geoserver/](http://localhost:8080/geoserver/)

The default login/password is *admin/geoserver*, change it !
