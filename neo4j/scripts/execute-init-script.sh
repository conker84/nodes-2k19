#!/usr/bin/env bash

echo -e "\n\n⏳ Waiting for Neo4j to be available in order to create constraints\n"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:7474/db/data) -eq 000 ]
do
    echo -e $(date) "Neo4j Rest Server state: " $(curl -s -o /dev/null -w %{http_code} connectors) " (waiting for 200)"
    sleep 5
done

echo -e "Neo4j is ready, executing the init script"
cypher-shell -u neo4j -p connect < /scripts/init.cypher