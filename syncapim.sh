#!/bin/bash
#
# Script created by Rogerbernardi@gmail.com in 27/06/2018
# Used to sync directories using md5 checksum to compare directory content.
#
# Debug ON
# set -x
# Debug OFF
set +x

# Search for any previously job executed, and kill the associated process.
for i in `ps x | grep syncapim.sh | grep -v grep |grep -v $$ | cut -d' ' -f 2`; 
do
        kill -9 $i;
done

# Production environment variables:
# ctrlNow="/u/wso2/wso2am-2.2.0/repository/deployment/ctrlNow.txt";
# ctrlLast="/u/wso2/wso2am-2.2.0/repository/deployment/ctrlLast.txt";
# dirOrigem="/u/wso2/wso2am-2.2.0/repository/deployment/server";
# dirDestino="root@as1441:/u/wso2/wso2am-2.2.0/repository/deployment/server"
#syncdirs="rsync -avzhe ssh --progress --delete $dirOrigem $dirDestino"

# Test environment variables:
ctrlNow="/Users/rogerbernardi/wso2/ctrlNow.txt";
ctrlLast="/Users/rogerbernardi/wso2/ctrlLast.txt";
dirOrigem="/Users/rogerbernardi/wso2/origem/";
dirDestino="/Users/rogerbernardi/wso2/destino/"
syncdirs="rsync -avzh --delete --progress $dirOrigem $dirDestino"

while true;
do
        # Start getting md5 checksum of original directory and log in a controlFile
        du -cs $dirOrigem | cut  -f 1 | sort | uniq | md5sum | cut -d '-' -f1 > $ctrlNow
        # If don't detect any difference
        if [ `cat $ctrlNow` = `cat $ctrlLast`]; then
                # Se o arquivo é igual ele não faz nada, apenas loga a atividade com data e hora.
                date
                echo -e "\033[33;1msyncapim: same files \033[m";
                echo -e "\033[33;1mDidn't find any change\033[m";
                echo -e "\033[33;1mNo one operation will be executed at this moment\033[m";
                echo -e "\033[33;1mThis job was finished successfully\033[m";
                echo -e "\033[33;1m**************************************************\033[m";
        else
        # If detect some difference
                date
                echo -e "\033[31;5msyncapim: some differences was detected between last checkpoint and now\033[m";
                echo -e "\033[31;5msyncronization job will be execute!\033[m";
                # Updating checkpoint with new registers. Using md5sum for this.
                du -cs $dirOrigem | cut  -f 1 | sort | uniq | md5sum | cut -d '-' -f1> $ctrlLast
                du -cs $dirOrigem | cut  -f 1 | sort | uniq | md5sum | cut -d '-' -f1> $ctrlNow
                # Synchronization job with time control
                time $syncdirs
                echo -e "\033[31;5mThis job was finished successfully\033[m";
                echo -e "\033[31;5m************************************************************************\033[m";
        fi
        # Job cycle in seconds, this mechanism is used for do not overload of server.
        sleep 3
done
