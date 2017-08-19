variable name {
  description = "The name of the kubernetes cluster. Note that nodes names will be prefixed with `k8s-`"
}

variable cluster_uid {
  description = "The cluster uid"
  default     = ""
}

variable k8s_version {
  description = "The version of kubernetes to use. See available versions using: `apt-cache madison kubelet`"
  default     = "1.7.4"
}

variable dashboard_version {
  description = "The version tag of the kubernetes dashboard, per the tags in the repo: https://github.com/kubernetes/dashboard"
  default     = "v1.6.3"
}

variable cni_version {
  description = "The version of the kubernetes cni resources to install. See available versions using: `apt-cache madison kubernetes-cni`"
  default     = "0.5.1"
}

variable docker_version {
  description = "The version of Docker to install. See available versions using: `apt-cache madison docker-ce`"
  default     = "17.06.0"
}

variable calico_version {
  description = "Version of Calico to install for pod networking."
  default     = "2.4"
}

variable compute_image {
  description = "The project/image to use on the master and nodes. Must be ubuntu or debian 8+ compatible."
  default     = "ubuntu-os-cloud/ubuntu-1704"
}

variable network {
  description = "The network to deploy to"
  default     = "default"
}

variable pod_network_type {
  description = "The type of networking to use for inter-pod traffic. Either kubenet or calico."
  default     = "kubenet"
}

variable subnetwork {
  description = "The subnetwork to deploy to"
  default     = "default"
}

variable region {
  description = "The region to create the cluster in."
  default     = "us-central1"
}

variable zone {
  description = "The zone to create the cluster in."
  default     = "us-central1-f"
}

variable access_config {
  description = "The access config block for the instances. Set to [] to remove external IP."
  type        = "list"
  default     = [{}]
}

variable master_machine_type {
  description = "The machine tyoe for the master node."
  default     = "n1-standard-4"
}

variable node_machine_type {
  description = "The machine type for the nodes."
  default     = "n1-standard-4"
}

variable num_nodes {
  description = "The number of nodes."
  default     = "3"
}

variable add_tags {
  description = "Additional list of tags to add to the nodes."
  type        = "list"
  default     = []
}

variable master_ip {
  description = "The internal IP of the master node. Note this must be in the CIDR range of the region and zone."
  default     = "10.128.0.10"
}

variable pod_cidr {
  description = "The CIDR for the pod network. The master will allocate a portion of this subnet for each node."
  default     = "10.40.0.0/14"
}

variable service_cidr {
  description = "The CIDR for the service network"
  default     = "10.25.240.0/20"
}

variable dns_ip {
  description = "The IP of the kube DNS service, must live within the service_cidr."
  default     = "10.25.240.10"
}

variable depends_id {
  description = "The ID of a resource that the instance group depends on."
  default     = ""
}
