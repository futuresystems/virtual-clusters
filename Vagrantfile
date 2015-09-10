require 'yaml'

SPEC_FILE = 'machines.yml'
SPEC = YAML.load_file(SPEC_FILE)
INVENTORY_FILE = 'inventory.txt'
ZK_URL_FILE = 'zk_url.txt'
HOSTS_FILE = 'hosts'

def get_from_spec_with_defaults(definition, attr, spec=SPEC)
  if definition.has_key?(attr)
      definition[attr]
  else
    spec['defaults'][attr]
  end
end


def set_node_property?(config, definition, attr, spec=SPEC)
  val = get_from_spec_with_defaults definition, attr, spec

  config.vm.provider spec['vagrant']['provider'] do |provider|
    provider.send("#{attr}=", val)
  end

end


def get_public_key(private_key_path)
  # if ssh-agent is running, use it to get the public key
  if ENV.has_key? 'SSH_AGENT_PID' then
    cmd = "ssh-add -L | grep #{private_key_path}"
  else
    cmd = "ssh-keygen -yf #{private_key_path}"
  end

  pub_key = `#{cmd}`.strip

  if $? != 0 then
    raise IOError, "Command '#{cmd}' failed with #{$?}"
  end

  if pub_key.empty? then
    raise RuntimeError, "Got empty string for public key using '#{cmd}'"
  end

  return pub_key

end

def insert_key?(config, definition, spec=SPEC)
  config.vm.provision 'shell', privileged: false do |shell|

    key_path = get_from_spec_with_defaults definition, 'key_path', spec
    key_path = File.expand_path key_path
    pub_key  = get_public_key key_path

    shell.inline = <<-SHELL
      echo "key: #{key_path}"
      echo "#{pub_key}" >> $HOME/.ssh/authorized_keys
    SHELL
  end

end


Vagrant.configure(2) do |config|

  config.vm.box = SPEC['vagrant']['box']
  config.vm.synced_folder ".", "/vagrant", disabled: true

  SPEC['machines'].each do |machine|

    config.vm.define machine['name'] do |node|
 
      netmask = get_from_spec_with_defaults machine, 'netmask'
      hostname = machine.fetch 'hostname', machine['name']

      node.vm.hostname = hostname
      node.vm.network :private_network,
                      ip: machine['ip'],
                      netmask: netmask

      set_node_property? config, machine, "memory"
      set_node_property? config, machine, "cpus"
      set_node_property? config, machine, "nested"
        
      insert_key? config, machine

    end
  end

end


print `./scripts/mkInventory #{SPEC_FILE} | tee #{INVENTORY_FILE}`
`./scripts/mkZookeeperUrl #{SPEC_FILE} > #{ZK_URL_FILE}`
`./scripts/mkHosts #{SPEC_FILE} > #{HOSTS_FILE}`
