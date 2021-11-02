#!/bin/bash
ansible tag_Service_resource:tag_Service_edge -b --become-user root -a "systemctl reload nginx-consul"