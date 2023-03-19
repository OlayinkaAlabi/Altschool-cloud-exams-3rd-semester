resource "aws_route53_zone" "eks-hosted_zone" {
  name = var.domain.domain
}

data "kubernetes_service" "ingress-service" {
    metadata {
    name = "nginx-ingress-controller"
  }
  depends_on = [
    helm_release.nginx-ingress-controller
  ]
}

resource "aws_route53_record" "eks-record" {
  zone_id = aws_route53_zone.eks-hosted_zone.zone_id
  name    = var.domain.record
  type    = "CNAME"
  ttl     = "300"
  records = [data.kubernetes_service.ingress-service.status.0.load_balancer.0.ingress.0.hostname]
}

resource "namedotcom_domain_nameservers" "eaaladejana-live" {
  domain_name = "eaaladejana.live"
  nameservers = [
    "${aws_route53_zone.eks-hosted_zone.name_servers.0}",
    "${aws_route53_zone.eks-hosted_zone.name_servers.1}",
    "${aws_route53_zone.eks-hosted_zone.name_servers.2}",
    "${aws_route53_zone.eks-hosted_zone.name_servers.3}",
  ]
}
