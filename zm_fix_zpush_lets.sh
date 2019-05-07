#! /bin/bash -x

whereis_templates="/opt/zimbra/conf/nginx/templates"

if [ -z $1 ] ; then
	echo "Script to insert Z-Push, Let's Encrypt and Munin confs on Zimbra Proxy templates"
	echo ""
	echo "No option given! tell me what to do."
	echo ""
	echo "$0 [all|zpush|lets|munin]"
	echo ""
	exit
fi

version="0.0.3"
files=`grep Microsoft-Server-ActiveSync $whereis_templates/* | cut -d: -f1 | sort | uniq`
echo $files

# Z-PUSH

add_zpush(){

tmp_file="/tmp/add_zpush.tmp"

for file in $files ; do

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
		head -n $head_n $file >$tmp_file


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
" >>$tmp_file

		total_lines=`wc -l $file | cut -d" " -f1`
		tail_n=`expr $total_lines - ${l2}`

		tail -n $tail_n $file >>$tmp_file

	fi

	# Copia o arquivo para o lugar certo
	cp $tmp_file $file

done

}

# LET'S ENCRYPT
add_lets(){

tmp_file="/tmp/add_lets.tmp"

for file in $files ; do

	test_lets=`grep letsencrypt $file | grep acme-challenge`
	if [ "$test_lets" = "" ] ; then
		head_n=`grep -n ".docs.common" $file | cut -d: -f1`
		
		head -n $head_n $file >$tmp_file

		echo "" >>$tmp_file
		echo "    location ^~ /.well-known/acme-challenge { root /opt/zimbra/data/nginx/letsencrypt; }" >>$tmp_file

		total_lines=`wc -l $file | cut -d" " -f1`
		tail_n=`expr $total_lines - $head_n`

		tail -n $tail_n $file >>$tmp_file

	fi

	# Copia o arquivo para o lugar certo
	cp $tmp_file $file

done
}

# Munin
add_munin(){

tmp_file="/tmp/add_munin.tmp"

for file in $files ; do

	test_lets=`grep munin $file | grep cache`
	if [ "$test_lets" = "" ] ; then
		head_n=`grep -n ".docs.common" $file | cut -d: -f1`
		
		head -n $head_n $file >$tmp_file

		echo "" >>$tmp_file
		echo "    location ^~ /munin { root /var/cache/munin; }" >>$tmp_file

		total_lines=`wc -l $file | cut -d" " -f1`
		tail_n=`expr $total_lines - $head_n`

		tail -n $tail_n $file >>$tmp_file

	fi

	# Copia o arquivo para o lugar certo
	cp $tmp_file $file

done
}

#Let's Rock!

if [ "$1" = "all" ] ; then
	add_zpush ; add_lets ; add_munin
elif [ "$1" = "zpush" ] ; then
	add_zpush
elif [ "$1" = "lets" ] ; then
	add_lets
elif [ "$1" = "munin" ] ; then
	add_munin
fi
