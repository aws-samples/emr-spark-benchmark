# Steps to build spark-benchmark-assembly application

## Pre-requisites
We can complete all the steps either from a local desktop or using [AWS Cloud9](https://aws.amazon.com/cloud9/).  If you’re using AWS Cloud9, follow the instructions in the first step to spin up an AWS Cloud9 environment, otherwise skip to the next step.

### 1. Setup AWS Cloud9
AWS Cloud9 is a cloud-based IDE that lets you write, run, and debug your code with just a browser. AWS Cloud9 comes preconfigured with many of the dependencies we require to build our application.

Create an AWS Cloud9 environment from the [AWS Management Console[(https://console.aws.amazon.com/cloud9)] with an instance type of t3.small or larger. For our testing we used m5.xlarge for adequate memory and CPU to compile and build our benchmark application. Provide the required name, and leave the remaining default values. After your environment is created, you should have access to a terminal window. If you are new to AWS Cloud9 follow [this tutorial](https://docs.aws.amazon.com/cloud9/latest/user-guide/tutorial.html) to create your environment.

You must increase the size of the [Amazon Elastic Block Store (Amazon EBS)](https://aws.amazon.com/ebs/) volume attached to your AWS Cloud9 instance to 20 GB, because the default size (10 GB) is not enough. For instructions, refer to [Resize an Amazon EBS volume used by an environment](https://docs.aws.amazon.com/cloud9/latest/user-guide/move-environment.html#move-environment-resize).

### 2. Install Docker if required
AWS Cloud9 EC2 instance m5.xlarge comes with Docker pre-installed. Depending on your environment you may or may not need to install Docker. To install Docker follow the instructions in the [Docker Desktop page](https://docs.docker.com/desktop/#download-and-install).

## Build Benchmark application

To build our application we are going to reuse the source code for TPCDS benchmarking application that was used to build a similar benchmarking utility from [the EMR on EKS benchmark Github repo](https://github.com/aws-samples/emr-on-eks-benchmark).

### 1. Download the source code from Github repo as shown below:
```
git clone https://github.com/aws-samples/emr-on-eks-benchmark.git
```

### 2. Build a docker image of Apache Spark

First change to project root directory, and then build the Spark base image. In this example, we use Spark version 3.3.0 and Hadoop 3.3.4. Feel free to change these versions if needed.
```
cd emr-on-eks-benchmark

export SPARK_VERSION=3.3.0
export HADOOP_VERSION=3.3.4
```

```
docker build -t spark:$SPARK_VERSION_hadoop_$HADOOP_VERSION -f docker/hadoop-aws-3.3.1/Dockerfile --build-arg HADOOP_VERSION=$HADOOP_VERSION --build-arg SPARK_VERSION=$SPARK_VERSION .
```

### 3. Build the Spark Benchmark application as a docker image

Build the benchmark utility image based on the Spark based image built above. In order to do that, we need to make sure the following build argument contains the `SPARK_BASE_IMAGE` parameter:

```
--build-arg SPARK_BASE_IMAGE=spark:$SPARK_VERSION_hadoop_$HADOOP_VERSION
```


Use Dockerfile to compile the benchmark utility as shown below:

```
docker build -t eks-spark-benchmark:$SPARK_VERSION -f docker/benchmark-util/Dockerfile --build-arg SPARK_BASE_IMAGE=spark:$SPARK_VERSION_hadoop_$HADOOP_VERSION .
```

### 4. Locate the benchmark application jar file within a docker image
Run a docker container from the image built in the previous step. In the example below we give it a name `spark-benchmark` using the `--name` argument.

```
docker run --name spark-benchmark -it eks-spark-benchmark:$SPARK_VERSION bash
```
This should start an interactive session to your spark-benchmark docker container. If the login was successful, you should be able to run bash scripts as usual. You should see a jar file named `eks-spark-benchmark-assembly-1.0.jar` under the `$SPARK_HOME/examples/jars` directory as shown in the example below:

```
hadoop@9ca5b2afe778:/opt/spark/work-dir$ pwd
/opt/spark/work-dir
hadoop@9ca5b2afe778:/opt/spark/work-dir$ cd ../examples/jars
hadoop@9ca5b2afe778:/opt/spark/examples/jars$ ls
eks-spark-benchmark-assembly-1.0.jar  scopt_2.12-3.7.1.jar  spark-examples_2.12-3.3.0.jar
# optionally, directly upload the benchmark-assembly jar file to S3 bucket within the docker container if you are testing EMR's Spark.
```

### 5. Copy the jar and upload to S3

On a second terminal of Cloud9 or your local computer, run the `docker ps` command to find your running container and its name. Here is an example:

```
sekar:~/environment $ docker ps
CONTAINER ID   IMAGE                       COMMAND                  CREATED         STATUS         PORTS     NAMES
9ca5b2afe778   eks-spark-benchmark:3.3.0   "/opt/entrypoint.sh …"   7 seconds ago   Up 6 seconds             spark-benchmark
```

Now you can copy the compiled benchmark utility file from the running container to a local host via the syntax `docker cp <container_name>:/path/to/example.txt ./path/to/localhost`. 

For example:

```
docker cp spark-benchmark:/opt/spark/examples/jars/eks-spark-benchmark-assembly-1.0.jar ./spark-benchmark-assembly-3.3.0.jar

```
To test EMR Spark runtime, upload the benchmark application to S3. Replace $YOUR_S3_BUCKET with your S3 bucket name. To test open-source Apache Spark, you must download the file to your local host.
```
aws s3 cp spark-benchmark-assembly-3.3.0.jar s3://$YOUR_S3_BUCKET/blog/jar/spark-benchmark-assembly-3.3.0.jar

```


