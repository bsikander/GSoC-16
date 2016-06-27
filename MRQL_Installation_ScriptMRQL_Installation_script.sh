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

function getVersionFromName {
    local NAME=$1
    
    VERSION=${NAME##/*/} # Parse the path to get just the complete name e.g. hadoop-2.7.0
    VERSION=${VERSION#*-} # Parse out the name of system and just return the version e.g. 2.7.0
    echo "$VERSION"
}

function searchAndReplace {
    sed -i -e 's~'$2'~'$3'~g' $1/conf/mrql-env.sh
}

function configureHadoopInMRQL {
    echo ' '
    echo '--------------- Starting Hadoop Configurations ---------------'

    # 1- Replace Hadoop version with the version installed on the system
    # 2- Replace Hadoop home path
    # 3- Replace the namenode URL

    local HADOOP_VERSION=$(getVersionFromName $2)
    echo '=> Hadoop version found : '$HADOOP_VERSION

    local HADOOP_VERSION_TO_REPLACE=2.7.1

    # Replace the Hadoop version with the version Found on the system
    searchAndReplace $1 $HADOOP_VERSION_TO_REPLACE $HADOOP_VERSION

    echo '=> Hadoop version changed successfully in mrql-env.sh'

    # Replace Hadoop Home path
    local HADOOP_HOME_REPLACE='${HOME}/hadoop-${HADOOP_VERSION}'
    searchAndReplace $1 $HADOOP_HOME_REPLACE $HADOOP_HOME

    echo '=> HADOOP_HOME changed successfully in mrql-env.sh'

    # Replace namenode URL
    local DEFAULT_MRQL_FS_DEFAULT_NAME=localhost:9000
    local MY_FS_DEFAULT_NAME=$3
    searchAndReplace $1 $DEFAULT_MRQL_FS_DEFAULT_NAME $MY_FS_DEFAULT_NAME

    echo '=> FS_DEFAULT_NAME changed successfully in mrql.env.sh'
    echo '--------------- Hadoop configurations complete ---------------'
}


function configureHamaInMRQL {
    echo ' '
    echo '--------------- Starting HAMA Configurations -----------------'

    # 1- Replace HAMA_VERSION
    # 2- Replace HAMA_HOME

    local HAMA_VERSION=$(getVersionFromName $2)
    echo '=> HAMA version found : '$HAMA_VERSION

    local HAMA_VERSION_TO_REPLACE=0.7.0

    # Replace the Hama version with the version found on the system
    searchAndReplace $1 $HAMA_VERSION_TO_REPLACE $HAMA_VERSION

    echo '=> HAMA_VERSION changed successfully from '$HAMA_VERSION_TO_REPLACE' to '$HAMA_VERSION' in mrql.env.sh'

    # Replace Hama home path
    local HAMA_HOME_REPLACE='${HOME}/hama-${HAMA_VERSION}'
    searchAndReplace $1 $HAMA_HOME_REPLACE $HAMA_HOME

    echo '=> HAMA_HOME changed successfully in mrql.env.sh'

    echo '--------------- End HAMA Configurations ----------------------'
    echo ' '
}

function configureSparkInMRQL {
    echo ' '
    echo '---------------- Starting SPARK Configurations ---------------'

    local SPARK_HOME=$2
    echo '=> SPARK found : '$SPARK_HOME
    
    local SPARK_HOME_TO_REPLACE='${HOME}/spark-1.6.0-bin-hadoop2.6'
    searchAndReplace $1 $SPARK_HOME_TO_REPLACE $SPARK_HOME

    echo '=> SPARK_MASTER -> '$3
    searchAndReplace $1 'SPARK_MASTER=yarn-client' 'SPARK_MASTER='$3
    
    echo ' '
    echo '---------------- End SPARK Configurations --------------------'
}

function configureFlinkInMRQL {
    echo ' '
    echo '---------------- Starting FLINK Configurations ---------------'
          
    local FLINK_VERSION=$(getVersionFromName $2)
    echo '=> FLINK version found : '$FLINK_VERSION
                   
    FLINK_VERSION_TO_REPLACE=0.10.2
                        
    # Replace the Hama version with the version found on the system
    searchAndReplace $1 $FLINK_VERSION_TO_REPLACE $FLINK_VERSION  

    echo '=> FLINK_VERSION changed successfully from '$FLINK_VERSION_TO_REPLACE' to '$FLINK_VERSION' in mrql.env.sh'
                                       
    # Replace Flink home path
    local FLINK_HOME_REPLACE='${HOME}/flink-${FLINK_VERSION}'
    searchAndReplace $1 $FLINK_HOME_REPLACE $FLINK_HOME      

    echo '=> FLINK_HOME changed successfully in mrql.env.sh'
                                                           
    echo '--------------- End HAMA Configurations ----------------------'
    echo ' '
}


# $1 -> Path of MRQL
# $2 -> Platform to use e.g. mrql-spark
# $3 -> Total workers to use 
# $4 -> Algorithm to execute
function executeCommand {
    # Hadoop Page Rank
    COMMAND="$($1/bin/$2 -dist -nodes $3 $1/queries/$4)"
    echo ' '
    #echo '=> The Total Runtime of '$4' on '$2' is : '"${OUTPUT##*Run time: }"
    
    local output="${COMMAND##*Run time: }" # Execute the command

    local replace=" secs"
    local replace_with=" "
    output="${output//$replace/$replace_with}"

    echo '=> The Total Runtime of '$4' on '$2' is : '$output
    echo ' '

    local resultvar=$5
    local result=$output
    eval $resultvar="'$result'"
}

function performBenchmark {
    echo '--------------- Executing PageRank on Hama -------------------'
   
    echo ' '
    echo '=> Deleting tmp/graph.bin* from HDFS'
    echo ' '

    $2/bin/hadoop fs -rm tmp/graph.bin*  # Delete existing graph files from bin HDFS

    echo ' '
    echo '=> Generating a graph with 10K nodes and 100K edges in HDFS'
    echo ' '

    $1/bin/mrql -dist $1/queries/RMAT.mrql 10000 100000 # Generate a graph with 100K nodes and 1M edges

    echo ' '
    echo '=> Running the PageRank algorithm'
    echo ' '

    executeCommand $1 'mrql' $3 'pagerank.mrql' output_hadoop # Run page rank on Hadoop using 4 reducers
    executeCommand $1 'mrql.bsp' $3 'pagerank.mrql' output_hama # Run page rank on Hama using 4 BSP workers
    executeCommand $1 'mrql.spark' $3 'pagerank.mrql' output_spark # Run page rank on Spark using 4 Slave workers
    executeCommand $1 'mrql.flink' $3 'pagerank.mrql' output_flink # Run page rank on Flink using 4 flink workers

    echo '------------ PageRank execution on Hama complete -------------'

    outputBenchmarkResult $output_hadoop $output_hama $output_spark $output_flink
}

function outputBenchmarkResult {
    echo '----------------- Writing benchmark results ----------------'

echo $1 $2 $3 $4

cat > result.html <<- _EOF_

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
         <title>Bechmark of Hama against Flink and Spark</title>
    </head>

    <body>
        <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
        <div id="chart_div"></div>

        <script type='text/javascript'>//<![CDATA[
        google.charts.load('current', {packages: ['corechart', 'bar']});
        google.charts.setOnLoadCallback(drawRightY);
        
        function drawRightY() {
                 var data = google.visualization.arrayToDataTable([
                                            ['Platform', 'Hadoop', 'Hama', 'Spark', 'Flink'],
                                            ['Page Rank', $1,$2, $3, 20],
                                            ['Word Count', 7,7, 3, 10],
                                        ]);
                var options = {
                                chart: {
                                    title: 'Page Rank Algorithm Benchmark',
                                    subtitle: 'Based on the results collected from Apache MRQL'
                                },
                                hAxis: {
                                    title: 'Total Time',
                                    minValue: 0,
                                },
                                vAxis: {
                                    title: 'Algorithm'
                                },
                                bars: 'horizontal',
                                axes: {
                                        y: {
                                             0: {side: 'right'}
                                        }
                                }
                            };
                            
                            var material = new google.charts.Bar(document.getElementById('chart_div'));
                            material.draw(data, options);
        }
                                                                                                                                                                                                                                                                                 //]]>
                                                                                                                                                                                                                                                                                 </script>
</body>
</html>

_EOF_
}

function testOutput {
    local  result=$1
    local  myresult='some value'
    eval $result="'$myresult'"
}

# => Following properties need to be configured to the execution of script
MRQL_INSTALL_FOLDER='/Users/raja/Documents/GSoC/MRQL_Installation_Script/script_test_folder'
MRQL_HOME=$MRQL_INSTALL_FOLDER'/apache-mrql-0.9.6-incubating'
HDFS_ADDRESS=localhost:54310
SPARK_MASTER=spark://127.0.0.1:7077
MRQL_NODES=4

# Note: Currently only executes PageRank algorithm
# => End

testOutput result_output
echo $result_output
#outputBenchmarkResult

getVersionFromName $HAMA_HOME
downloadMRQL $MRQL_INSTALL_FOLDER
unzipMRQL $MRQL_INSTALL_FOLDER
configureJarsRequiredByMRQL
configureJavaInMRQL $MRQL_HOME $JAVA_HOME
configureHadoopInMRQL $MRQL_HOME $HADOOP_HOME $HDFS_ADDRESS   # Default path of Hadoop should be configured in envirnment variables under HADOOP_HOME
configureHamaInMRQL $MRQL_HOME $HAMA_HOME # Default path of Hama should be configured under HAMA_HOME variable
configureSparkInMRQL $MRQL_HOME $SPARK_HOME $SPARK_MASTER
#configureFlinkInMRQL $MRQL_HOME $FLINK_HOME
performBenchmark $MRQL_HOME $HADOOP_HOME $MRQL_NODES

# LATER on update the spark /flink version

