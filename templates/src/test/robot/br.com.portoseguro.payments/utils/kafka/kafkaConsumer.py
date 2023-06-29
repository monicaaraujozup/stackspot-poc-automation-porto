import json
from threading import Thread, Event
import boto3
import os
from aws_schema_registry import SchemaRegistryClient, DataAndSchema, SchemaRegistryException
from aws_schema_registry.adapter.kafka import KafkaDeserializer
from kafka import KafkaConsumer
from waiting import wait, TimeoutExpired


# Cria sessão para conexão com aws
session = boto3.Session(region_name='ca-central-1')

# Cria o client de conexão com o glue
glue_client = session.client('glue')

# Configura o glue client
client = SchemaRegistryClient(glue_client,
                              registry_name='finance-schema-registry')
# Cria deserealizidor
deserializer = KafkaDeserializer(client)

# bootstrap = os.getenv('KAFKA_BOOTSTRAP_SERVERS')

# Variaveis
RESULTADO = None
EVENTO_THREAD = Event()
THREAD: Thread
LISTA_EVENTOS: list = []


def configura_consumer(topico: str, bootstrap) -> KafkaConsumer:
    consumer = KafkaConsumer(topico,
                             bootstrap_servers=bootstrap,
                             value_deserializer=deserializer,
                             client_id='teste-robot',
                             group_id='teste-robot-2',
                             auto_offset_reset='earliest',
                             consumer_timeout_ms=float(60000),
                             max_poll_interval_ms=5000
                             )
    return consumer


def consome_eventos(consumer):
    while EVENTO_THREAD.is_set() is False:
        try:
            lote = consumer.poll(timeout_ms=1000)
            lista = list(lote.values())
            if lista.__len__() != 0:
                for item in lista:
                    for record in item:
                        dados: DataAndSchema = record.value
                        LISTA_EVENTOS.append(dados)
        except SchemaRegistryException as erro:
            print(erro.__cause__)
        finally:
            consumer.commit_async()

    consumer.close()


def inicia_consumer(topico: str, bootstrap):
    global THREAD
    print(topico)
    print('iniciando consumer no topico: ' + topico)

    LISTA_EVENTOS.clear()
    EVENTO_THREAD.clear()

    consumer = configura_consumer(topico, bootstrap)
    THREAD = Thread(target=consome_eventos, args=(consumer,))
    THREAD.start()


def para_consumer():
    global THREAD
    EVENTO_THREAD.set()
    print('parando consumer')
    wait(lambda: THREAD.is_alive() is False, timeout_seconds=60, waiting_for='finalizar thread')


def busca_evento_na_lista(chave, valor):
    global RESULTADO
    if LISTA_EVENTOS.__len__() == 0:
        print(LISTA_EVENTOS)
        return None
    else:
        for item in LISTA_EVENTOS:
            evento_json = json.loads(json.dumps(item.data))
            if valor in evento_json[chave]:
                RESULTADO = str(item.data)
                return item.data
            else:
                LISTA_EVENTOS.remove(item)
        return None


def aguarda_evento(chave, valor, timeout):
    try:
        wait(lambda: busca_evento_na_lista(chave, valor) is not None,
             timeout_seconds=timeout,
             waiting_for='aguardando evento de teste'
             )
    except TimeoutExpired as erro:
        print(erro)
    finally:
        return RESULTADO