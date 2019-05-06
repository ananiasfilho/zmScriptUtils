#! /bin/bash 

whereis_templates="/opt/zimbra/conf/nginx/templates"

version="0.0.2"
files=`grep Microsoft-Server-ActiveSync $whereis_templates/* | cut -d: -f1 | sort | uniq`

for file in $files ; do

	# Z-PUSH

	l1=`grep -n Microsoft-Server-ActiveSync $file | cut -d: -f1`
	if [ "$l1" != "" ] ; then
		many_spaces=`grep Microsoft-Server-ActiveSync $file | awk -F'[^ \t]' '{print length($1)","NR}' | cut -d, -f1`

		regexp=$(echo "}" | perl -pe "\$_=\" \"x$many_spaces .\$_")

		li="$l1"
		while [ true ] ; do
			regtest=`sed "${li}q;d" $file | grep "^$regexp"`
			if [ "$regtest" != "" ] ; then
				l2=$li
				break
			fi
			li=`expr $li + 1`

			#echo "$regexp"
		done

		# Adiciona as configurações certas
		head_n=`expr ${l1} - 1`
		head -n $head_n $file >/tmp/file_tmp_nginx_zm


		echo "    location ^~ /Microsoft-Server-ActiveSync
    {
        
        set \$mailhostport \${web.http.uport};
        set \$relhost \$host;

        if (\$mailhostport != 80) { 
            set \$relhost \$host:\$mailhostport;
        }

        include /opt/z-push/nginx-php-fpm.conf;
        
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        
        set \$virtual_host \$http_host;

        if (\$virtual_host = '') {
            set \$virtual_host $server_addr:$server_port;
        }

        proxy_set_header Host            \$virtual_host;

        proxy_redirect http://\$http_host/ https://\$http_host/;

        proxy_redirect http://\$relhost/ https://\$http_host/;
        
    }
" >> /tmp/file_tmp_nginx_zm

		total_lines=`wc -l $file | cut -d" " -f1`
		tail_n=`expr $total_lines - ${l2}`

		tail -n $tail_n $file >>/tmp/file_tmp_nginx_zm


	fi

	# LET'S ENCRYPT

	test_lets=`grep letsencrypt $file | grep acme-challenge`
	if [ "$test_lets" = "" ] ; then
		head_n=`grep -n ".docs.common" /tmp/file_tmp_nginx_zm | cut -d: -f1`
		
		head -n $head_n /tmp/file_tmp_nginx_zm >/tmp/file_tmp_nginx_zm2

		echo "" >>/tmp/file_tmp_nginx_zm2
		echo "    location ^~ /.well-known/acme-challenge { root /opt/zimbra/data/nginx/letsencrypt; }" >>/tmp/file_tmp_nginx_zm2
		echo "" >>/tmp/file_tmp_nginx_zm2
		echo "}" >>/tmp/file_tmp_nginx_zm2

		cp /tmp/file_tmp_nginx_zm2 /tmp/file_tmp_nginx_zm
	fi

	# Copia o arquivo para o lugar certo
	cp /tmp/file_tmp_nginx_zm $file
done
