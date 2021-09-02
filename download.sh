META_FILE_PATH='./meta.json'

TABLE=$(jq -r '.TABLE' $META_FILE_PATH)
maxItems=$(jq '.maxItems | tonumber' $META_FILE_PATH)
index=$(jq '.index | tonumber' $META_FILE_PATH)
maxPages=$(jq '.maxPages | tonumber' $META_FILE_PATH)
mkdir -p $TABLE

nextToken=$(jq -r '.nextToken' $META_FILE_PATH)

while [[ "${nextToken}" != "" ]] && [[ $nextToken != "null" ]] && [[ $index -le $maxPages ]]
do
  if [[ $nextToken == "start" ]]
  then
  DATA=$(aws dynamodb --profile prod scan --table-name $TABLE --max-items $maxItems)
  else
  DATA=$(aws dynamodb --profile prod scan --table-name $TABLE --max-items $maxItems --starting-token $nextToken)
  fi
  nextToken=$(echo $DATA | jq -r '.NextToken')
  
  echo $DATA | jq ".Items | {\"$TABLE\": [{\"PutRequest\": { \"Item\": .[]}}]}" >  "$TABLE/$TABLE-$index.json"
  
  ((index+=1))
  tmp=$(mktemp)
  jq --arg i "$index" '.index = $i' $META_FILE_PATH >"$tmp" && mv "$tmp" $META_FILE_PATH

  if [[ $nextToken != "null" ]] 
  then
    tmp=$(mktemp)
    jq --arg i "$nextToken" '.nextToken = $i' $META_FILE_PATH >"$tmp" && mv "$tmp" $META_FILE_PATH
  else
    nextToken=""
  fi
done