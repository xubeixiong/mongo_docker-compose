#!bin/bash

echo "$(date +%Y%-m-%d-%H:%M:%S)"
cd /opt/chart_banck_mongo
source ./env/bin/activate

echo ">>>> Enter virtual environment..."

defi_data=$(curl "https://data-api.defipulse.com/api/v1/defipulse/api/MarketData?api-key=c5955059491aa04d18671faf1b8d8471ab4a09a19a80887c56f84dd35c1b")

echo ">>>> query api data..."

len_data=${#defi_data}

if (( $len_data < 3 ))
then
    echo ">>>> json too short: " $defi_data
    ./deactivate
    exit 1
else
    echo ">>>> json check OK. Go on."
fi


date_num=$(date +%s)


defipluse_data=$(echo $defi_data | jq -c --arg date_num $date_num '{time: $date_num} + .')


export LC_ALL=en_US.UTF-8
export MONGOCAT_URL='mongodb://root:root123@192.168.8.8:27017'

echo ">>>> save data to mongo..."


mongocat -W -d defipluse marketdata -p json <<EOF
${defipluse_data}
EOF

./deactivate
echo ">>>> Exit virtual environment..."

