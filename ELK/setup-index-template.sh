#!/bin/bash
# Aplica o index template sentilo-ds no Elasticsearch.
# Uso (na raiz do projeto, com .envsrc carregado):
#   source .envsrc && ./ELK/setup-index-template.sh
# Ou com host customizado:
#   ELASTIC_HOST=http://localhost:9200 ./ELK/setup-index-template.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="${SCRIPT_DIR}/elasticsearch/index-templates/sentilo-ds.json"
ELASTIC_HOST="${ELASTIC_HOST:-http://localhost:9200}"
ELASTIC_USER="${ELASTIC_USER:-elastic}"

if [[ -z "${ELASTIC_PASSWORD:-}" ]]; then
    echo "ERRO: defina ELASTIC_PASSWORD (ex.: source .envsrc)"
    exit 1
fi

echo "Aplicando index template sentilo-ds em ${ELASTIC_HOST}..."

HTTP_CODE=$(curl -s -o /tmp/sentilo-template-response.json -w "%{http_code}" \
    -u "${ELASTIC_USER}:${ELASTIC_PASSWORD}" \
    -X PUT "${ELASTIC_HOST}/_index_template/sentilo-ds" \
    -H "Content-Type: application/json" \
    -d @"${TEMPLATE_FILE}")

if [[ "${HTTP_CODE}" -ge 200 && "${HTTP_CODE}" -lt 300 ]]; then
    echo "Index template aplicado com sucesso."
    cat /tmp/sentilo-template-response.json
    echo ""
else
    echo "ERRO ao aplicar template (HTTP ${HTTP_CODE}):"
    cat /tmp/sentilo-template-response.json
    exit 1
fi
