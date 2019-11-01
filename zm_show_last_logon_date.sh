#!/bin/bash
### DEFINIR DATA NO SEGUINTE FORMATO: YYYYMMDDhhmmss (14 caracteres)
### Exemplor de 01 de outubro de 2019 a partir da 00:00hs - 2019 10 01 00 00 00
### Basta remover os espacos
 
if [ "$1" = "" ] ; then
	clear
	echo ""
	echo "########## ERROR ##########"
	echo ""
        echo "[!!]  DEFINIR DATA NO SEGUINTE FORMATO: YYYYMMDDhhmmss (14 caracteres)"
        echo "[!!]  Exemplo de 01 de outubro de 2019 a partir da 00:00hs - 2019 10 01 00 00 00"
        echo "[!!]  Basta remover os espacos"
	echo ""
	echo ""
        exit
fi
 
MIN_LAST_LOGIN="$1"
 
 
for EMAIL in `su - zimbra -c"/opt/zimbra/bin/zmprov -l gaa|grep -E -v \"admin|gal|virus|spam|ham\"|sed 's/ //g'"`; do
  DATE_LAST_LOGIN=`su - zimbra -c"zmprov ga $EMAIL|grep zimbraLastLogonTimestamp|grep -E -v \"Inactive\"|cut -d'.' -f1|cut -d' ' -f2 | sed 's/[^0-9]*//g'"`
  # Checa se o DATE_LAST_LOGIN existe e não é vazia
  if [ $DATE_LAST_LOGIN ] ; then
      DATE_LAST_LOGIN_FORMATED=`date -d "${DATE_LAST_LOGIN:0:8} ${DATE_LAST_LOGIN:8:2}:${DATE_LAST_LOGIN:10:2}:${DATE_LAST_LOGIN:12:2}"`
      if [ "$DATE_LAST_LOGIN" -gt "$MIN_LAST_LOGIN" ] ; then
         # Imprime na tela no formato CSV com separador ";"
         echo "$EMAIL;$DATE_LAST_LOGIN;$DATE_LAST_LOGIN_FORMATED"
      fi
  fi
done
