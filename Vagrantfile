Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  #config.vm.box = "fedora/27-atomic-host"
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.vm.hostname = 'test-origin.example.com'
  config.vm.provision "ansible" do |ansible|
    ansible.verbose = "vvv"
    ansible.sudo = true
    ansible.playbook = "origin.yml"
    ansible.limit = 'all,localhost'
    ansible.groups = {
      "masters" => ["default"],
      "nodes" => ["default"],
      "nfs" => ["default"],
      "OSEv3" => ["default"],
      "etcd" => ["default"],
    }
    ansible.host_vars = {
      "default" => {
        "openshift_image_tag": "latest",
        "openshift_pkg_version": "",
        "openshift_python_interpreter" => "/usr/bin/python3",
        "openshift_docker_additional_registries" => 'registry.access.redhat.com,registry.fedoraproject.org',
        "openshift_deployment_type" => "origin",
        "containerized" => true,
        "openshift_schedulable" => true,
        "openshift_disable_check" => 'disk_availability,memory_availability,docker_storage',
        "os_update" => true,
        "openshift_master_identity_providers" => '[{\"name\":\"allow_all\",\"login\":true,\"challenge\":true,\"kind\":\"AllowAllPasswordIdentityProvider\"}]',
        "openshift_node_labels" => '{\"region\":\"infra\",\"zone\":\"default\"}'
      }
    }
  end

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.memory = 4096
    libvirt.cpus = `grep -c ^processor /proc/cpuinfo`.to_i
    libvirt.volume_cache = 'unsafe'
  end
end
