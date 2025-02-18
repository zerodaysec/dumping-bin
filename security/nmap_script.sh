#!/bin/bash
log=/tmp/nmap.log
email=admin@domain.com
nmap_list=~/nmap_list.txt

nmap_opts="-v -O -P0 -sS -sV"

nmap_decoy_ips="-D8.8.8.8,10.5.1.2,4.2.2.2,3.4.2.9"
#if none remove the -D, if ips, leave the -Dx.x.x.x,x.x.x.x
#nmap_decoy_ips=""

echo Scanning Hosts: >> $log
cat $nmap_list >> $log

echo Scanning...
nmap $nmap_opts -iL $nmap_list $nmap_decoy_ips >> $log

echo Emailing log to $email...
cat $log | mail -s "Nmap Script Results" $email
