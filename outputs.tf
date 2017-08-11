output master_ip {
  description = "The internal address of the master"
  value       = "${var.master_ip}"
}

output depends_id {
  description = "Value that can be used for intra-module dependency creation."
  value       = "${module.master-mig.depends_id}"
}
