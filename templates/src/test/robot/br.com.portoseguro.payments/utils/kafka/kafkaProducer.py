import boto3
import os


# Cria sessão para conexão com aws
session = boto3.Session(region_name='ca-central-1')

glue_client = session.client('glue')

from aws_schema_registry import SchemaRegistryClient
from aws_schema_registry.avro import AvroSchema
from aws_schema_registry.codec import encode
from kafka import KafkaProducer

# Create the schema registry client, which is a façade around the boto3 glue client
client = SchemaRegistryClient(glue_client,
                              registry_name='finance-schema-registry')
# Create the producer

#bootstrap = os.getenv('KAFKA_BOOTSTRAP_SERVERS')

def kafkaProducer(topico, esquema, dados, bootstrap):
    print(dados)
    producer = KafkaProducer(
        bootstrap_servers=bootstrap,
        key_serializer=str.encode
    )
    # Our producer needs a schema to send along with the data.
    # In this example we're using Avro, so we'll load an .avsc file.
    with open(esquema, 'rb') as schema_file:
        schema = AvroSchema(schema_file.read().decode())

    id = client.get_schema_by_definition(definition=str(schema), schema_name=topico)
    msg = encode(schema.write(dados), id.version_id)

    producer.send(topic=topico, key='teste-robot', value=msg,
                  headers=[('kafka_correlationId', b'teste-robot')])
    producer.flush()
    print('evento produzido: ' + str(dados))