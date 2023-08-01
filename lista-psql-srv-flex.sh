#!/bin/bash

# Criar/Clear do arquivo de saída
echo "" > bancos-postgresql-flexiveis-rsg-tamanho.txt

# Obter uma lista de todos os servidores PostgreSQL flexíveis em todos os grupos de recursos
az postgres flexible-server list --query [].id | jq -r '.[]' | while read server_id; do
    # Para cada servidor, obtemos o grupo de recursos e o nome do servidor
    resource_group=$(echo $server_id | cut -d'/' -f5)
    server_name=$(echo $server_id | cut -d'/' -f9)

    # Obtemos o storage_used do servidor PostgreSQL flexível
    storage_used_bytes=$(az monitor metrics list --resource $server_id --metric storage_used --query value[0].timeseries[0].data[0].average --output tsv)

    # Obtemos o storage_free do servidor PostgreSQL flexível
    storage_free_bytes=$(az monitor metrics list --resource $server_id --metric storage_free --query value[0].timeseries[0].data[0].average --output tsv)

    # Convertemos bytes para megabytes (1 MB = 1048576 bytes)
    storage_used_mb=$(bc <<< "scale=2; $storage_used_bytes / 1048576")
    storage_free_mb=$(bc <<< "scale=2; $storage_free_bytes / 1048576")

    echo "Servidor PostgreSQL Flexível: $server_name" | tee -a bancos-postgresql-flexiveis-rsg-tamanho.txt
    echo "Grupo de recursos: $resource_group" | tee -a bancos-postgresql-flexiveis-rsg-tamanho.txt
    echo "Armazenamento Utilizado: $storage_used_mb MB" | tee -a bancos-postgresql-flexiveis-rsg-tamanho.txt
    echo "Armazenamento Disponivel: $storage_free_mb MB" | tee -a bancos-postgresql-flexiveis-rsg-tamanho.txt
    echo "" | tee -a bancos-postgresql-flexiveis-rsg-tamanho.txt
done

