FROM openjdk:8-slim

# Expects a version string, e.g. "2.7.3" or "3.1.1"
ARG HADOOP_VERSION

# Install wget for the build process; will remove later.
RUN apt-get update && apt-get install -y wget --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# Download and extract the Hadoop binary package.
RUN wget -qO- https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
	| tar xvz -C /opt/  \
	&& ln -s /opt/hadoop-$HADOOP_VERSION /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc \
	&& apt-get --purge remove -y wget \
	&& apt-get autoremove -y

# Add config files.
COPY mapred-site.xml /opt/hadoop/etc/hadoop/
COPY core-site.xml /opt/hadoop/etc/hadoop/
COPY yarn-site.xml /opt/hadoop/etc/hadoop/

# Add S3a jars to the classpath using this hack.
# Note: HADOOP_OPTIONAL_TOOLS should have worked, but is not correctly picked up by Yarn apps.
RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

# Add 'hadoop' user so that this cluster is not run as root.
RUN groupadd -g 1080 hadoop && \
    useradd -r -m -u 1080 -g hadoop hadoop && \
    mkdir -p /opt/hadoop/logs && \
    chown -R -L hadoop /opt/hadoop && \
    chgrp -R -L hadoop /opt/hadoop

USER hadoop
WORKDIR /home/hadoop

# Set necessary environment variables. 
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/hadoop/bin:${PATH}"

ENTRYPOINT ["tail", "-f", "/dev/null"]
