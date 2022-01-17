#!/bin/bash
#=======BIEN SU DUNG========
PASS="khongbiet"
BACKUP_DIR="/home/backup"
DATE="$(date +%Y-%m-%d:%H:%M:%S)"
#===========================
DATABASES=`/usr/bin/mysql -uroot -p${PASS} -e "show databases;" | grep -v "Database\|admin_default\|information_schema\|mysql\|performance_schema\|roundcube" | tr '\n' ' '`

check_backupdir() {
 if [[ ! -f $BACKUP_DIR ]]; then
     #sudo mkdir -p $BACKUP_DIR && cd $BACKUP_DIR && sudo mkdir ${DATE}
     sudo mkdir -p $BACKUP_DIR/${DATE}
     if [ "$?" = "0" ]; then
         :
     else
         echo "Couldn't create folder. Check folder permissions and/or disk quota!"
     fi
 else
  if [[ ! -f $BACKUP_DIR/$DATE ]]; then
	cd $BACKUP_DIR && sudo mkdir $DATE
	if [ "$?" = "0" ]; then
               :
           else
               echo "Couldn't create folder. Check folder permissions and/or disk quota!"
           fi
 fi
 fi
}

back_up(){
 for i in ${DATABASES}
 do
    cd ${BACKUP_DIR}/${DATE} --force-local && mysqldump -uroot -p${PASS} ${i} > ${i}-${DATE}.sql 
 done
}

compress_backup(){ 
 cd ${BACKUP_DIR}
 tar --force-local -zcf backup-${DATE}.tar  ${DATE}
 rm -rf ${DATE}
}

remove_old_file(){
 a="$(ls ${BACKUP_DIR} | wc -l)"
 let a-=3
 b="$(ls ${BACKUP_DIR} | sort -nr | tail -$a)"
 cd ${BACKUP_DIR}
 rm -rf $b
}

check_backupdir
back_up
compress_backup
remove_old_file
