#! /bin/bash

cd /opt/tomcat/webapps
mkdir fftools && cd fftools && jar -xvf ../fftools.war
sed -i -e '$ d' ./WEB-INF/config/app.prop
echo "python.exe=/opt/conda/bin/python /www/algorithm/dispatcher.py" >> ./WEB-INF/config/app.prop
echo "helloworld"
bash /opt/tomcat/bin/startup.sh
