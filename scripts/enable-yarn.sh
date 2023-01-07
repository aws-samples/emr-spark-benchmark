#!/bin/sh
export HADOOP_PREFIX=/home/ec2-user/hadoop
echo "export HADOOP_PREFIX=$HADOOP_PREFIX" >> ~/.bashrc
echo "export HADOOP_HOME=$HADOOP_PREFIX" >> ~/.bashrc
echo "export HADOOP_COMMON_HOME=$HADOOP_PREFIX" >> ~/.bashrc
echo "export HADOOP_CONF_DIR=$HADOOP_PREFIX/conf" >> ~/.bashrc
echo "export HADOOP_HDFS_HOME=$HADOOP_PREFIX" >> ~/.bashrc
echo "export HADOOP_MAPRED_HOME=$HADOOP_PREFIX" >> ~/.bashrc
echo "export HADOOP_YARN_HOME=$HADOOP_PREFIX" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=/home/ec2-user/hadoop/lib/native/" >> ~/.bashrc

cp $HADOOP_PREFIX/etc/hadoop/capacity-scheduler.xml $HADOOP_PREFIX/conf/
cp $HADOOP_PREFIX/etc/hadoop/log4j.properties $HADOOP_PREFIX/conf/

echo "export LD_LIBRARY_PATH=/lib64" >> $SPARK_HOME/conf/spark-env.sh
echo "export HADOOP_HOME=$HADOOP_PREFIX" >> $SPARK_HOME/conf/spark-env.sh
echo "export HADOOP_CONF_DIR=$HADOOP_PREFIX/conf" >> $SPARK_HOME/conf/spark-env.sh
echo "export SPARK_DIST_CLASSPATH=$HADOOP_PREFIX/share/hadoop" >> $SPARK_HOME/conf/spark-env.sh