#!/bin/bash

# #Listar todos os servidores PostgreSQL
#echo "Listando todos os servidores PostgreSQL..."
#az postgres server list --query "[].{name: name, version: version}" | jq -r '.[] | "\(.name): \(.version)"'

#echo "-------------------------------------------------------"

# Listar todos os servidores PostgreSQL flexíveis
echo "Listando todos os servidores PostgreSQL flexíveis..."
az group list --query [].name --output tsv | while read -r resource_group; do
    az postgres flexible-server list --resource-group "$resource_group" --query "[].{name: name, version: version}" --output tsv 2>/dev/null
done

