#!bin/bash

CRONT_FILE="/var/spool/cron/crontabs/root"
DEL_FLAG="#defipluse_crontab"

# 清除相关定时任务文件
sed -i /${DEL_FLAG}/d /var/spool/cron/crontabs/root


cd crontab_file

#获取文件下所有定时任务文件名 *.sh
file_name=$( ls )

#获取目标文件结对路径
file_path=$(pwd)

echo "" >> $CRONT_FILE

# 添加任务开始说明
echo "#-------------START---------------- $DEL_FLAG" >> $CRONT_FILE

# 将所有文件添加至任务中
# 文件格式:
# 	line1: #/bin/bash
# 	line2: 定时任务设置时间频率  * * * * *
for file in $file_name
do
	cat $file | head -2 | tail -1 | awk -vfile_path=$file_path -vfile_name=$file -vFLAG=$DEL_FLAG -F "#" '{print($2 "\t/bin/bash " file_path "/" file_name " " FLAG)}' >> $CRONT_FILE
done
