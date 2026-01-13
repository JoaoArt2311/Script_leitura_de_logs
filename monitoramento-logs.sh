#!/bin/bash


LOG_DIR="../myapp/logs"
ARQUIVO_DIR="../myapp/logs-processados"

mkdir -p $ARQUIVO_DIR


echo "Verificando logs no diretorio $LOG_DIR"

find $LOG_DIR -name "*.log" -print0 | while IFS= read -r -d '' arquivo;
do
	grep "ERROR" $arquivo > "${arquivo}.filtrado"
	grep "SENSITIVE_DATA" $arquivo >> "${arquivo}.filtrado"

	sed -i 's/User password is .*/User password is REDACTED/g' "${arquivo}.filtrado"
	sed -i 's/User password reset request with token .*/User password reset request with token REDACTED/g' "${arquivo}.filtrado"
        sed -i 's/API key leaked: .*/API key leaked: REDACTED/g' "${arquivo}.filtrado"
        sed -i 's/User credit card last four digits: .*/User credit card last four digits: REDACTED/g' "${arquivo}.filtrado"
        sed -i 's/User session initiated with token: .*/User session initiated with token: REDACTED/g' "${arquivo}.filtrado"
	
	sort "${arquivo}.filtrado" -r "${arquivo}.filtrado"

	uniq "${arquivo}.filtrado" > "${arquivo}.unico"

	num_palavras=$(wc -w < "${arquivo}.unico")
	num_linhas=$(wc -l < "${arquivo}.unico")
	
	nome_arquivo=$(basename "${arquivo}.unico")

	echo "Arquivo: $nome_arquivo" >> "${ARQUIVO_DIR}/log_stats_$(date +%F).txt"
	echo "Número de Linhas: $num_linhas" >> "${ARQUIVO_DIR}/log_stats_$(date +%F).txt"
	echo "Número e Palavras: $num_palavras" >> "${ARQUIVO_DIR}/log_stats_$(date +%F).txt"
	echo "----------------------------------------------" >> "${ARQUIVO_DIR}/log_stats_$(date +%F).txt"

    	if [[ "$nome_arquivo" == *frontend* ]]; then
        	sed 's/^/[FRONTEND] /' "${arquivo}.unico" >> "${ARQUIVO_DIR}/logs_combinados_$(date +%F).log"
    	elif [[ "$nome_arquivo" == *backend* ]]; then
        	sed 's/^/[BACKEND] /' "${arquivo}.unico" >> "${ARQUIVO_DIR}/logs_combinados_$(date +%F).log"
    	else
        	cat "${arquivo}.unico" >> "${ARQUIVO_DIR}/logs_combinados_$(date +%F).log" 	
		
	fi	
done

sort -k2 "${ARQUIVO_DIR}/logs_combinados_$(date +%F).log" -o "${ARQUIVO_DIR}/logs_combinados_$(date +%F).log"
