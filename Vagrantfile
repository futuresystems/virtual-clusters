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
    case attr
    when "memory"
      provider.memory = val
    when "cpus"
      provider.cpus = val
    when "nested"
      provider.nested = val
    end
  end

end

Vagrant.configure(2) do |config|

  config.vm.box = SPEC['vagrant']['box']
  config.vm.synced_folder ".", "/vagrant", disabled: true

  SPEC['inventory'].each do |groupname, elems|
    elems.each do |machine|
      puts machine

      config.vm.define machine['name'] do |node|
 
        netmask = get_from_spec_with_defaults machine, 'netmask'
        hostname = machine.fetch 'hostname', machine['name']

        node.vm.hostname = hostname
        node.vm.network :private_network,
                        :ip => machine['ip'],
                        :netmask => netmask

        set_node_property? config, machine, "memory"
        set_node_property? config, machine, "cpus"
        set_node_property? config, machine, "nested"
        

      end
    end
  end

end
