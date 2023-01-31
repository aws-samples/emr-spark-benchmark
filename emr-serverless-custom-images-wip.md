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

First change to project root directory, and then build the Spark version 3.3.0. We use Hadoop 3.3.4. Feel free to change the Spark version to the one that you need.

```
export ECR_URL=9876543210.dkr.ecr.us-east-1.amazonaws.com
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
