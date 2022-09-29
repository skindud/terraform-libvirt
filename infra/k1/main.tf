# instance the provider
provider "libvirt" {
  uri = "qemu+ssh://ansible@***/system?known_hosts_verify=ignore"
}

resource "libvirt_volume" "volume" {
  count = length(var.hostname)
  name = "volume-${var.hostname[count.index]}"
  pool = "images"
  format = "qcow2"
  base_volume_pool = "cimages-pool"
  base_volume_name = "Fedora-Cloud-Base-36-1.5.x86_64.qcow2"
}

# https://github.com/hashicorp/terraform/issues/1893
data "template_file" "user_data" {
  count = length(var.hostname)
  template = file("${path.module}/cloud_init.cfg")
  vars = {
    hostname = element(var.hostname, count.index)
    fqdn = "${var.hostname[count.index]}.${var.domain}"
  }
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

# https://github.com/dmacvicar/terraform-provider-libvirt/blob/master/website/docs/r/cloudinit.html.markdown
resource "libvirt_cloudinit_disk" "commoninit" {
  count          = length(var.hostname)
  name           = "commoninit-${count.index}.iso"
  user_data      = data.template_file.user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = "images"
}

# Create the machine
resource "libvirt_domain" "domain" {
  # timeouts {
  #   create = "1m"
  #   update = "1m"
  #   delete = "1m"
  # }
  count  = length(var.hostname)
  name   = "${var.hostname[count.index]}"
  description = "desc1-${var.GITLAB_USER_EMAIL}\n${var.GITLAB_USER_NAME}\n${var.CI_PROJECT_URL}\n${var.CI_PIPELINE_URL}"
  memory = var.memoryMB
  vcpu = var.cpu

  # cloudinit = libvirt_cloudinit_disk.commoninit
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  # cloudinit = "${element(libvirt_cloudinit_disk.commoninit, count.index)}"

  #[count.index]
  # element(libvirt_volume.volume.*.id, count.index)

  network_interface {
    bridge = "br0"
    mac    = "${var.mac[count.index]}"
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = element(libvirt_volume.volume.*.id, count.index)
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

terraform {
  # required_version = ">= 0.12"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

