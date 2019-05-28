#!/usr/bin/expect

set PASSPHRASE [lindex $argv 0]
set PATH_KEYS [lindex $argv 1]
set COMMENT [lindex $argv 2]

#timeout is a predefined variable in expect which by default is set to 10 sec
#spawn_id is another default variable in expect.
#It is good practice to close spawn_id handle created by spawn command
set timeout 10
spawn ssh-keygen -t rsa -C "${COMMENT}" -f "${PATH_KEYS}"
while {1} {
	expect {

		eof				{break}
		"Enter file in which to save the key"	{send "\r"}
		"Overwrite (y/n)"			{send "y\r"}
		"Enter passphrase (empty for no passphrase):"	{send "$PASSPHRASE\r"}
		"Enter same passphrase again:"	{send "$PASSPHRASE\r"}
		"*\]"				{send "exit\r"}
	}
}
catch wait result
exit [lindex $result 3]
