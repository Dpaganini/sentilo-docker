# sentilo-docker

Stack Docker para executar a plataforma [Sentilo](https://www.sentilo.io/) com ELK, monitoramento e proxy reverso.

> Para implantação em produção, consulte o guia interno em **[docs/PRODUCAO.md](docs/PRODUCAO.md)**.

## Setup

### Certificados
Antes de iniciar o projeto é necessário que as chaves **privada, pública e de requisição**
estejam localizadas em **certs/server**, sendo nomeadas, respectivamente como: 
server-key.pem, server-cert.pem e server-req.pem.

Para gerar certificados autoassinados (desenvolvimento):

```bash
cd certs && ./gen-cert.sh
```

### Variáveis de ambiente
Na raíz do projeto, adicione um arquivo **.envsrc**, com os seguintes atributos:
```bash
export MONGO_INITDB_ROOT_USERNAME=xxx
export MONGO_INITDB_ROOT_PASSWORD=xxx
export ELASTIC_PASSWORD=xxx
export ELASTIC_USER=xxx
export LOGSTASH_USER=xxx
export LOGSTASH_PASSWORD=xxx
export KIBANA_USER=xxx
export KIBANA_PASSWORD=xxx
```

## Inicialização

### 1. Criar rede e volumes Docker

A rede e os volumes de persistência do sentilo-core são **externos** — precisam existir antes do primeiro `up`:

```bash
docker network create sentilo_network

docker volume create sentilo-mongo-vol
docker volume create sentilo-redis-vol
```

### 2. Carregar variáveis de ambiente

```bash
source .envsrc
```

### 3. Subir os serviços

Use o script `server.sh` na raiz do projeto:

```bash
# Subir tudo
./server.sh up

# Ou subir individualmente (ordem recomendada na primeira vez):
./server.sh up sentilo
./server.sh up elk
./server.sh up monitoring
./server.sh up proxy
```

Para parar:

```bash
./server.sh down
./server.sh down elk   # parar apenas o ELK
```

### 4. Pós-inicialização

- **ELK:** configurar senhas do Elasticsearch — ver [ELK/README.md](ELK/README.md)
- **Tenants:** criar usuários ADMIN via `sadmin` — ver [sentilo-core/README.md](sentilo-core/README.md)
- **Encaminhadores:** configurar e executar os scripts em `forwarder/`

## Estrutura do projeto

| Pasta            | Descrição                                      |
|------------------|------------------------------------------------|
| `sentilo-core/`  | Redis, MongoDB, API, Catalog, Agents           |
| `ELK/`           | Elasticsearch, Kibana, Logstash                |
| `monitoring/`    | Prometheus, Grafana, exporters                 |
| `proxy/`         | Nginx reverso (HTTPS)                          |
| `forwarder/`     | Scripts MQTT → HTTP (estações LoRaWAN / TTN)   |
| `certs/`         | Certificados TLS                               |
| `docs/`          | Documentação interna                           |

## Encaminhadores

Sensores que utilizam LoRaWAN via gateway TTN precisam de um script que converte requisições MQTT para HTTP.
No momento é necessário um script por estação (em `forwarder/`).

> TODO: Fazer um único algoritmo que recebe dados de inúmeras estações 
e realizar o _parser_ corretamente de todos.
> TODO: Adicionar secrets do Redis nas variáveis de ambiente.
