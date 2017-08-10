#!/bin/bash

cat <<EOF > /etc/kubernetes/kubeadm.conf
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
kubernetesVersion: v${k8s_version}
cloudProvider: gce
token: ${token}
networking:
  serviceSubnet: ${service_cidr}
  podSubset: ${pod_cidr}
authorizationModes:
- RBAC
apiServerCertSANs:
- 127.0.0.1
controllerManagerExtraArgs:
  allocate-node-cidrs: "true"
  configure-cloud-routes: "true"
  cloud-config: /etc/kubernetes/gce.conf
  cluster-cidr: ${pod_cidr}
  cluster-name: ${instance_prefix}
  feature-gates: AllAlpha=true,RotateKubeletServerCertificate=false,RotateKubeletClientCertificate=false,ExperimentalCriticalPodAnnotation=true
EOF

cat <<'EOF' > /etc/kubernetes/gce.conf
[global]
node-tags = ${tags}
node-instance-prefix = ${instance_prefix}
EOF

kubeadm init --config /etc/kubernetes/kubeadm.conf

# kubeadm manages the manifests directory, so add configmap after the init returns.
kubectl --kubeconfig /etc/kubernetes/admin.conf create -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: ingress-uid
  namespace: kube-system
data:
  provider-uid: ${cluster_uid}
  uid: ${cluster_uid}
EOF