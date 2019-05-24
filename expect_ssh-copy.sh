#!/usr/bin/expect

#read the input parameters
set HOST_USER [lindex $argv 0]
set HOST_IP [lindex $argv 1]
set PASSWD [lindex $argv 2]
set PATH_KEYS [lindex $argv 3]

#timeout is a predefined variable in expect which by default is set to 10 sec
#spawn_id is another default variable in expect.
#It is good practice to close spawn_id handle created by spawn command
set timeout 10
spawn ssh-copy-id -i "${PATH_KEYS}.pub" "${HOST_USER}@${HOST_IP}"
while {1} {
	expect {

		eof				{break}
		"Are you sure you want to continue connecting (yes/no)?"	{send "yes\r"}
		"password:"			{send "$PASSWD\r"}
		"*\]"				{send "exit\r"}
	}
}
wait
close $spawn_id

