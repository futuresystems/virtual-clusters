# Getting #

```
git clone --recursive https://github.com/futuresystems/virtual-clusters.git
```

# Requirements #

- [ldapget](https://github.com/futuresystems/ldapget)
- python
- ansible


# Deployment #

0.  `virtualenv venv && . venv/bin/activate && pip install -r requirements.txt`
1.  `./scripts/openstack-boot machines.yml openstack.yml`
2.  `./scripts/mkInventory openstack.yml > inventory.txt`
3.  `./scripts/mkHosts openstack.yml internal_ip >roles/common/files/hosts`
4.  `until ansible all -m ping -u ubuntu -f $(./scripts/listMachines openstack.yml | wc -l); do sleep 5; done`
5.  `ldapget -p 9389 -P fg475 -o public_keys`
6.  `ls public_keys >users.txt`
7.  `add admin users to admins.txt`
8.  `ansible-playbook site.yml -u ubuntu -f $(./scripts/listMachines openstack.yml | wc -l)`


# Monitoring #

In order to view the Nagios and Ganglia monitoring framework, ssh with X forwarding into the monitor node, install a browser:

```
$ ./scripts/sshMachine openstack.yml monitor1 -l ubuntu -X
$ sudo apt-get install chromium-browser
$ chromium monitor1/ganglia master1:50070 master1:8088
```
