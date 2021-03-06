require 'yaml'

SPEC_FILE = 'machines.yml'
SPEC = YAML.load_file(SPEC_FILE)
INVENTORY_FILE = 'inventory.txt'
HOSTS_FILE = 'hosts'

PROVIDER_DEFAULTS = {
  :libvirt => {
    :storage => {
      :size => '10G',
      :type => 'qcow2',
      :bus  => 'virtio',
      :cache => 'default'
    }
  }
}

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


def set_node_storage_libvirt(config, disk_definition)

  defaults = PROVIDER_DEFAULTS[:libvirt][:storage]

  config.vm.provider :libvirt do |libvirt|
    options = {
      :size  => disk_definition.fetch('size', defaults[:size]),
      :type  => disk_definition.fetch('type', defaults[:type]),
      :bus   => disk_definition.fetch('bus', defaults[:bus]),
      :cache => disk_definition.fetch('cache', defaults[:cache])
    }

    if disk_definition.has_key? 'device' then
      options[:device] = disk_definition['device']
    end

    libvirt.storage(:file, **options)

  end

end


def set_node_storage?(config, definition, spec=SPEC)

  extra_disks = get_from_spec_with_defaults definition, 'extra_disks', spec

  if extra_disks.nil? then
    return
  end

  provider = spec['vagrant']['provider']

  case provider
  when "libvirt"
    add_disk = :set_node_storage_libvirt
  else
    raise RuntimeError, "Unknown provider #{provider}"
  end

  extra_disks.each do |disk|
    send add_disk, config, disk
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
      set_node_storage? config, machine        

      insert_key? config, machine


    end
  end

end


# print `./scripts/mkInventory #{SPEC_FILE} > #{INVENTORY_FILE}`
# `./scripts/mkHosts  #{SPEC_FILE} > #{HOSTS_FILE}`
