# data "aws_eks_node_group" "eks-node-group" {
#   cluster_name = "tg-tekton-eks-cluster"
#   #node_group_name = "tg-tekton-cluster-node-group"
# }

resource "time_sleep" "wait_for_kubernetes" {

    depends_on = [
        data.aws_eks_cluster.tg-tekton-eks-cluster
    ]

    create_duration = "20s"
}

resource "null_resource" "example" {
  provisioner "local-exec" {
   command    = "cat ~/.kube/config"
  }
}
# resource "kubernetes_namespace" "kube-namespace" {
#   #depends_on = [data.aws_eks_node_group.eks-node-group, time_sleep.wait_for_kubernetes]
#   metadata {
    
#     name = "prometheus"
#   }
# }

resource "helm_release" "prometheus" {
  #depends_on = [kubernetes_namespace.kube-namespace, time_sleep.wait_for_kubernetes]
  name       = "module.prometheus.release_name"  
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  #namespace  = kubernetes_namespace.kube-namespace.id
  namespace  = "prometheus"
  create_namespace = false
  version    = "45.7.1"
  recreate_pods   = true  # Recreate pods during upgrade
  reset_values    = true  # Reset any existing values
  force_update    = true  # Force update the release
  values = [
    file("values.yaml")
  ]
  timeout = 2000
  

set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  # You can provide a map of value using yamlencode. Don't forget to escape the last element after point in the name
  set {
    name = "server\\.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}
  
