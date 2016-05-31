#/bin/bash

MRQL_INSTALL_FOLDER='/Users/raja/Documents/GSoC/MRQL_Installation_Script/script_test_folder'

# URL for Apache MRQL tarball download
MRQL_TARBALL_URL='http://mirrors.ae-online.de/apache/incubator/mrql/apache-mrql-0.9.6-incubating/apache-mrql-0.9.6-incubating-bin.tar.gz'

# Download the MRQL Tarball to a specific folder
# TODO: Checksum required ?
#wget -P ${MRQL_INSTALL_FOLDER} "${MRQL_TARBALL_URL}"

#wget "${MRQL_TARBALL_URI}"
#wget -P /Users/raja/Documents/GSoC/MRQL_Installation_Script/script_test_folder/  "${MRQL_TARBALL_URI}"

download_message='Apache MEQL downloaded successfully at '${MRQL_INSTALL_FOLDER}
#download_message=$download_message${MRQL_INSTALL_FOLDER}
echo $download_message
#echo 'Apache MRQL downloaded successfully at' + ${MRQL_INSTALL_FOLDER}

# Unzip the tarball
#tar xvfz ${MRQL_INSTALL_FOLDER}/apache-mrql-*.tar.gz -C ${MRQL_INSTALL_FOLDER}

echo 'File:  unzipped successfully'

# Check if java-cup-11a.jar exists
CUP_JAR_PATH=${HOME}/.m2/repository/net/sf/squirrel-sql/thirdparty/non-maven/java-cup/11a/
CUP_JAR_NAME=java-cup-11a.jar

if [ -e $CUP_JAR_PATH$CUP_JAR_NAME ]
then
    echo $CUP_JAR_NAME" file exists"
else
    CUP_JAR_DOWNLOAD_URL=http://www2.cs.tum.edu/projects/cup/releases/java-cup-11a.jar
    echo $CUP_JAR_NAME" file is missing. Downloading from http://www2.cs.tum.edu/projects/cup/"
    wget -P $CUP_JAR_PATH "${CUP_JAR_DOWNLOAD_URL}" 
fi
# end cup jar check

# Check if jline-1.0.jar exists in maven repository
JLINE_JAR_PATH=${HOME}/.m2/repository/jline/jline/1.0/
JLINE_JAR_NAME=jline-1.0.jar
if [ -e $JLINE_JAR_PATH$JLINE_JAR_NAME ]
then
    echo ${JLINE_JAR_NAME}" file exists"
else
    echo ${JLINE_JAR_NAME}" file is missing. Downloading from http://jline.sourceforge.net"
    JLINE_JAR_DOWNLOAD_URL=https://sourceforge.net/projects/jline/files/jline/1.0/jline-1.0.zip
    wget -P $JLINE_JAR_PATH "${JLINE_JAR_DOWNLOAD_URL}"
fi
# end jline check

# CHECK if CUP JAR exists
# CHECK if JLine JAR exists
# UPDATE hadoop version and HAMA version initially
# LATER on update the spark /flink version

