# hadoop_docker_flashblade

For these scripts to work, the following additional steps are needed:
 * Ansible host group containing all nodes that will run Yarn workers.
 * NFS filesystem and data VIP created and configured in control_yarn.sh.
 * core-site.xml, mapred-site.xml, yarn-site.xml.


Example command to run inside the Hadoop client container:
```
DATASIZE=1000000000000
PARTITIONS=1000
hadoop fs -rm -r s3a://joshuarobinson/randomtext
time hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar randomtextwriter -D mapreduce.randomtextwriter.totalbytes=${DATASIZE} -D mapreduce.randomtextwriter.bytespermap=$(( ${DATASIZE} / ${PARTITIONS} )) -D mapreduce.job.maps=${PARTITIONS} -D mapreduce.job.reduces=${PARTITIONS} s3a://joshuarobinson/randomtext


time hadoop jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar grep s3a://joshuarobinson/randomtext s3a://joshuarobinson/randomtext-grepped grepstring
```
