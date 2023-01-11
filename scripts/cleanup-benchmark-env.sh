#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2023 Amazon.com, Inc. or its affiliates.
# SPDX-License-Identifier: MIT-0

export YOUR_S3_BUCKET=prabu-oss-test-bucket
export YOUR_CLUSTERID=j-3T7T1GLEL5BVB
export OSS_SPARK_CLUSTER=bigdata-cluster
aws emr terminate-clusters --cluster-ids $YOUR_CLUSTERID

# Make sure flintrock is in your path. To do this, add the Python bin directory to your environment path. For example,
# export PATH=$PATH:~/Library/Python/3.8/bin
flintrock destroy $OSS_SPARK_CLUSTER
aws s3 rm s3://$YOUR_S3_BUCKET --recursive
aws s3api delete-bucket --bucket $YOUR_S3_BUCKET
