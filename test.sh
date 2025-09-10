#!/usr/bin/env bash

. core/00_message.sh; 
. core/01_status.sh; 
. core/02_string.sh; 
. core/03_var.sh; 

. core/oop/00_config.sh; 
. core/oop/01_check.sh; 
. core/oop/02_meta.sh; 
. core/oop/03_type.sh; 
. core/oop/04_instance.sh; 

echo "# Definição"
objectTypeCreate Account
objectTypeSetProperty Account string nome
objectTypeSetProperty Account int idade 0
objectTypeSetProperty Account int amount 0
debug() { 
    local -n arrArgs="${1}"; shift;
    local it=""
    for it in "${!arrArgs[@]}"; do
      echo "- ${it} : ${arrArgs[$it]}"
    done
    
    echo -e "another parans:\n$@"; 
}
showAmount() { 
    local -n arrArgs="${1}"; shift;
    local name="${arrArgs[nome]}"
    local idade="${arrArgs[idade]}"
    local amount="${arrArgs[amount]}"

    echo -e "Olá ${name}(${idade}), você tem ${amount} na conta!"; 
}
objectTypeSetMethod Account debug
objectTypeSetMethod Account showAmount
objectTypeCreateEnd Account
echo "  done!"
echo ""
echo ""
echo "# Dump do novo objeto"
objectTypeDump Account
echo "  done!"
echo ""
echo ""
echo "# Criando instância"
objectInstanceNew "Account" "katze"
Account katze set nome "Rianna Katze"
Account katze set idade 43
Account katze set amount 199999999999
echo "## Exec property"
Account katze exec showAmount
echo "  done!"
#Account katze exec debug
objectTypeDump Account