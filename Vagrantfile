require 'yaml'

SPEC = YAML.load_file('machines.yml')


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


def insert_key?(config, definition, spec=SPEC)
  pub_key_path = get_from_spec_with_defaults definition, 'pub_key_path', spec
  key = File.readlines(pub_key_path).first.strip

  config.vm.provision 'shell', privileged: false do |shell|
    shell.inline = <<-SHELL
      echo "#{key}" >> $HOME/.ssh/authorized_keys
    SHELL
  end

end


Vagrant.configure(2) do |config|

  config.vm.box = SPEC['vagrant']['box']
  config.vm.synced_folder ".", "/vagrant", disabled: true

  SPEC['inventory'].each do |groupname, elems|
    elems.each do |machine|

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

end
