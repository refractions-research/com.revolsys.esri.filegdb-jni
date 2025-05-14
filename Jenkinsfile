def checkoutBranch(folderName, url, branchName) {
  dir(folderName) {
    deleteDir()
    checkout([
      $class: 'GitSCM',
      branches: [[name: branchName]],
      doGenerateSubmoduleConfigurations: false,
      extensions: [],
      gitTool: 'Default',
      submoduleCfg: [],
      userRemoteConfigs: [[url: url]]
    ])
  }
}

node ('built-in') {
  echo 'Running on the master node!'


  //def artifactoryServer = Artifactory.server 'prod'
  //def mavenRuntime = Artifactory.newMavenBuild()
  //env.JAVA_HOME="${tool 'jdk17'}"
  //mavenRuntime.tool = 'm3' 
  //mavenRuntime.deployer releaseRepo: 'libs-release-local', snapshotRepo: 'libs-snapshot-local', server: artifactoryServer
  //mavenRuntime.resolver releaseRepo: 'repo', snapshotRepo: 'repo', server: artifactoryServer
  //mavenRuntime.deployer.deployArtifacts = false
  //def buildInfo = Artifactory.newBuildInfo()

  stage ('SCM globals') {
     sh '''
git config --global user.email "egouge@refractions.net"
git config --global user.name "Emily Gouge"
     '''
  }

  stage ('Checkout') {
    dir ('source') {
      deleteDir()
    }
    checkoutBranch('source', 'https://github.com/refractions-research/com.revolsys.esri.filegdb-jni.git', 'v1_5_3_updates');
  }
  
  stage ('Cross Platform') {
    dir ('source') {
      sh '''
npm install --loglevel silent
gulp
      '''
    }
  }
  
  stage ('Native Library Build') {

    stash includes: '''
      source/gulpfile.js,
      source/package.json,
      source/package-lock.json,
      source/target/cpp/EsriFileGdb_wrap.cpp
    ''', name: 'shared';

    stash includes: '''
      source/target/FileGDB_API_MACOSX15_64clang/include/**,
      source/target/FileGDB_API_MACOSX15_64clang/lib/**,
      source/target/classes/natives/osx_64/**
    ''', name: 'osx';

    stash includes: '''
      source/build-winnt.bat,
      source/Makefile.nmake,
      source/target/FileGDB_API_VS2022/include/**,
      source/target/FileGDB_API_VS2022/lib64/**
    ''', name: 'windows';



//    node ('macosx') {
//      dir ('source') {
//        deleteDir()
//      }
//
//      env.NODEJS_HOME = "${tool 'node-latest'}"
//      env.PATH="${env.NODEJS_HOME}/bin:${env.PATH}"
//      unstash 'shared';
//      unstash 'osx';
//      dir ('source') {
//        sh ''' 
//npm install --loglevel silent
//gulp compileOSX
//gulp linkOSX
//      '''
//      }
//      stash includes: '''
//        source/target/classes/natives/osx_64/**
//      ''', name: 'osxLib';
//    }
    
    node ('windows_agent') {
      dir ('source') {
        deleteDir()
      }

      env.PATH = env.PATH + ";c:\\Windows\\System32"
      unstash 'shared';
      unstash 'windows';
      dir ('source') {
        bat 'build-winnt.bat'
      }
      stash includes: '''
        source/target/classes/natives/windows_64/*.dll
      ''', name: 'windowsLib';
    }

//    unstash 'osxLib'
    unstash 'windowsLib'

    dir ('source') {      
      sh '''
clang++ -W -fexceptions -fPIC -O3 -m64 -DUNICODE -D_UNICODE -DUNIX -D_REENTRANT -DFILEGDB_API -D__USE_FILE_OFFSET64 -DUNIX_FILEGDB_API -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE "-I/usr/lib/jvm/default-java/include/" "-I/usr/lib/jvm/default-java/include/linux" "-Itarget/FileGDB_API_RHEL8_64/include" -DLINUX_CLANG -std=c++11 -stdlib=libstdc++ -Wno-narrowing -c target/cpp/EsriFileGdb_wrap.cpp -o target/cpp/EsriFileGdb_wrap.o
clang++ -lFileGDBAPI -v -stdlib=libstdc++ -lpthread -lrt -Ltarget/FileGDB_API_RHEL8_64/lib -shared -o target/classes/natives/linux_64/libFileGdbJni.so target/cpp/EsriFileGdb_wrap.o
      '''
    }
  

  
    stage('build') {
      dir ('source') {
        //mavenRuntime.run pom: 'pom.xml', goals: 'install', buildInfo: buildInfo
        //mavenRuntime.run pom: 'pom.xml', goals: 'install'
        sh '''
mvn install
        '''
      }
    }
    
    //stage('deploy') {
    //  dir ('source') {
        //mavenRuntime.deployer.deployArtifacts buildInfo
        //artifactoryServer.publishBuildInfo buildInfo
    //  }
    //}
  }
}
