#!/bin/bash
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
REMOTE_SERVER=""
LOCAL_IP=''
# back up local
LOCAL_DIR="/home/backupdb/"
MYSQL_PASS="khongbiet"
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DATABASES=`/usr/bin/mysql -e "show databases;" | grep -v "Database\|admin_default\|information_schema\|mysql\|performance_schema\|roundcube" | tr '\n' ' '`
DATE="$(date +%Y-%m-%d:%H:%M:%S)"

echo DATABASES=$DATABASES
report_msg () {
        echo  "[$1] [$(date +'%Y-%m-%d %H:%M:%S')] $2 "
        return
}

local_backup () {
        report_msg "!" "===local backup===" >>  ${LOCAL_DIR}/backup.log
        for i in ${DATABASES}
        do
                cd ${LOCAL_DIR} && /usr/bin/mysqldump ${i} > ${i}-${DATE}.sql && \
                report_msg "!" "mysqldump '$i' thanh cong." >> ${LOCAL_DIR}/backup.log || \
                report_msg "X" "mysqldump '$i' khong thanh cong." >> ${LOCAL_DIR}/backup.log
        done
                report_msg "!" "===Backup local completed===" >>  ${LOCAL_DIR}/backup.log
        return
}

compress_backup(){
 cd ${LOCAL_DIR}
 #tar --force-local -zcf backup-${DATE}.tar *.sql
 zip -r backup-${DATE}.zip *.sql
 rm -rf *.sql
}


rsync_to_remote_server () {
        rsync -avz -e "ssh -i /home/backupdb/.ssh/id_rsa " /home/backupdb/*.zip root@<REMOTE_IP>:/home/backup/remote
        cd ${LOCAL_DIR}
        rm -rf *.zip
}

#--------------- main ---------------#

[[ -d ${LOCAL_DIR} ]] || /bin/mkdir -p ${LOCAL_DIR} && chmod 700  ${LOCAL_DIR}
[[ -f ${LOCAL_DIR}/backup.log ]] || touch ${LOCAL_DIR}/backup.log && chmod 600 ${LOCAL_DIR}/backup.log

report_msg "-" "-------------------$DATE-------------------" >> ${LOCAL_DIR}/backup.log

local_backup
compress_backup
rsync_to_remote_server
