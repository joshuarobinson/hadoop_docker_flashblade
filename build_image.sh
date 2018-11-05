#!/bin/bash

set -e

#  Variables.
HADOOPVER=3.1.1
REPONAME=joshuarobinson

# Build Hadoop image.
docker build --build-arg HADOOP_VERSION=$HADOOPVER \
	-t fb-hadoop-$HADOOPVER .

# Tag and push to the public docker repository.
docker tag fb-hadoop-$HADOOPVER $REPONAME/fb-hadoop-$HADOOPVER
docker push $REPONAME/fb-hadoop-$HADOOPVER
