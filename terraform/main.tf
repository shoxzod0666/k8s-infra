# Namespaces
resource "kubernetes_namespace" "microservices" {
  metadata {
    name = "microservices"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Ingress Nginx
resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name

  values = [file("${path.module}/../ingress-nginx/my-values.yaml")]

  depends_on = [kubernetes_namespace.ingress_nginx]
}

# Cert Manager
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name

  values = [file("${path.module}/../cert-manager/my-values.yaml")]

  depends_on = [kubernetes_namespace.cert_manager]
}

# Longhorn
resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name

  values = [file("${path.module}/../longhorn/my-values.yaml")]

  depends_on = [kubernetes_namespace.longhorn]
}

# Prometheus + Grafana
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [file("${path.module}/../monitoring/my-values.yaml")]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.longhorn
  ]
}

# Loki
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana-community.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [file("${path.module}/../loki/my-values.yaml")]

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.longhorn
  ]
}

# Promtail
resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [file("${path.module}/../promtail/my-values.yaml")]

  depends_on = [helm_release.loki]
}
