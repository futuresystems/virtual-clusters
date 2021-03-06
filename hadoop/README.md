# Getting #

```
git clone --recursive https://github.com/futuresystems/virtual-clusters.git
```

# Requirements #

- [ldapget](https://github.com/futuresystems/ldapget)
- python
- ansible
- security groups of hadoop, hadoop-status, sshlb, and webserver
   - rule name (port range)
   - hadoop (1-65535)
   - hadoop-status (8088, 50070, 19888)
   - sshlb (2222)
   - webserver (80, 443)
- ssh-agent if a ssh key is passphrase enabled (ansible uses ssh to install software packages)

# Deployment #

1.  `virtualenv venv && . venv/bin/activate && pip install -r requirements.txt`
1.  `./scripts/openstack-boot machines.yml openstack.yml`
1.  `./scripts/mkInventory openstack.yml > inventory.txt`
1.  `./scripts/mkHosts openstack.yml internal_ip >roles/common/files/hosts`
1.  `./scripts/mkVars openstack.yml`
1.  `until ansible all -m ping -u ubuntu -f $(./scripts/listMachines openstack.yml | wc -l); do sleep 5; done`
1.  `ldapget -p 9389 -P fg475 -o public_keys`
1.  `ls public_keys >users.txt`
1.  `add admin users to admins.txt`
1.  `ansible-playbook site.yml -u ubuntu -f $(./scripts/listMachines openstack.yml | wc -l)`


# Monitoring #

In order to view the Nagios and Ganglia monitoring framework, ssh with X forwarding into the monitor node, install a browser:

```
$ ./scripts/sshMachine openstack.yml monitor1 -l ubuntu -X
$ sudo apt-get install chromium-browser
$ chromium monitor1/ganglia master1:50070 master1:8088
```
