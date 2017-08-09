# Kubernetes Cluster on GCE Terraform Module

Modular Kubernetes Cluster for GCE.

## Usage

```ruby
module "k8s" {
  source      = "/Users/disla/Projects/terraform-google-modules/terraform-google-k8s-gce"
  name        = "dev"
  network     = "k8s"
  region      = "${var.region}"
  zone        = "${var.zone}"
  k8s_version = "1.7.3"
  num_nodes   = "${var.num_nodes}"
}
```

### Input variables

- `name` (required): The name of the kubernetes cluster. Note that nodes names will be prefixed with `k8s-`.
- `version` (optional): The version of kubernetes to use. See available versions using: `apt-cache madison kubelet`. Default is `1.7.3`
- `cni_version` (optional): The version of the kubernetes cni resources to install. See available versions using: `apt-cache madison kubernetes-cni`. Default is `0.5.1`.
- `docker_version` (optional): The version of Docker to install. See available versions using: `apt-cache madison docker-ce`. Default is `17.06.0`
- `compute_image` (optional): The project/image to use on the master and nodes. Must be ubuntu or debian 8+ compatible. Default is `ubuntu-os-cloud/ubuntu-1704`.
- `network` (optional): The network to deploy to. Default is `default`.
- `region` (optional): The region to create the cluster in. Default is `us-central1`
- `zone` (optional): The zone to create the cluster in.. Default is `us-central1-f`.
- `master_machine_type` (optional): The machine tyoe for the master node. Default is `n1-standard-4`.
- `node_machine_type` (optional): The machine tyoe for the nodes. Default is `n1-standard-4`.
- `num_nodes` (optional): The number of nodes. Default is `3`.
- `add_tags` (optional): Additional list of tags to add to the nodes.
- `master_ip` (optional): The internal IP of the master node. Note this must be in the CIDR range of the region and zone. Default is `10.128.0.10`.
- `pod_cidr` (optional): The CIDR for the pod network. The master will allocate a portion of this subnet for each node. Default is `10.12.0.0/14`.
- `service_cidr` (optional): The CIDR for the service network. Default is `10.15.240.0/20`.
- `dns_ip` (optional): The IP of the kube DNS service, must live within the service_cidr. Default is `10.15.240.10`.


### Output variables

- `master_ip`: The internal address of the master.

## Resources created

**Figure 1.** *diagram of terraform resources*

- [`module.master-mig`](https://github.com/danisla/terraform-google-managed-instance-group): Managed instance group for the master node.
- [`module.default-pool-mig`](https://github.com/danisla/terraform-google-managed-instance-group): Managed instance group for the nodes.
