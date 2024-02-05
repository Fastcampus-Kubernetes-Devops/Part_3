locals {
  service_account_name = {
    ebs_csi_controller : "ebs-csi-controller-sa"
    load_balancer_controller : "load-balancer-controller-sa"
  }
  service_account_namespace = "kube-system"
}
