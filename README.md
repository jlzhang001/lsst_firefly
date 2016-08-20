# LSST firefly

This repository is for the environment settings of LSST visualization server framework. The code here is mainly for environment setup, actual [frontend][1] (html, javascript & css) and [backend][2] (python algorithm) code is in separate directory (as the submodules linked here).


##Basic coding structure

The whole application is based on the web technology. The application is built on top of [lsst/firefly][3]. To facilitate the use of firefly, we plan to use the [Docker][4] for deployment and development. It creates an clean virtual environment and glues the front end and back end code together.

The image is available on [Docker hub][7] and for interest, please look at the [Dockerfile][8] that created this image.

##Installation

###Using Docker Engine
Currently the following instruction assumes Linux/Unix system. The shell script might not be compatible with other types of operating systems. Note that **Docker requires Linux kernel 3.10 or higher** to be able to run. Check [here][9] for dependencies.

1. Follow the instruction on [Docker][4] and download Docker engine based on your OS. Detailed information on Docker is also available on the [documentation page][10].
2. clone this repository and go into it `git clone --recursive https://github.com/lsst-camera-visualization/lsst_firefly.git <your repository> && cd <your repository>`
3. start the Docker virtual machine service (for linux, it is `service docker start` (may require root privilege), for other operating systems, look at the [official documentation][10])
4. run `./install.sh`

###On local machine
Alternatively, the procedures in the Dockerfile can be reproduced on local machine but the user has to take care of those commands. 

1. First build `fftools.war` based on the instruction of [Firefly][3]. Dependencies and commands are also listed on the page. After building `fftools.war`, Oracle Java 8 should exist in the `$PATH` and Tomcat will be able to find it.
2. Check out the lastest version of [front end][1] and [back end][2] code.
3. Deploy [Tomcat 7+][13] on local machine either by package manager or downloading the binary from [Tomcat website][12]. Before starting Tomcat server, we need to modify `$CATALINA_HOME/conf/server.xml` to specify the code directory.
    - If you install Tomcat using package manager, look for the directory where Tomcat configuration file exists. For example, `/etc/tomcat7/server.xml` is the server configuration of `tomcat7` installed by `apt-get` on Ubuntu 14.04.
    - Otherwise you should be aware of where `$CATALINA_HOME` points to. For example, if you use the binary downloaded from Tomcat official website, environmental variable `$CATALINA_HOME` can be set to the directory where tomcat files being extracted and `$CATALINA_HOME/conf/server.xml` is the configuration file.
    
    You can also change the port 8080 to other ports (port number under 1024 usually requires root privilege).

4. Copy `fftools.war` (built in step 1) to `$CATALINA_HOME/webapps`.
5. Add the following line in the `<Host> ... </Host>` block in  `$CATALINA_HOME/conf/server.xml`:

    ```xml
    <Context docBase="/path/to/your/frontend/code" path="/name of the app" />
    ```
    For instance, if you check out the front end code into `/home/user_name/lsst/frontend`, then the line would be:
    ```xml
    <Context docBase="/home/user_name/lsst/frontend" path="/static" />
    ```
    
6. Edit `$CATALINA_HOME/webapps/fftools/WEB-INF/config/app.prop` (assume back end code is cloned into `/home/user_name/lsst/backend/`) :
    ```
    python.exe= "/path/to/python /home/user_name/lsst/backend/dispatcher.py"
    ```
    - If `fftools/` directory does not exists in `$CATALINA_HOME/webapps/`, you can start the tomcat service first and visit `localhost:8080/fftools` or manually unzip the war file into `$CATALINA_HOME/webapps/fftools/`.
    - Look at [this documentation][14] from Firefly if you want to change how firefly handles FITS files.
    
Now you can start the server.

## Start and Stop

To run the program, `cd <your directory>`(the repository cloned from GIT), and run `./start.sh <port number>`, and go to `http://localhost:<port number>` to see the result

To stop the program, run `./stop.sh &` and then also stop the docker virtual machine.

If you want to login into the docker container to debug interactively, run `docker exec -it firefly bash`. This will drop the user to a bash shell inside the docker virtual machine.


## Issues

Please use [Github Issues][11] for any bug or improvement.

### Currently known issue

+ ~~When killing the docker instance, there will be a defunct java process. The process is defunt at the moment but the zombie process presists. Current work around is restart the docker server (or to retart the machine).~~

[1]: https://github.com/lsst-camera-visualization/frontend
[2]: https://github.com/lsst-camera-visualization/backend
[3]: https://github.com/Caltech-IPAC/firefly
[4]: https://docs.docker.com/engine/installation/
[7]: https://hub.docker.com/r/victorren/ff_server/
[8]: https://github.com/lsst-camera-visualization/lsst_firefly/blob/master/Dockerfile
[9]: https://docs.docker.com/engine/installation/binaries/
[10]: https://docs.docker.com/engine/
[11]: https://github.com/lsst-camera-visualization/lsst_firefly/issues
[12]: https://tomcat.apache.org/download-70.cgi
[13]: https://tomcat.apache.org
[14]: https://github.com/Caltech-IPAC/firefly/blob/dev/docs/server-settings-for-fits-files.md
