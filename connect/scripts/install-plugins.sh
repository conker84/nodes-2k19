#!/usr/bin/env bash

echo -e "\n\n⏳ Waiting for Kafka Connect to be available before installing the plugins\n"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -eq 000 ]
do
    echo -e $(date) "Kafka Connect Rest Server state: " $(curl -s -o /dev/null -w %{http_code} connectors) " (waiting for 200)"
    sleep 5
done

function retry {
    max_retry=5
    success=0

    for i in $(seq 1 5)
    do
        echo -e "Installing $1 (attempt $i)"
        if [ $(curl -X POST -H "Content-Type: application/json" -d @$2 -w "\n%{http_code}\n" http://localhost:8083/connectors --output /dev/null | tail -n 1) == 201 ]
        then
            success=1 && break
        fi
        sleep 10
    done

    if [ $success == 1 ]
    then
        echo -e "$1 successfully installed"
    else
        echo -e "Cannot install $1 please check the logs"
    fi
}

retry "Installing the Neo4j Connector" "connect.neo4j.sink.json"
retry "Installing the Elastic Connector" "connect.elastic.sink.json"
retry "Installing the Elastic (Rank) Connector" "connect.elastic.rank.sink.json"
