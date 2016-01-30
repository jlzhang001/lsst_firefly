# lsst firefly

This repository is for the environment settings of framework for LSST firefly framework. The code here is mainly for environment setup, actual [frontend][1] (html, javascript & css) and [backend][2] (python algorithm) code is in separate directory.


basic coding structure
----------------------

The whole application is based on the web technology. The application is build on top of [lsst/firefly][3], to facilitate the use of firefly, we plan to use the [docker][4] for facilitate development and deployment. It creates an clean virtual environment and glues the frontend and backend code together.

The image is available on [docker hub][7] and for interest, please look at the [Dockerfile][8]

Installation
------------
Currently the following instruction assumes linux system

1. Follow the instruction on [docker][4] and **Get started with Docker** to download, and open the machine
2. clone this repository and go into it `git clone lsst-camera-visualization/lsst_firefly.git <your repository> && cd <your repository>`
3. start the docker virtual machine (for linux, it is `service docker start`, for other system, look at the official documentation)
4. run `./install.sh`


Start and Stop
----

To run the program, `cd <your directory>`, and run `./start.sh <port number>`, and go to `http://localhost:<port number>` to see the result

To stop the program, run `./stop.sh &` and also stop the docker virtual machine.

[1]: https://github.com/lsst-camera-visualization/frontend
[2]: https://github.com/lsst-camera-visualization/backend
[3]: https://github.com/lsst/firefly
[4]: https://www.docker.com/
[7]: https://hub.docker.com/r/victorren/firefly_lsst/
[8]: 








