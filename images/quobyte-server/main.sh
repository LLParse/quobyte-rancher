#!/bin/bash

function replaceOrAddParam () {
    local config_file=$1
    local config_param=$2
    local config_value=$3

    if grep ^"$config_param" "$config_file";then
        sed -i "s/$config_param=.*/$config_param=$config_value/" "$config_file"
    else
        # param not present so far, add at the end
        echo "$config_param"="$config_value" >> "$config_file"
    fi
}

function rancher_agent_ip () {
    while true; do
        local agent_ip=$(curl -s http://rancher-metadata.rancher.internal/2015-12-19/self/host/agent_ip)
        if [ "$agent_ip" == "" ]; then
            sleep 1 && continue
        else
            echo $agent_ip && return 0
        fi
    done
}

function get_debug_level () {
    local log_level=$1
    local debug_levels=(EMERG ALERT CRIT ERR WARNING NOTICE INFO DEBUG)
    local debug_level=6
    for (( i=0; i<${#debug_levels[@]}; i++ )); do
        if [ "$log_level" == "${debug_levels[$i]}" ]; then
            debug_level=$i
            break
        fi
    done
    echo $debug_level
}

uname -a

if [ "$QUOBYTE_NETWORK" == "host" ]; then export HOST_IP=$(rancher_agent_ip); fi

echo registry=$QUOBYTE_REGISTRY > /etc/quobyte/host.cfg

if [ -n "$QUOBYTE_RPC_PORT" ]; then echo rpc.port=$QUOBYTE_RPC_PORT > /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_HTTP_PORT" ]; then echo http.port=$QUOBYTE_HTTP_PORT >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_API_PORT" ]; then echo api.port=$QUOBYTE_API_PORT >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_S3_HOSTNAME" ]; then echo s3.hostname=$QUOBYTE_S3_HOSTNAME >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_S3_PORT" ]; then echo s3.port=$QUOBYTE_S3_PORT >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_S3_SECURE_PORT" ]; then echo s3.secure.port=$QUOBYTE_S3_SECURE_PORT >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_WEBCONSOLE_PORT" ]; then echo webconsole.port=$QUOBYTE_WEBCONSOLE_PORT >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_EXTRA_SERVICE_CONFIG" ]; then echo $QUOBYTE_EXTRA_SERVICE_CONFIG >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_DEBUG_PORT" ]; then echo REMOTE_DEBUGGING_PORT=$QUOBYTE_DEBUG_PORT >> /etc/default/quobyte; fi
if [ -n "$QUOBYTE_ENABLE_ASSERTIONS" ]; then echo ENABLE_ASSERTIONS=$QUOBYTE_ENABLE_ASSERTIONS >> /etc/default/quobyte; fi
if [ -n "$HOST_IP" ]; then echo public_ip=$HOST_IP >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi
if [ -n "$QUOBYTE_LOG_LEVEL" ]; then echo debug.level=$(get_debug_level $QUOBYTE_LOG_LEVEL) >> /etc/quobyte/$QUOBYTE_SERVICE.cfg; fi

if [ -n "$QUOBYTE_MAX_MEM_REGISTRY" ]; then replaceOrAddParam "/etc/default/quobyte" "MAX_MEM_REGISTRY" "$QUOBYTE_MAX_MEM_REGISTRY"; fi
if [ -n "$QUOBYTE_MAX_MEM_METADATA" ]; then replaceOrAddParam "/etc/default/quobyte" "MAX_MEM_METADATA" "$QUOBYTE_MAX_MEM_METADATA"; fi
if [ -n "$QUOBYTE_MAX_MEM_DATA" ]; then replaceOrAddParam "/etc/default/quobyte" "MAX_MEM_DATA" "$QUOBYTE_MAX_MEM_DATA"; fi
if [ -n "$QUOBYTE_MAX_MEM_API" ]; then replaceOrAddParam "/etc/default/quobyte" "MAX_MEM_API" "$QUOBYTE_MAX_MEM_API"; fi
if [ -n "$QUOBYTE_MAX_MEM_WEBCONSOLE" ]; then replaceOrAddParam "/etc/default/quobyte" "MAX_MEM_WEBCONSOLE" "$QUOBYTE_MAX_MEM_WEBCONSOLE"; fi
if [ -n "$QUOBYTE_MAX_MEM_S3" ]; then replaceOrAddParam "/etc/default/quobyte" "MAX_MEM_S3" "$QUOBYTE_MAX_MEM_S3"; fi
if [ -n "$QUOBYTE_MIN_MEM_METADATA" ]; then replaceOrAddParam "/etc/default/quobyte" "MIN_MEM_METADATA" "$QUOBYTE_MIN_MEM_METADATA"; fi
if [ -n "$QUOBYTE_MIN_MEM_DATA" ]; then replaceOrAddParam "/etc/default/quobyte" "MIN_MEM_DATA" "$QUOBYTE_MIN_MEM_DATA"; fi
if [ -n "$QUOBYTE_MIN_MEM_REGISTRY" ]; then replaceOrAddParam "/etc/default/quobyte" "MIN_MEM_REGISTRY" "$QUOBYTE_MIN_MEM_REGISTRY"; fi
if [ -n "$QUOBYTE_MIN_MEM_API" ]; then replaceOrAddParam "/etc/default/quobyte" "MIN_MEM_API" "$QUOBYTE_MIN_MEM_API"; fi
if [ -n "$QUOBYTE_MIN_MEM_WEBCONSOLE" ]; then replaceOrAddParam "/etc/default/quobyte" "MIN_MEM_WEBCONSOLE" "$QUOBYTE_MIN_MEM_WEBCONSOLE"; fi
if [ -n "$QUOBYTE_MIN_MEM_S3" ]; then replaceOrAddParam "/etc/default/quobyte" "MIN_MEM_S3" "$QUOBYTE_MIN_MEM_S3"; fi

grep -q "/devices" /proc/mounts
if [ $? -ne 0 ]; then
  echo test.device_dir=/devices >> /etc/quobyte/$QUOBYTE_SERVICE.cfg
fi

echo logging.file_name= >> /etc/quobyte/$QUOBYTE_SERVICE.cfg
echo logging.stdout=true >> /etc/quobyte/$QUOBYTE_SERVICE.cfg

SERVICE_UUID=$(uuidgen)
echo uuid=$SERVICE_UUID >> /etc/quobyte/$QUOBYTE_SERVICE.cfg

export LIMIT_OPEN_FILES=100000
export LIMIT_MAX_PROCESSES=16384

ulimit -n $LIMIT_OPEN_FILES
# Maximize the virtual memory limit to make sure that Java can set the MaxHeapSize (-Xmx) correctly.
ulimit -v unlimited
ulimit -u $LIMIT_MAX_PROCESSES

echo "Running Quobyte service $QUOBYTE_SERVICE $SERVICE_UUID in container"
echo "Service configuration:"
cat /etc/quobyte/$QUOBYTE_SERVICE.cfg

/usr/bin/quobyte-$QUOBYTE_SERVICE
