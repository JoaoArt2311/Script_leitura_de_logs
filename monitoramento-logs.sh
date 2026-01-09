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

	echo "Arquivo: $nome_arquivo" >> log_stats.txt
	echo "Número de Linhas: $num_linhas" >> log_stats.txt
	echo "Número e Palavras: $num_palavras" >> log_stats.txt
	echo "----------------------------------------------" >> log_stats.txt

	cat "${arquivo}.unico" >> "${ARQUIVO_DIR}/logs_combinados_$(date +%F).log"
done

