#!bin/bash
#* */2 * * *
MONGO_URL='mongodb://root:root123@192.168.8.8:27017'
MONGO_DATABASE=defipluse
MONGO_CELLECTION=marketdata
TARGET_FILE=/opt/defipluse_data_to_mongo


echo "$(date +%Y%-m-%d-%H:%M:%S)"
cd $TARGET_FILE
source env/bin/activate

echo ">>>> Enter virtual environment..."

#获取指定网站数据
# run_usa自定义命令，只接收一个参数
defi_data=$(run_usa ' curl -s "https://data-api.defipulse.com/api/v1/defipulse/api/MarketData?api-key=93c078480f89a7fa220f2b91a7244ea17b5bab77e3cff6b0fa1e2d0ed22c" ')


echo ">>>> query api data..."

# 通过长度校验数据合法性
len_data=${#defi_data}

if (( $len_data < 3 ))

then
	echo ">>>> json too short: " $defi_data
	deactivate
	exit 1
else
	echo ">>>> json check OK. Go on."
	fi

# 获取当前时间戳
date_num=$(date +%s)

# 利用jq加工目标数据，增加额外时间信息
defipluse_data=$(echo $defi_data | jq -c --arg date_num $date_num '{time: $date_num} + .')


#export LC_ALL=en_US.UTF-8
# 创建mongo连接
export MONGOCAT_URL=$MONGO_URL

echo ">>>> save data to mongo..."

# 以json格式将数据写入mongo
mongocat -W -d $MONGO_DATABASE $MONGO_CELLECTION -p json <<EOF
${defipluse_data}
EOF

deactivate
echo ">>>> Exit virtual environment..."
