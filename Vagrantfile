# -*- mode: ruby -*-
# vi: set ft=ruby :

openshift_ansible_dir = nil
SEARCH_DIRS = [
  ENV["OPENSHIFT_ANSIBLE_DIR"], './openshift-ansible',
  '../openshift-ansible',
  '~/openshift-ansible',
  '/usr/share/ansible/openshift-ansible'
].compact

SEARCH_DIRS.each {|candidate|
  if Dir.exists?(candidate)
    openshift_ansible_dir = candidate
    puts "\033[32mUsing openshift-ansible from '#{candidate}'\033[0m"
    break
  end
}

if openshift_ansible_dir.nil?
  Kernel.abort("\033[31mopenshift-ansible not found in any of #{SEARCH_DIRS}, if it exists somewhere else please set the OPENSHIFT_ANSIBLE_DIR environment variable\033[0m")
end

Vagrant.configure("2") do |config|
  # if ENV["ATOMIC"]
  config.vm.box = "fedora/27-atomic-host"
  # else
  #   config.vm.box = "fedora/27-cloud-base"
  # end
  #
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  nodes = (1..(ENV["NUM_NODES"]||3).to_i).map {|i| "node#{i}.example.com"}

  nodes.each_with_index do |name, i|
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network :private_network,
        :ip => "192.168.67.#{11 + i}"
      node.vm.provider :libvirt do |domain|
        domain.storage :file, :size => '80G', :type => 'raw'
      end
    end
  end


  config.vm.define 'master.example.com', :primary => true do |master|
    master.vm.hostname = 'master.example.com'
    master.vm.network :private_network,
      :ip => '192.168.67.10'

    master.vm.synced_folder '.', '/vagrant', disabled: true

    master.vm.provision :file, :source => "~/.ssh/id_rsa.pub", :destination => "/tmp/key"
    master.vm.provision :shell, :inline => <<-EOF
      cat /tmp/key >> /home/vagrant/.ssh/authorized_keys
      mkdir -p /root/.ssh
      cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
    EOF

    master.vm.provision :ansible do |ansible|
      ansible.playbook = "origin.yml"
      ansible.become = true
      ansible.limit = 'all,localhost'
      # ansible.inventory_path = './inventory'
      ansible.extra_vars = {
        "openshift_ansible_dir": openshift_ansible_dir
      }
      ansible.groups = {
        "masters" => ["master.example.com"],
        "etcd" => ["master.example.com"],
        "nodes" => nodes,
        # "nfs" => ["default"],
        "OSEv3" => ["master.example.com"] + nodes,
        "OSEv3:vars" => {
          "openshift_image_tag": "v3.9.0",
          "openshift_pkg_version": "",
          "ansible_python_interpreter" => "/usr/bin/python3",
          "openshift_docker_additional_registries" => 'registry.access.redhat.com,registry.fedoraproject.org',
          "openshift_deployment_type" => "origin",
          "containerized" => true,
          "openshift_use_system_containers" => true,
          "openshift_disable_check" => 'disk_availability,memory_availability,docker_storage',
          "os_update" => true,
          "openshift_master_identity_providers" => '[{\"name\":\"allow_all\",\"login\":true,\"challenge\":true,\"kind\":\"AllowAllPasswordIdentityProvider\"}]'
        }
      }
    end
  end


  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.memory = 4096
    libvirt.cpus = `grep -c ^processor /proc/cpuinfo`.to_i
    libvirt.volume_cache = 'unsafe'
  end
end
