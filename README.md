# sentilo-docker

Para iniciar o projeto de forma correta é necessário seguir a seguinte order:

1. Iniciar os subprojetos ELK e grafana
2. Iniciar o subprojeto sentilo-core

Sensores que utilizam da LoraWAN como rede para envio de dados e utilizam-se do 
gateway da TTN, é necessário um script que converte requisições MQTT para HTTP.
Esses scripts ainda estão em desenvolvimento, no momento é necessário um script para
cada estação.

> TODO: Fazer um único algoritmo que recebe dados de inúmeras estações 
e realizar o _parser_ corretamente de todos.