Get-ADUser -Filter *

Get-ADUser -identity USERNAME_HERE -properties *

#Get-ADUser -searchbase "ou=specialusers,ou=users,dc=mydomain,dc=com" -filter * -Properties Department | Select-Object name, department > c:\temp\myfile.csv

Get-ADUser -filter * -Properties Department | Select-Object name, department > c:\temp\myfile.csv
