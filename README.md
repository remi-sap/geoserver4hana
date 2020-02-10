# geoserver4hana
Docker image of Geoserver with plugin for SAP HANA

Pull the image with

```docker pull remiremi/geoserver4hana```

Start it on port 8080 with

```docker run -d -it -p 8080:8080/tcp geoserver4hana```

Then connect to the web page at [http://localhost:8080/geoserver/](http://localhost:8080/geoserver/)

The default login/password is *admin/geoserver*, change it !
