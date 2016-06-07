#/bin/bash

function downloadMRQL {
    # URL for Apache MRQL tarball download
    MRQL_TARBALL_URL='http://mirrors.ae-online.de/apache/incubator/mrql/apache-mrql-0.9.6-incubating/apache-mrql-0.9.6-incubating-bin.tar.gz'

    # Download the MRQL Tarball to a specific folder
    wget -P $1 $MRQL_TARBALL_URL

    download_message='=> Apache MEQL downloaded successfully at '$MRQL_INSTALL_FOLDER
    echo $download_message
}

function unzipMRQL {
    # Unzip the tarball
    tar xvfz $1/apache-mrql-*.tar.gz -C $1

    echo '=> Tarball unzipped successfully'
}

function configureJarsRequiredByMRQL {
    echo ' '
    echo '-------- Checking/Downloading JAR(s) required by MRQL --------'

    # Check if java-cup-11a.jar exists
    CUP_JAR_PATH=${HOME}/.m2/repository/net/sf/squirrel-sql/thirdparty/non-maven/java-cup/11a/
    CUP_JAR_NAME=java-cup-11a.jar

    if [ -e $CUP_JAR_PATH$CUP_JAR_NAME ]
    then
        echo '=> '$CUP_JAR_NAME" file exists"
    else
        CUP_JAR_DOWNLOAD_URL=http://www2.cs.tum.edu/projects/cup/releases/java-cup-11a.jar
        echo '=> '$CUP_JAR_NAME" file is missing. Downloading from http://www2.cs.tum.edu/projects/cup/"
        wget -P $CUP_JAR_PATH $CUP_JAR_DOWNLOAD_URL 
    fi
    # end cup jar check

    # Check if jline-1.0.jar exists in maven repository
    JLINE_JAR_PATH=${HOME}/.m2/repository/jline/jline/1.0/
    JLINE_JAR_NAME=jline-1.0.jar
    if [ -e $JLINE_JAR_PATH$JLINE_JAR_NAME ]
    then
        echo '=> '$JLINE_JAR_NAME" file exists"
    else
        echo '=> '$JLINE_JAR_NAME" file is missing. Downloading from http://jline.sourceforge.net"
        JLINE_JAR_DOWNLOAD_URL=https://sourceforge.net/projects/jline/files/jline/1.0/jline-1.0.zip
        wget -P $JLINE_JAR_PATH "$JLINE_JAR_DOWNLOAD_URL"
    fi
    # end jline check

    echo '--------------- JAR(s) checking complete ---------------------'
    echo ' '
}

function configureJavaInMRQL {
    echo '--------------- Modifying Java -------------------------------'

    # Replace java home
    JAVA_HOME_TO_REPLACE=/usr/lib/jvm/java-8-oracle
    sed -i -e 's~'$JAVA_HOME_TO_REPLACE'~'$2'~g' $1/conf/mrql-env.sh

    echo '=> JAVA_HOME changed successfully to '$2
    echo '--------------- Java modification complete -------------------'
}

