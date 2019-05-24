#!/bin/bash

PATH_ENABLED="playbooks-enabled"

rm -rf ${PATH_ENABLED}
mkdir ${PATH_ENABLED}
cd ${PATH_ENABLED}

for playbook in $( ls ../playbooks-available/*.yml ); do
	linkpb=${playbook/'../playbooks-available/'/}
   if [ -L ${linkpb} ]; then
       rm ${linkpb}
   fi
   ln -s ${playbook} ${linkpb}
done

cd ..
