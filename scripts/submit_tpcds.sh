export APP_ID=$1                                                #Your EMR Serverless Application Id from Previous Step 
export query=$2                                                 #option query param, can skip if all tpc-ds queries are run
export RUNTIMEROLE="arn:aws:iam::333333333333:role/runtimerole" #Runtime role setup from pre-req
export YOURBUCKET=aws-emr-xxxxxx-yyyy                           #S3 bucket to write logs and benchmark results
export AWS_REGION=us-east-1                                     #region where app was created
export ITERATION=1                                              #number of iterations to be run

aws emr-serverless start-job-run --application-id $APP_ID \
--execution-role-arn "$RUNTIMEROLE" \
--job-driver '{"sparkSubmit": {"entryPoint": "s3://'$YOURBUCKET'/jars/spark-benchmark-assembly-3.3.0.jar","entryPointArguments": ["s3://blogpost-sparkoneks-us-east-1/blog/BLOG_TPCDS-TEST-3T-partitioned","s3://'$YOURBUCKET'/spark/EMRSERVERLESS_TPCDS-TEST-3T-RESULT","/opt/tpcds-kit/tools","parquet","3000",'$ITERATION',"false",'$query',"true"],"sparkSubmitParameters": "--class com.amazonaws.eks.tpcds.BenchmarkSQL"}}' \
--configuration-overrides '{"monitoringConfiguration": {"s3MonitoringConfiguration": {"logUri": "s3://'$YOURBUCKET'/spark/logs/"}}}' \
--region "$AWS_REGION"
