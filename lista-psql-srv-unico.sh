#!/bin/bash

# Criar/Clear do arquivo de saída
echo "" > bancos-postgresql-servidores-unicos-rsg-tamanho.txt

# Obter uma lista de todos os servidores PostgreSQL em todos os grupos de recursos
az postgres server list --query [].id | jq -r '.[]' | while read server_id; do
    # Para cada servidor, obtemos o grupo de recursos e o nome do servidor
    resource_group=$(echo $server_id | cut -d'/' -f5)
    server_name=$(echo $server_id | cut -d'/' -f9)

    # Obtemos o storage_used do servidor PostgreSQL
    storage_used_bytes=$(az monitor metrics list --resource $server_id --metric storage_used --query value[0].timeseries[0].data[0].average --output tsv)

    # Convertemos bytes para megabytes (1 MB = 1048576 bytes)
    storage_used_mb=$(bc <<< "scale=2; $storage_used_bytes / 1048576")

    # Obtemos o storage_percent do servidor PostgreSQL
    storage_percent=$(az monitor metrics list --resource $server_id --metric storage_percent --query value[0].timeseries[0].data[0].average --output tsv)

    if [[ ! -z "$storage_percent" && "$storage_percent" != "null" ]]; then
        # Neste caso, o armazenamento percentual já está em um formato utilizável (%)
        storage_percent_display="$storage_percent%"
    else
        storage_percent_display="N/A"
    fi

    echo "Servidor PostgreSQL: $server_name" | tee -a bancos-postgresql-servidores-unicos-rsg-tamanho.txt
    echo "Grupo de recursos: $resource_group" | tee -a bancos-postgresql-servidores-unicos-rsg-tamanho.txt
    echo "Armazenamento Utilizado: $storage_used_mb MB" | tee -a bancos-postgresql-servidores-unicos-rsg-tamanho.txt
    echo "Percentual de Armazenamento: $storage_percent_display" | tee -a bancos-postgresql-servidores-unicos-rsg-tamanho.txt
    echo | tee -a bancos-postgresql-servidores-unicos-rsg-tamanho.txt
done

