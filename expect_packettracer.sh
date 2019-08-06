#!/usr/bin/expect

#read the input parameters
set PATH_PT [lindex $argv 0]
cd ${PATH_PT}

#timeout is a predefined variable in expect which by default is set to 300 sec
#spawn_id is another default variable in expect.
#It is good practice to close spawn_id handle created by spawn command
set timeout 300
spawn ./install
while {1} {
  expect {

    eof            {break}
    "Press the Enter key to read the EULA."   {send "\r"}
    "More--"       {send "\r"}
    "Do you accept the terms of the EULA? (Y)es/(N)o"  {send "Y\r"}
    "Enter location to install Cisco Packet Tracer or press enter for default" {send "/opt/pt\r"}
    "in /usr/local/bin for easy Cisco Packet Tracer startup?"       {send "Y\r"}
  }
}
catch wait result
exit [lindex $result 3]
