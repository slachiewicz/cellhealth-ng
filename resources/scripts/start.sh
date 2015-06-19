#!/bin/bash
function  usage() {
    cat << EOF
    usage: $0 options

    This script will run the  batch configuration for retrieving performance metrics
    from the specified vCenter server

    OPTIONS:
        -?	   Show this message
        -l	   Path to a log4j config file
        -c	   Path to cellhealth configuration file
    EOF
}

source /opt/IBM/WAS85/AppServer/profiles/dmgr/bin/setupCmdLine.sh

JAVA_HOME="$WAS_HOME"/java
CELLHEALTH_HOME=/opt/cellhealth-ng
LIB_DIR=${CELLHEALTH_HOME}/lib

while getopts "?:l:c:" $OPTIONS; do
     case $OPTION in
         c)
             CONFILE=$OPTARG
             ;;
         l)
             LOGFILE=$OPTARG
             ;;
         ?)
             usage
             exit 1
             ;;
     esac
done

CLASSPATH=$(JARS=("$LIB_DIR"/*.jar); IFS=:; echo "${JARS[*]}"):${WAS_HOME}/runtimes/:${WAS_HOME}/lib/

if [[ -n $LOGFILE ]]
then
    	LOG4JAVA="-Dlog4j.configuration=file:$LOGFILE"
else
    	LOG4JAVA="-Dlog4j.configuration=file:${CELLHEALTH_HOME}/conf/log4j.properties"
fi

if [[ -n $CONFFILE ]]
then
    	CONFILE="-Dch_config_path=$CONFILE"
else
    	CONFILE="-Dch_config_path=${CELLHEALTH_HOME}/conf/config.properties"
fi
MAIN_JAR=`ls -1tr ${CELLHEALTH_HOME}/bin/cellhealth-ng.*.jar|tail -1`

${JAVA_HOME}/bin/java $CONFILE $CLIENTSAS $STDINCLIENTSAS $SERVERSAS $CLIENTSOAP $CLIENTIPC $JAASSOAP $CLIENTSSL $WAS_LOGGING -cp $CLASSPATH:${CELLHEALTH_HOME}/lib $LOG4JAVA -jar ${MAIN_JAR}