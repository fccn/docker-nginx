# Docker image for a generic Nginx web application server

[![Build Status](https://dev.azure.com/pcosta-fccn/Docker%20base%20images/_apis/build/status/fccn.docker-nginx?branchName=master)](https://dev.azure.com/pcosta-fccn/Docker%20base%20images/_build/latest?definitionId=6&branchName=master)

A docker image based on Alpine for Nginx with configuration support for reverse proxy and simplesamlphp.
The following additional settings are used:

- Nginx configurations on $NGINX_OPTS folder (defaults to /opt/nginx)
for easier overrides
- Location of NGINX_OPTS and NGINX_ROOT folders can be set as build argument
- Clean sites-enabled folder on $NGINX_OPTS/sites-enabled
- Local copy of [H5bp]() configurations at $NGINX_ROOT/h5bp
- Customized init script that starts and monitors the required processes for the webserver
- Using Nginx v1.15.12
- Alpine 3.8

## Requirements

To build this container you need to have docker installed. A makefile is provided along with the project to facilitate
building and publishing of the images.

## Configure and Install

Check the **deploy.env** file for build configurations for both the production and development images. To publish the image you will
need to change the **DOCKER_REPO** var to your repository location. This can also be a private repository location.

## Building the docker image

To create the image run:
```
make image
```

To create and publish a new version of the image run:
```
make release
```

For more information on what it is possible to do

```
make help
```

## Usage

To correctly use this image as a Nginx web server the following is required:

- You can use this image directly to serve static html content.
- You need to define the site configuration on the sites-enabled folder located under **$NGINX_OPTS/sites-enabled**, check *test/config/sites-enabled* for examples.
- Import the html content to the root folder defined in the site settings.
- The container entrypoint script needs to be executed by root. The entrypoint script starts and monitors the required processes for the webserver.

To check the sample site provided with this project run:

```
$ make test
```
You can then access the test page at http://localhost:10080 (if defaults are being used)

Alternatively, create an application specific Dockerfile to generate a new image that includes the necessary content and additional configurations:

```
FROM stvfccn/nginx_proxy

#--- additional NGINX general configurations
COPY config/my-nginx-general-settings.conf $NGINX_OPTS/conf.d/90-general-configs.conf

#--- NGINX site configuration
COPY config/my-site-settings.conf $NGINX_OPTS/sites-enabled/my-site-settings.conf

USER application

#--- copy application contents
WORKDIR $WEB_DOCUMENT_ROOT
COPY my-site-contents .

# run this container as root because of entrypoint script or replace with new entrypoint
USER root

```

### Usage with docker-compose

Use the following sample compose file to start this container in docker-compose:

```yaml
version: '3.4'
services:

  nginx:
    image: stvfccn/nginx_proxy
    container_name: nginx_proxy
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./sites-enabled:/opt/nginx/sites-enabled   # site configurations
      - ./conf.d:/opt/nginx/conf.d                 # additional nginx configs
      - ./certs:/opt/nginx/ssl                     # ssl certificates
      - ./webcontent:/var/www                      # html static content

#-- other services

```

In the example above the site configurations are defined in **sites-enabled** folder, additional nginx configurations can be set on the **conf.d** folder, the ssl certificates are located in the **certs** folder and the html static content at the **webcontent** folder.

## Author

Paulo Costa

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/fccn/docker-npn-webapp-base/tags).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
