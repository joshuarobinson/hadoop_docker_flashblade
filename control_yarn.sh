#!/bin/bash

# Image and repository name to pull images.
IMGNAME=joshuarobinson/fb-hadoop-3.1.1

# NFS server and path that should be exposed to Hadoop as datahub paths.
DATAHUB_IP="10.62.64.200"
DATAHUB_FS="root"

# Name of Ansible host group for Hadoop workers and degree of task parallelism.
HOSTGRP="irp210 -f 24"

if [ "$1" == "start" ]; then
	echo "Starting"
		
	echo "Checking for latest container image."
	./build_image.sh
	ansible $HOSTGRP -a "docker pull $IMGNAME"

	echo "Creating NFS datahub mounts..."	
	docker volume create --driver local --opt type=nfs --opt o=addr=$DATAHUB_IP,rw \
		--opt=device=:/$DATAHUB_FS hadoop-datahub
	ansible $HOSTGRP -a "docker volume create --driver local --opt type=nfs --opt o=addr=$DATAHUB_IP,rw \
		--opt=device=:/$DATAHUB_FS hadoop-datahub"

	echo "Starting ResourceManager"
	docker run -d --rm --net=host \
		--name hadoop-rm \
		-v hadoop-datahub:/datahub \
		$IMGNAME
	docker exec hadoop-rm yarn --daemon start resourcemanager

	echo "Starting NodeManagers"
	ansible $HOSTGRP -a "docker run -d --rm --net=host \
		--name hadoop-nm \
		-v hadoop-datahub:/datahub \
		$IMGNAME"
	ansible $HOSTGRP -a "docker exec hadoop-nm yarn --daemon start nodemanager"

	echo "Starting client container"
	docker run -idt --net=host \
		--name hadoop-client \
		--restart=always \
		-v hadoop-datahub:/datahub \
		--entrypoint=/bin/bash \
		$IMGNAME
	echo "Connect to the client with: docker attach hadoop-client"

elif [ "$1" == "stop" ]; then

	docker stop hadoop-client
	docker rm hadoop-client

	echo "Stopping yarn services"
	ansible $HOSTGRP -a "docker exec hadoop-nm yarn --daemon stop nodemanager"
	docker exec hadoop-rm yarn --daemon stop resourcemanager

	echo "Stopping NodeManager/ResourceManager containers"
	ansible $HOSTGRP -a "docker stop hadoop-nm"
	docker stop hadoop-rm

	echo "Removing datahub mounts..."
	docker volume rm hadoop-datahub
	ansible $HOSTGRP -a "docker volume rm hadoop-datahub"
else
	echo "Usage: $0 [start|stop]"
fi
