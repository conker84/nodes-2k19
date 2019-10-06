# Repo of Streaming Graph Data with Kafka talk @ NODES 2k19

## Step 1

Execute the `docker-compose` file via the following command:

```bash
docker-compose up -d
```

You'll find:

* Neo4j Browser @ http://localhost:7474
* Kibana @ http://localhost:5601

## Step 2

<img src="https://github.com/conker84/nodes-2k19/raw/master/neo-kafka-elastic.1.png">

Create some data by executing the fake data generator:

`java -jar kafka-connect-data-generator.jar`

This will populate Neo4j (as graph) and Kibana (as indexes)

## Step 3

<img src="https://github.com/conker84/nodes-2k19/raw/master/neo-kafka-elastic.2.png">

We want to find the most important actors into our graph, and use the result of this computation to sort and reinforce the search operation over Elastic indexes by a hypotetic API

```cypher
CALL algo.pageRank.stream(
  'MATCH (p:Person) RETURN p.id AS id',
  'MATCH (p1:Person)-->()<--(p2:Person) RETURN distinct p1.id AS source, p2.id AS target',
  {graph:'cypher'}
) YIELD nodeId, score
MATCH (p:Person{id: nodeId})
WHERE p.name is not null
CALL streams.publish('rank', {id: toString(p.id), entity: 'person', properties: {rank: score, name: p.name, born: p.born}})
RETURN nodeId, p.name, score
ORDER BY score DESC
```
