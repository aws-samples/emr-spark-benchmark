#!/bin/bash

APP_ID=$1
export AWS_REGION="us-east-1"

arr=("q21-v2.4" "q22-v2.4" "q23a-v2.4" "q23b-v2.4" "q24a-v2.4" "q24b-v2.4" "q25-v2.4" "q26-v2.4" "q27-v2.4" "q28-v2.4" "q29-v2.4" "q3-v2.4" "q30-v2.4" "q31-v2.4" "q32-v2.4" "q33-v2.4" "q34-v2.4" "q35-v2.4" "q36-v2.4" "q37-v2.4" "q38-v2.4" "q39a-v2.4" "q39b-v2.4" "q4-v2.4" "q40-v2.4")

function run_benchmark(){
        for (( i = 0; i < "${#arr[@]}"; i++ )); do
                        echo  "${arr[$i]}"
                        job_id=$(bash submit_tpcds.sh "${arr[$i]}" "$APP_ID" | jq -c '.jobRunId')
                        job_id=$(echo "$job_id" | tr -d '"')
                        state=""
                        while [[ "$state" != "SUCCESS" ]] && [[ "$state" != "FAILED" ]] && [[ "$state" != "CANCELLED" ]];
                        do
                         output=$(/usr/local/bin/aws emr-serverless get-job-run --application-id $APP_ID --job-run-id $job_id  --region $AWS_REGION | jq -c '.jobRun.state')
                         #Sleep before checking job status
                         sleep 30
                         state=`sed -e 's/^"//' -e 's/"$//' <<<"$output"`
                        done
                        #2 minutes sleep for EMR Serverless App to stop, replenish resources for next query run
                        #sleep 120;
                        /usr/local/bin/aws emr-serverless stop-application --application-id $APP_ID --region $AWS_REGION
                        sleep 90;
                        echo "`date +%m-%d-%YT%T` Ran job with "${arr[$i]}"  job id: $job_id"
                        echo "Status of query ${arr[$i]} with job_id: $job_id is $state"
        done
}

g=1
for (( k = 0; k < $g; k++ )); do
        echo "running iteration $k"
        run_benchmark
done
