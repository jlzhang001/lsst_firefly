# LSST firefly

This repository is for the environment settings of LSST visualization server framework. The code here is mainly for environment setup, actual [frontend][1] (html, javascript & css) and [backend][2] (python algorithm) code is in separate directory (as the submodules linked here).


Basic coding structure
----------------------

The whole application is based on the web technology. The application is built on top of [lsst/firefly][3]. To facilitate the use of firefly, we plan to use the [Docker][4] for deployment and development. It creates an clean virtual environment and glues the front end and back end code together.

The image is available on [Docker hub][7] and for interest, please look at the [Dockerfile][8] that created this image.

Installation using Docker
------------
Currently the following instruction assumes Linux/Unix system. The shell script might not be compatible with other types of operating systems. Note that **Docker requires Linux kernel 3.10 or higher** to be able to run. Check [here][9] for dependencies.

1. Follow the instruction on [Docker][4] and download Docker engine based on your OS. Detailed information on Docker is also available on the [documentation page][10].
2. clone this repository and go into it `git clone --recursive https://github.com/lsst-camera-visualization/lsst_firefly.git <your repository> && cd <your repository>`
3. start the Docker virtual machine service (for linux, it is `service docker start` (may require root privilege), for other operating systems, look at the [official documentation][10])
4. run `./install.sh`


Start and Stop
----

To run the program, `cd <your directory>`(the repository cloned from GIT), and run `./start.sh <port number>`, and go to `http://localhost:<port number>` to see the result

To stop the program, run `./stop.sh &` and then also stop the docker virtual machine.

If you want to login into the docker container to debug interactively, run `docker exec -it firefly bash`. This will drop the user to a bash shell inside the docker virtual machine.


Issues
------

Please use [Github Issues][11] for any bug or improvement. 

### Currently known issue

+ When killing the docker instance, there will be a defunct java process. The process is defunt at the moment but the zombie process presists. Current work around is restart the docker server (or to retart the machine).

[1]: https://github.com/lsst-camera-visualization/frontend
[2]: https://github.com/lsst-camera-visualization/backend
[3]: https://github.com/lsst/firefly
[4]: https://docs.docker.com/engine/installation/
[7]: https://hub.docker.com/r/victorren/ff_server/
[8]: https://github.com/lsst-camera-visualization/lsst_firefly/blob/master/Dockerfile
[9]: https://docs.docker.com/engine/installation/binaries/
[10]: https://docs.docker.com/engine/
[11]: https://github.com/lsst-camera-visualization/lsst_firefly/issues





