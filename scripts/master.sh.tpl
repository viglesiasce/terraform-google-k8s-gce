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

# Install L7 GLBC controller, path glbc.manifest to support kubeadm cluster.
curl -sL https://raw.githubusercontent.com/kubernetes/kubernetes/ff33e7014a50493ccb9ab780360b087d01b4fd62/cluster/saltbase/salt/l7-gcp/glbc.manifest | \
  sed \
    -e 's|--apiserver-host=http://localhost:8080|--apiserver-host=https://127.0.0.1:6443 --kubeconfig=/etc/kubernetes/admin.conf|g' \
    -e 's|--config-file-path=/etc/gce.conf|--config-file-path=/etc/kubernetes/gce.conf|g' \
    -e 's|: /etc/gce.conf|: /etc/kubernetes|g' \
    > /etc/kubernetes/manifests/glbc.manifest
chmod 0600 /etc/kubernetes/manifests/glbc.manifest

# Install default http-backend controller
curl -sL https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/cluster-loadbalancing/glbc/default-svc-controller.yaml | \
  kubectl --kubeconfig /etc/kubernetes/admin.conf create -n kube-system -f -

# Install default http-backend service
curl -sL https://raw.githubusercontent.com/kubernetes/kubernetes/master/cluster/addons/cluster-loadbalancing/glbc/default-svc.yaml | \
  kubectl --kubeconfig /etc/kubernetes/admin.conf create -n kube-system -f -

