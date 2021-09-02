META_FILE_PATH='./meta.json'

TABLE=$(jq -r '.TABLE' $META_FILE_PATH)
maxItems=$(jq '.maxItems | tonumber' $META_FILE_PATH)
index=$(jq '.index | tonumber' $META_FILE_PATH)
maxPages=$(jq '.maxPages | tonumber' $META_FILE_PATH)
mkdir -p upload

for file in ./$TABLE/*
do
  aws dynamodb batch-write-item \
    --request-items file://$file \
    --return-consumed-capacity INDEXES \
    --return-item-collection-metrics SIZE  >>  "upload/$TABLE.log"
done