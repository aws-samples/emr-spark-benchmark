#!/bin/bash

# SPDX-FileCopyrightText: Copyright 2023 Amazon.com, Inc. or its affiliates.
# SPDX-License-Identifier: MIT-0

export AWS_REGION=us-east-1
export ACCOUNTID=$(aws sts get-caller-identity --query Account --output text)
export ECR_URL="$ACCOUNTID.dkr.ecr.$AWS_REGION.amazonaws.com"
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL
aws ecr delete-repository --repository-name eks-spark-benchmark --force
aws ecr delete-repository --repository-name spark --force
