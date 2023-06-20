# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "homelab"
  config.vm.box = "archlinux/archlinux"
  config.vm.synced_folder '.', '/vagrant', disabled: true

  config.vm.provider :libvirt do |libvirt|
    libvirt.driver = "kvm"
    libvirt.memory = 1024
    libvirt.cpus = 4

    # Linux seems to have trouble booting without some form of output, so we can't disable the graphic output
    # A possible workaround would be to use a serial console
    # libvirt.graphics_type = "none"
    # libvirt.video_type = "none"

    libvirt.storage :file, :size => "1G", :path => "disk1.qcow2"
    libvirt.storage :file, :size => "1G", :path => "disk2.qcow2"
  end

  # Install python so ansible can run
  config.vm.provision "shell", inline: "pacman -Sy --noconfirm python"

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "../provisionning/main.yml"
  end
end
