#/bin/bash

MRQL_INSTALL_FOLDER='/Users/raja/Documents/GSoC/MRQL_Installation_Script/script_test_folder'

# URL for Apache MRQL tarball download
MRQL_TARBALL_URI='http://mirrors.ae-online.de/apache/incubator/mrql/apache-mrql-0.9.6-incubating/apache-mrql-0.9.6-incubating-bin.tar.gz'

# Download the MRQL Tarball to a specific folder
# TODO: Checksum required ?
wget -P ${MRQL_INSTALL_FOLDER} "${MRQL_TARBALL_URI}"
#wget "${MRQL_TARBALL_URI}"
#wget -P /Users/raja/Documents/GSoC/MRQL_Installation_Script/script_test_folder/  "${MRQL_TARBALL_URI}"

echo 'Apache MRQL downloaded successfully at ${MRQL_INSTALL_FOLDER}'

# Unzip the tarball
tar xvfz ${MRQL_INSTALL_FOLDER}/apache-mrql-*.tar.gz -C ${MRQL_INSTALL_FOLDER}

echo 'File:  unzipped successfully'
