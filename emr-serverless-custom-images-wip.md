# Steps to custom image with EMR Serverless for TPC-DS benchmark testing:

## Pre-requisites
We can complete all the steps either from a local desktop or using [AWS Cloud9](https://aws.amazon.com/cloud9/).  If you’re using AWS Cloud9, follow the instructions in the first step to spin up an AWS Cloud9 environment, otherwise skip to the next step.

### 1. Setup AWS Cloud9
AWS Cloud9 is a cloud-based IDE that lets you write, run, and debug your code with just a browser. AWS Cloud9 comes preconfigured with many of the dependencies we require to build our application.

Create an AWS Cloud9 environment from the [AWS Management Console[(https://console.aws.amazon.com/cloud9)] with an instance type of t3.small or larger. For our testing we used m5.xlarge for adequate memory and CPU to compile and build our benchmark application. Provide the required name, and leave the remaining default values. After your environment is created, you should have access to a terminal window. If you are new to AWS Cloud9 follow [this tutorial](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html) to create your environment.

You must increase the size of the [Amazon Elastic Block Store (Amazon EBS)](https://aws.amazon.com/ebs/) volume attached to your AWS Cloud9 instance to 20 GB, because the default size (10 GB) is not enough. For instructions, refer to [Resize an Amazon EBS volume used by an environment](https://docs.aws.amazon.com/cloud9/latest/user-guide/move-environment.html#move-environment-resize).

### 2. Install Docker if required
AWS Cloud9 EC2 instance m5.xlarge comes with Docker pre-installed. Depending on your environment you may or may not need to install Docker. To install Docker follow the instructions in the [Docker Desktop page](https://docs.docker.com/desktop/#download-and-install).

## Build Benchmark application

### 1. Create a project folder (emr-serverless-benchmark) and download the benchmark jar file into your local project folder. 

Copy the benchmark utility application JAR file spark-benchmark-assembly-3.3.0.jar that you had built earlier Or if you are using Spark 3.3.0 you could download a pre-built jar: [spark-benchmark-assembly-3.3.0.jar](https://aws-bigdata-blog.s3.amazonaws.com/artifacts/oss-spark-benchmarking/spark-benchmark-assembly-3.3.0.jar)


### 2. Build a docker image of Apache Spark

First change to project root directory, and then build the Spark version 3.3.0. We use Hadoop 3.3.4. Feel free to change the Spark version to the one that you need.
```
cd emr-serverless-benchmark

create a Dockerfile with below content:
===========================================
# Dockerfile
FROM public.ecr.aws/emr-serverless/spark/emr-6.9.0:latest

USER root
ADD spark-benchmark-assembly-3.3.0.jar /usr/lib/spark/jars/spark-benchmark-assembly-3.3.0.jar

# EMRS will run the image as hadoop
USER hadoop:hadoop
===========================================
Copy jar to your project directoty and execute code below:

docker build -t .
```

### 3. Build the Spark Benchmark application as a docker image

Build the benchmark utility based on the Spark version we created above. In order to do that we need to make sure the Dockerfile points to the correct Spark and Hadoop versions. Edit [docker/benchmark-util/Dockerfile](https://github.com/aws-samples/emr-on-eks-benchmark/blob/main/docker/benchmark-util/Dockerfile) and make sure Spark and Hadoop versions are correct. In our example we are benchmarking Spark version 3.3.0.

```
ARG SPARK_VERSION=3.3.0
ARG HADOOP_VERSION=3.3.4
```

Use this Dockerfile to build the benchmark utility as shown below

```
docker build -t eks-spark-benchmark:3.3.0 -f docker/benchmark-util/Dockerfile --build-arg SPARK_BASE_IMAGE=spark:3.3.0_hadoop_3.3.4 .
```

### 4. Copy the benchmark application jar file from the docker image
To do this open two terminals. In the first terminal run a docker container from the image built in the previous step. In the example below we give it a name `spark-benchmark` using the `--name` argument.

```
docker run --name spark-benchmark -it eks-spark-benchmark:3.3.0 bash
```
This should start a bash prompt in your spark-benchmark docker container. If the build was successful, inside the bash prompt in your docker container, you should see a jar file named `eks-spark-benchmark-assembly-1.0.jar` in the `$SPARK_HOME/examples/jars` directory as shown in the example below:

```
hadoop@9ca5b2afe778:/opt/spark/work-dir$ pwd
/opt/spark/work-dir
hadoop@9ca5b2afe778:/opt/spark/work-dir$ cd ../examples/jars
hadoop@9ca5b2afe778:/opt/spark/examples/jars$ ls
eks-spark-benchmark-assembly-1.0.jar  scopt_2.12-3.7.1.jar  spark-examples_2.12-3.3.0.jar
```

On another terminal in Cloud9 running the `docker ps` command shows our running container. Here is an example:

```
sekar:~/environment $ docker ps
CONTAINER ID   IMAGE                       COMMAND                  CREATED         STATUS         PORTS     NAMES
9ca5b2afe778   eks-spark-benchmark:3.3.0   "/opt/entrypoint.sh …"   7 seconds ago   Up 6 seconds             spark-benchmark
```

Now you can copy the eks-spark-benchmark-assembly-1.0.jar file from the docker container into your local directory using `docker cp` command as shown below:

```
docker cp spark-benchmark:/opt/spark/examples/jars/eks-spark-benchmark-assembly-1.0.jar ./spark-benchmark-assembly-3.3.0.jar
```

Optionally, upload benchmark application to S3. Replace `$YOUR_S3_BUCKET` with your S3 bucket name.

```
aws s3 cp spark-benchmark-assembly-3.3.0.jar s3://$YOUR_S3_BUCKET/blog/jar/spark-benchmark-assembly-3.3.0.jar
```