function configureHadoopInMRQL {
    echo ' '
    echo '--------------- Starting Hadoop Configurations ---------------'

    # 1- Replace Hadoop version with the version installed on the system
    # 2- Replace Hadoop home path
    # 3- Replace the namenode URL

    HADOOP_HOME=$2 # TODO: Find some other way to figure this out
    HADOOP_VERSION=${HADOOP_HOME##/*/} # Parse the path to get just the version e.g hadoop-2.7.0
    HADOOP_VERSION=${HADOOP_VERSION/hadoop-/} # Parse the word 'hadoop-' from the string to get 2.7.0

    echo '=> Hadoop version found : '$HADOOP_VERSION

    HADOOP_VERSION_TO_REPLACE=2.7.1

    # Replace the Hadoop version with the version Found on the system
    sed -i -e "s/$HADOOP_VERSION_TO_REPLACE/$HADOOP_VERSION/g" $1/conf/mrql-env.sh

    echo '=> Hadoop version changed successfully in mrql-env.sh'

    # Replace Hadoop Home path
    HADOOP_HOME_REPLACE='${HOME}/hadoop-${HADOOP_VERSION}'

    sed -i -e 's~'$HADOOP_HOME_REPLACE'~'$HADOOP_HOME'~g' $1/conf/mrql-env.sh

    echo '=> HADOOP_HOME changed successfully in mrql-env.sh'

    # Replace namenode URL
    DEFAULT_MRQL_FS_DEFAULT_NAME=localhost:9000
    MY_FS_DEFAULT_NAME=$3
    sed -i -e "s/$DEFAULT_MRQL_FS_DEFAULT_NAME/$MY_FS_DEFAULT_NAME/g" $1/conf/mrql-env.sh

    echo '=> FS_DEFAULT_NAME changed successfully in mrql.env.sh'
    echo '--------------- Hadoop configurations complete ---------------'
}


function configureHamaInMRQL {
    echo ' '
    echo '--------------- Starting HAMA Configurations -----------------'

    # 1- Replace HAMA_VERSION
    # 2- Replace HAMA_HOME

    HAMA_HOME=$2
    HAMA_VERSION=${HAMA_HOME##/*/} # Parse the path to get the version
    HAMA_VERSION=${HAMA_VERSION/hama-/} # Parse the word 'hama-' from the string to get 0.7.1

    echo '=> HAMA version found : '$HAMA_VERSION

    HAMA_VERSION_TO_REPLACE=0.7.0

    # Replace the Hama version with the version found on the system
    sed -i -e "s/$HAMA_VERSION_TO_REPLACE/$HAMA_VERSION/g" $1/conf/mrql-env.sh

    echo '=> HAMA_VERSION changed successfully from '$HAMA_VERSION_TO_REPLACE' to '$HAMA_VERSION' in mrql.env.sh'

    # Replace Hama home path
    HAMA_HOME_REPLACE='${HOME}/hama-${HAMA_VERSION}'
    sed -i -e 's~'$HAMA_HOME_REPLACE'~'$HAMA_HOME'~g' $1/conf/mrql-env.sh

    echo '=> HAMA_HOME changed successfully in mrql.env.sh'

    echo '--------------- End HAMA Configurations ----------------------'
    echo ' '
}

function configureSparkInMRQL {
    echo ' '
    echo '---------------- Starting SPARK Configurations ---------------'

    SPARK_HOME=$2
    echo '=> SPARK found : '$SPARK_HOME
    
    SPARK_HOME_TO_REPLACE='${HOME}/spark-1.6.0-bin-hadoop2.6'
    sed -i -e 's~'$SPARK_HOME_TO_REPLACE'~'$SPARK_HOME'~g' $1/conf/mrql-env.sh
    
    echo '=> SPARK_MASTER -> '$3

    # Spark master
    sed -i -e 's~SPARK_MASTER=yarn-client~SPARK_MASTER='$3'~g' $1/conf/mrql-env.sh

    echo ' '
    echo '---------------- End SPARK Configurations --------------------'
}

function configureFlinkInMRQL {
    echo ' '
    echo '---------------- Starting FLINK Configurations ---------------'

    FLINK_HOME=$2
    FLINK_VERSION=${FLINK_HOME##/*/} # Parse the path to get the version
    FLINK_VERSION=${FLINK_VERSION/flink-/} # Parse the word 'hama-' from the string to get 0.7.1
              
    echo '=> FLINK version found : '$FLINK_VERSION
                   
    FLINK_VERSION_TO_REPLACE=0.10.2
                        
    # Replace the Hama version with the version found on the system
    sed -i -e "s/$FLINK_VERSION_TO_REPLACE/$FLINK_VERSION/g" $1/conf/mrql-env.sh
                                  
    echo '=> FLINK_VERSION changed successfully from '$FLINK_VERSION_TO_REPLACE' to '$FLINK_VERSION' in mrql.env.sh'
                                       
    # Replace Flink home path
    FLINK_HOME_REPLACE='${HOME}/flink-${FLINK_VERSION}'
    sed -i -e 's~'$FLINK_HOME_REPLACE'~'$FLINK_HOME'~g' $1/conf/mrql-env.sh
                                                      
    echo '=> FLINK_HOME changed successfully in mrql.env.sh'
                                                           
    echo '--------------- End HAMA Configurations ----------------------'
    echo ' '
}


function executeCommands {
    echo '--------------- Executing PageRank on Hama -------------------'
   
    echo ' '
    echo '=> Deleting tmp/graph.bin* from HDFS'
    echo ' '

    $2/bin/hadoop fs -rm tmp/graph.bin*  # Delete existing graph files from bin HDFS

    echo ' '
    echo '=> Generating a graph with 10K nodes and 100K edges in HDFS'
    echo ' '

    $1/bin/mrql -dist $1/queries/RMAT.mrql 10000 100000 # Generate a graph with 100K nodes and 1M edges
    # $1/bin/mrql.bsp -dist -nodes 50 $1/queries/pagerank.mrql
    
    echo ' '
    echo '=> Running the PageRank algorithm'
    echo ' '

    # Hadoop Page Rank
    OUTPUT="$($1/bin/mrql -dist -nodes 50 $1/queries/pagerank.mrql)"
    echo ' '
    echo '=> The Total Runtime of PageRank on Hadoop is : '"${OUTPUT##*Run time: }"
    echo ' '

    # Hama Page Rank
    OUTPUT="$($1/bin/mrql.bsp -dist -nodes 50 $1/queries/pagerank.mrql)"
    
    echo ' '
    echo '=> The Total Runtime of PageRank on Hama is : '"${OUTPUT##*Run time: }"
    echo ' '

    # Spark Page Rank
    OUTPUT="$($1/bin/mrql.spark -dist -nodes 50 $1/queries/pagerank.mrql)"
    
    echo ' '
    echo '=> The Total Runtime of PageRank on Spark is : '"${OUTPUT##*Run time: }"
    echo ' '

    # FLINK Page Rank
    OUTPUT="$($1/bin/mrql.flink -dist -nodes 50 $1/queries/pagerank.mrql)"
    
    echo ' '
    echo '=> The Total Runtime of PageRank on Flink is : '"${OUTPUT##*Run time: }"
    echo ' '

    echo '------------ PageRank execution on Hama complete -------------'
}

MRQL_INSTALL_FOLDER='/Users/raja/Documents/GSoC/MRQL_Installation_Script/script_test_folder'
MRQL_HOME=$MRQL_INSTALL_FOLDER'/apache-mrql-0.9.6-incubating'

HDFS_ADDRESS=localhost:54310
HADOOP_HOME=$HADOOP_PREFIX

downloadMRQL $MRQL_INSTALL_FOLDER
unzipMRQL $MRQL_INSTALL_FOLDER
configureJarsRequiredByMRQL
configureJavaInMRQL $MRQL_HOME $JAVA_HOME
configureHadoopInMRQL $MRQL_HOME $HADOOP_HOME $HDFS_ADDRESS   # Default path of Hadoop should be configured in envirnment variables under HADOOP_PREFIX
configureHamaInMRQL $MRQL_HOME $HAMA_HOME # Default path of Hama should be configured under HAMA_HOME variable
configureSparkInMRQL $MRQL_HOME $SPARK_HOME "spark://127.0.0.1:7077"
configureFlinkInMRQL $MRQL_HOME $FLINK_HOME
executeCommands $MRQL_HOME $HADOOP_HOME

# LATER on update the spark /flink version

