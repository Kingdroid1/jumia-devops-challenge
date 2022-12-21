output "cluster_endpoint" {
  value = aws_eks_cluster.jumia.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.jumia.certificate_authority[0].data
}

output "cluster_vpc" {
  value = data.aws_vpc.selected.id
}