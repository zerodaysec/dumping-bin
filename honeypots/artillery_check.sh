#!/bin/bash

boxes="tok01 dal01 lon01"

for i in $boxes
do
status=`ssh -p 9022 root@$i "/etc/init.d/artillery status"`

echo $status
restart=`ssh -p 9022 root@$i "/etc/init.d/artillery restart"`
echo $restart
done
