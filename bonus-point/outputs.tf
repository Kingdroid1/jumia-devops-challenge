output "cluster_endpoint" {
  value = aws_eks_cluster.meeney.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.meeney.certificate_authority[0].data
}

output "cluster_vpc" {
  value = data.aws_vpc.prod_vpc.id
}