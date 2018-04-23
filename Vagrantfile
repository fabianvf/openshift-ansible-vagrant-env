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
  config.vm.box = "fedora/27-atomic-host"

  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = true

  nodes = (1..(ENV["NUM_NODES"]||3).to_i).map {|i| "node#{i}.example.com"}
  host_vars = {}

  nodes.each_with_index do |name, i|
    ip = "192.168.67.#{11 + i}"
    host_vars[name] = {
      "openshift_ip": ip,
      "openshift_hostname": name
    }
    config.vm.define name do |node|
      node.vm.hostname = name
      node.vm.network :private_network,
        :ip => ip
      node.vm.provider :libvirt do |domain|
        domain.storage :file, :size => '80G', :type => 'raw'
      end

      node.vm.synced_folder '.', '/vagrant', disabled: true

      node.vm.provision :file, :source => "~/.ssh/id_rsa.pub", :destination => "/tmp/key"
      node.vm.provision :shell, :inline => <<-EOF
        setenforce 0
        cat /tmp/key >> /home/vagrant/.ssh/authorized_keys
        mkdir -p /root/.ssh
        cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
        sed -i 's/127.0.0.1.*#{name}.*/192.168.17.10 #{name}/' /etc/hosts
      EOF
    end
  end

  config.vm.define 'master.example.com', :primary => true do |master|
    host_vars['master.example.com'] = {
      "openshift_hostname": "master.example.com",
      "openshift_ip": "192.168.67.10"
    }
    master.vm.hostname = 'master.example.com'
    master.vm.network :private_network,
      :ip => '192.168.67.10'
    master.vm.synced_folder '.', '/vagrant', disabled: true

    master.vm.provision :file, :source => "~/.ssh/id_rsa.pub", :destination => "/tmp/key"
    master.vm.provision :shell, :inline => <<-EOF
      setenforce 0
      cat /tmp/key >> /home/vagrant/.ssh/authorized_keys
      mkdir -p /root/.ssh
      cp /home/vagrant/.ssh/authorized_keys /root/.ssh/authorized_keys
      sed -i 's/127.0.0.1.*master.example.com.*/192.168.17.10 master.example.com/' /etc/hosts
    EOF

    master.vm.provision :ansible do |ansible|
      ansible.playbook = ENV["PLAYBOOK"]||"origin.yml"
      ansible.become = true
      ansible.limit = 'all,localhost'
      # ansible.inventory_path = './inventory'
      ansible.extra_vars = {
        "openshift_ansible_dir": openshift_ansible_dir
      }
      ansible.host_vars = host_vars
      ansible.groups = {
        "masters" => ["master.example.com"],
        "etcd" => ["master.example.com"],
        "nodes" => ["master.example.com"] + nodes,
        # "nfs" => ["default"],
        "OSEv3" => ["master.example.com"] + nodes,
        "OSEv3:vars" => {
          "openshift_image_tag": ENV["IMAGE_TAG"]||"v3.9.0",
          "openshift_pkg_version": "",
          "ansible_python_interpreter" => "/usr/bin/python3",
          "openshift_docker_additional_registries" => 'registry.access.redhat.com,registry.fedoraproject.org',
          "openshift_deployment_type" => "origin",
          "containerized" => true,
          "openshift_use_system_containers" => true,
          "openshift_disable_check" => 'disk_availability,memory_availability,docker_storage',
          "os_update" => true,
          "openshift_master_identity_providers" => [{"name":"allow_all","login":true,"challenge":true,"kind":"AllowAllPasswordIdentityProvider"}].to_json
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
