# Steps to use custom image with EMR Serverless for TPC-DS benchmark testing:

## Pre-requisites
We can complete all the steps either from a local desktop or using [AWS Cloud9](https://aws.amazon.com/cloud9/).  If you’re using AWS Cloud9, follow the instructions in the first step to spin up an AWS Cloud9 environment, otherwise skip to the next step.

### 1. Setup AWS Cloud9
AWS Cloud9 is a cloud-based IDE that lets you write, run, and debug your code with just a browser. AWS Cloud9 comes preconfigured with many of the dependencies we require to build our application.

Create an AWS Cloud9 environment from the [AWS Management Console[(https://console.aws.amazon.com/cloud9)] with an instance type of t3.small or larger. For our testing we used m5.xlarge for adequate memory and CPU to compile and build our benchmark application. Provide the required name, and leave the remaining default values. After your environment is created, you should have access to a terminal window. If you are new to AWS Cloud9 follow [this tutorial](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html) to create your environment.

You must increase the size of the [Amazon Elastic Block Store (Amazon EBS)](https://aws.amazon.com/ebs/) volume attached to your AWS Cloud9 instance to 20 GB, because the default size (10 GB) is not enough. For instructions, refer to [Resize an Amazon EBS volume used by an environment](https://docs.aws.amazon.com/cloud9/latest/user-guide/move-environment.html#move-environment-resize).

### 2. Install Docker if required
AWS Cloud9 EC2 instance m5.xlarge comes with Docker pre-installed. Depending on your environment you may or may not need to install Docker. To install Docker follow the instructions in the [Docker Desktop page](https://docs.docker.com/desktop/#download-and-install).

## Build Benchmark application

### 1. Build a custom docker image on top of EMR Serverless

Run the following command to build a docker image:

```
export ECR_URL=$ACCOUNTID.dkr.ecr.$AWS_REGION.amazonaws.com
git clone https://github.com/aws-samples/emr-on-eks-benchmark.git
cd emr-on-eks-benchmark

docker build -t $ECR_URL/eks-spark-benchmark:emrs6.9 -f docker/benchmark-util/Dockerfile --build-arg SPARK_BASE_IMAGE=public.ecr.aws/emr-serverless/spark/emr-6.9.0:latest .

docker push $ECR_URL/eks-spark-benchmark:emrs6.9
```

### 2. Create an EMR Serverless application using ECR URL:
With this option, you don't have to copy jar to S3 bucket, instead benchmark jar will be baked inside your docker image.

```
export REGION=us-east-1       
export EMR_RELEASE=emr-6.9.0 
export ECR_URL=9876543210.dkr.ecr.us-east-1.amazonaws.com

aws emr-serverless create-application --name "spark-custom-image" --image-configuration '{ "imageUri": "'$ECR_URL'"}' --type SPARK --release-label $EMR_RELEASE  --region $REGION  --initial-capacity '{
                                          "DRIVER": {
                                              "workerCount": 1,
                                              "workerConfiguration": {
                                                  "cpu": "4vCPU",
                                                  "memory": "16GB",
                                                  "disk": "120GB"
                                              }
                                          },
                                          "EXECUTOR": {
                                              "workerCount": 100,
                                              "workerConfiguration": {
                                                  "cpu": "4vCPU",
                                                  "memory": "16GB",
                                                "disk": "120GB"
                                              }
                                          }
}'  --network-configuration '{"subnetIds": ["subnet-XXXXXX", "subnet-YYYYY"], "securityGroupIds": ["sg-xxxxxyyyyyzzzz"]}'
```

### 3. Submit job to the EMR Serverless application:

Make sure runtime role has the appropriate s3 access to read and write from your S3 buckets.

```
export APP_ID=00xxxxp6vmdyyyyy                                  #Your EMR Serverless Application Id from Previous Step 
export RUNTIMEROLE="arn:aws:iam::333333333333:role/runtimerole" #Runtime role setup from pre-req
export YOURBUCKET=aws-emr-xxxxxx-yyyy                           #S3 bucket to write logs and benchmark results
export query='q1-2.4\,q2-2.4'                                   #option query param, can skip if all tpc-ds queries are run
export AWS_REGION=us-east-1                                     #region where app was created
export ITERATION=1                                              #number of iterations to be run

aws emr-serverless start-job-run --application-id $APP_ID \
--execution-role-arn "$RUNTIMEROLE" \
--job-driver '{"sparkSubmit": {"entryPoint": "/usr/lib/spark/jars/spark-benchmark-assembly-3.3.0.jar","entryPointArguments": ["s3://blogpost-sparkoneks-us-east-1/blog/BLOG_TPCDS-TEST-3T-partitioned","s3://'$YOURBUCKET'/spark/EMRSERVERLESS_TPCDS-TEST-3T-RESULT","/opt/tpcds-kit/tools","parquet","3000",'$ITERATION',"false",'q1-v2.4\,q10-v2.4\,q11-v2.4\,q12-v2.4\,q13-v2.4\,q14a-v2.4\,q14b-v2.4\,q15-v2.4\,q16-v2.4\,q17-v2.4\,q18-v2.4\,q19-v2.4\,q2-v2.4\,q20-v2.4\,q21-v2.4\,q22-v2.4\,q23a-v2.4\,q23b-v2.4\,q24a-v2.4\,q24b-v2.4\,q25-v2.4\,q26-v2.4\,q27-v2.4\,q28-v2.4\,q29-v2.4\,q3-v2.4\,q30-v2.4\,q31-v2.4\,q32-v2.4\,q33-v2.4\,q34-v2.4\,q35-v2.4\,q36-v2.4\,q37-v2.4\,q38-v2.4\,q39a-v2.4\,q39b-v2.4\,q4-v2.4\,q40-v2.4\,q41-v2.4\,q42-v2.4\,q43-v2.4\,q44-v2.4\,q45-v2.4\,q46-v2.4\,q47-v2.4\,q48-v2.4\,q49-v2.4\,q5-v2.4\,q50-v2.4\,q51-v2.4\,q52-v2.4\,q53-v2.4\,q54-v2.4\,q55-v2.4\,q56-v2.4\,q57-v2.4\,q58-v2.4\,q59-v2.4\,q6-v2.4\,q60-v2.4\,q61-v2.4\,q62-v2.4\,q63-v2.4\,q64-v2.4\,q65-v2.4\,q66-v2.4\,q67-v2.4\,q68-v2.4\,q69-v2.4\,q7-v2.4\,q70-v2.4\,q71-v2.4\,q72-v2.4\,q73-v2.4\,q74-v2.4\,q75-v2.4\,q76-v2.4\,q77-v2.4\,q78-v2.4\,q79-v2.4\,q8-v2.4\,q80-v2.4\,q81-v2.4\,q82-v2.4\,q83-v2.4\,q84-v2.4\,q85-v2.4\,q86-v2.4\,q87-v2.4\,q88-v2.4\,q89-v2.4\,q9-v2.4\,q90-v2.4\,q91-v2.4\,q92-v2.4\,q93-v2.4\,q94-v2.4\,q95-v2.4\,q96-v2.4\,q97-v2.4\,q98-v2.4\,q99-v2.4\,ss_max-v2.4',"true"],"sparkSubmitParameters": "--class com.amazonaws.eks.tpcds.BenchmarkSQL"}}' \
--configuration-overrides '{"monitoringConfiguration": {"s3MonitoringConfiguration": {"logUri": "s3://'$YOURBUCKET'/spark/logs/"}}}' \
--region "$AWS_REGION"
```

As an output of the benchmark job you can find the summarized results from the output bucket: s3://'$YOURBUCKET'/spark/EMRSERVERLESS_TPCDS-TEST-3T-RESULT in the same manner as we did for the OSS results and compare.
