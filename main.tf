data "template_file" "core-init" {
  template = "${file("${format("%s/scripts/k8s-core.sh.tpl", path.module)}")}"

  vars {
    dns_ip         = "${var.dns_ip}"
    docker_version = "${var.docker_version}"
    k8s_version    = "${var.k8s_version}"
    cni_version    = "${var.cni_version}"
  }
}

data "template_file" "master-bootstrap" {
  template = "${file("${format("%s/scripts/master.sh.tpl", path.module)}")}"

  vars {
    k8s_version     = "${var.k8s_version}"
    pod_cidr        = "${var.pod_cidr}"
    service_cidr    = "${var.service_cidr}"
    token           = "${random_id.token-part-1.hex}.${random_id.token-part-2.hex}"
    cluster_uid     = "${random_id.cluster-uid.hex}"
    tags            = "${join(",", concat(list("${random_id.instance-prefix.hex}"), var.add_tags))}"
    instance_prefix = "${random_id.instance-prefix.hex}"
  }
}

data "template_file" "node-bootstrap" {
  template = "${file("${format("%s/scripts/node.sh.tpl", path.module)}")}"

  vars {
    master_ip = "${var.master_ip}"
    token     = "${random_id.token-part-1.hex}.${random_id.token-part-2.hex}"
  }
}

data "template_file" "iptables" {
  template = "${file("${format("%s/scripts/iptables.sh.tpl", path.module)}")}"
}

resource "random_id" "token-part-1" {
  byte_length = 3
}

resource "random_id" "token-part-2" {
  byte_length = 8
}

resource "random_id" "cluster-uid" {
  byte_length = 8
}

resource "random_id" "instance-prefix" {
  byte_length = 4
  prefix      = "k8s-${var.name}-"
}

data "template_cloudinit_config" "master" {
  base64_encode = true
  gzip          = true

  part {
    filename     = "scripts/per-instance/10-k8s-core.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.core-init.rendered}"
  }

  part {
    filename     = "scripts/per-instance/20-master.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.master-bootstrap.rendered}"
  }

  // per boot
  part {
    filename     = "scripts/per-boot/10-iptables.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.iptables.rendered}"
  }
}

data "template_cloudinit_config" "node" {
  base64_encode = true
  gzip          = true

  part {
    filename     = "scripts/per-instance/10-k8s-core.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.core-init.rendered}"
  }

  part {
    filename     = "scripts/per-instance/20-node.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.node-bootstrap.rendered}"
  }

  // per boot
  part {
    filename     = "scripts/per-boot/10-iptables.sh"
    content_type = "text/x-shellscript"
    content      = "${data.template_file.iptables.rendered}"
  }
}

module "master-mig" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  name              = "${random_id.instance-prefix.hex}-master"
  region            = "${var.region}"
  zone              = "${var.zone}"
  network           = "${var.network}"
  network_ip        = "${var.master_ip}"
  can_ip_forward    = true
  size              = 1
  compute_image     = "${var.compute_image}"
  machine_type      = "${var.master_machine_type}"
  target_tags       = ["${concat(list("k8s-${var.name}"), var.add_tags)}"]
  service_port      = 80
  service_port_name = "http"

  metadata {
    user-data          = "${data.template_cloudinit_config.master.rendered}"
    user-data-encoding = "base64"
  }

  // run shutdown script to ensure routes and fw rules are cleaned up by the kube-controller.
  local_cmd_destroy = "gcloud compute ssh $(gcloud compute instances list --filter='networkInterfaces[0].networkIP=${var.master_ip}' --format='csv[no-heading](name)') --command 'sudo bash /etc/kubernetes/shutdown.sh' || true"
}

module "default-pool-mig" {
  source            = "github.com/danisla/terraform-google-managed-instance-group"
  name              = "${random_id.instance-prefix.hex}-default-pool"
  region            = "${var.region}"
  zone              = "${var.zone}"
  network           = "${var.network}"
  can_ip_forward    = true
  size              = "${var.num_nodes}"
  compute_image     = "${var.compute_image}"
  machine_type      = "${var.node_machine_type}"
  target_tags       = ["${concat(list("k8s-${var.name}"), var.add_tags)}"]
  service_port      = 80
  service_port_name = "http"

  metadata {
    user-data          = "${data.template_cloudinit_config.node.rendered}"
    user-data-encoding = "base64"
  }
}
