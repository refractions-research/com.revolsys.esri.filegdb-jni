# Java bindings for the ESRI File Geodatabase API

This module provides [SWIG](https://www.swig.org) generated Java bindings for the [ESRI File Geodatabase API](https://github.com/Esri/file-geodatabase-api).


# Build Notes (Emily May, 5, 2025)

I did not link the MAC libraries for this build. We are not using them and I didn't have access to a mac node on Jenkins.
I used version 1.5.3 of the ESRT libraries. All versions can be found here: https://github.com/Esri/file-geodatabase-api



To rebuild this library I had to:

1. Download the Jenkins docker image: https://hub.docker.com/r/jenkins/jenkins
   
   I used the latest docker image.

1. Run docker:
   ```   
   docker run -d --name jenkins -p 8080:8080 -p 50000:50000 jenkins/jenkins:latest
   ```

1. Log into the docker console as root and setup a number of tools on the docker instance:

   ```
   docker ps
   docker exec -U 0 -it <CID> bash

   apt update
   apt upgrade
   apt install npm
   apt install maven
   apt install swig
   apt install clang
   apt install default-jdk   

   npm install -g gulp-cli
   ```

   I don't think these are need but I did come across them in debugging:
   ```
   npm install -g gulp
   npm install --save-dev gulp@4
   ```

1. Setup Jenkins via the web interface using the defaults

1. On Jenkins (via the web interface) installed the GitHub Integration Plugin

   Settings -> Plugins
   
   Added: "GitHub Integration Plugin"

1. On Jenkins (via the web interface) configured a number of Tools

   Settings -> Tools

   Git Installations -> Ensure this was setup correctly 

1. On local windows machine, download and install the community edition of Visual Studio. In this case I used version 2022 to match the ESRI build version.

1. In Jenkins create a windows-agent node (Settings -> Nodes), 
   ```
   Name: windows_agent
   Number of executors: 1
   Remote root directory: C:\data\Jenkins
   Labels: windows
   Uages: Use this node as much as possible
   Launch method: Launch agent by connecting it to the controller
   Availability: Keep this agent online as much as possible
   ```
   After setup click on the 'Status' of the node you'll get a command to run on your local computer to run the window agent.
   
   Something similar to:
   ```
   curl.exe -sO http://localhost:8080/jnlpJars/agent.jar
   java -jar agent.jar -url http://localhost:8080/ -secret <SECRET> -name "windows_agent" -webSocket -workDir "C:\data\Jenkins"
   ```
   
1. Updated the versions of all the files in the project to point to the versions being used:
   ```
   build-winnt.bat -> Microsoft Visual Studio version & VC\Tools\MSVC
   gulpfile.js -> filefgdb version, and all the locations where these files are referenced
   Jenkinsfile -> all the filefgdb versions, for the clang++ command I also updated the reference to the java include and include/linux 
   pom.xml -> updated the version number
   ```

1. Create a new Jenkins build item. 
   ```
   Type: Pipeline
   Name: Build
   GitHubProject -> selected
   Project url: https://github.com/refractions-research/com.revolsys.esri.filegdb-jni/
   Pipeline Definition: Pipeline script from SCM
   SCM: Git
   Repository URL: https://github.com/refractions-research/com.revolsys.esri.filegdb-jni
   Credientials: I added some github credentitial shere
   Branch Specifier: */v1_5_3_updates
   Script Pather: Jenkinsfile
   ```
   
1. Run the newly created build item.

   Once run succesfully, log into the docker instance and do the last few maven commands manually:
   ```
   docker ps
   docker exec -U 0 -it <CID> bash

   cd /var/jenkins_home/workspace/<buildname>/source

   mvn compile
   mvn package
   mvn install
   ```
   
   This will install into the local docker repo: /root/.m2/repository/com/revolsys/esri/filegdb-jni/1.5.3-1/

1. Copy the build files off the docker instance and put them into our github maven repo:

   https://github.com/refractions-research/mvnrepository

   To copy the files off docker you can use this command:
   docker cp 97dc9dd5c6bc:/root/.m2/repository/com/revolsys/esri/filegdb-jni/1.5.3-1/filegdb-jni-1.5.3-1.jar <localpath>


