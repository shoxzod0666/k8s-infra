# Namespaces
resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

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

# External Secrets namespace
resource "kubernetes_namespace" "external_secrets" {
  metadata {
    name = "external-secrets"
  }
}

# Jenkins
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = kubernetes_namespace.jenkins.metadata[0].name

  values = [file("${path.module}/../jenkins/my-values.yaml")]

  wait             = true
  timeout          = 900
  atomic           = false
  cleanup_on_fail  = false

  depends_on = [
    kubernetes_namespace.jenkins,
    helm_release.longhorn
  ]
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

# Zabbix namespace
resource "kubernetes_namespace" "zabbix" {
  metadata {
    name = "zabbix"
  }
}

# Zabbix
resource "helm_release" "zabbix" {
  name       = "zabbix"
  repository = "https://zabbix-community.github.io/helm-zabbix"
  chart      = "zabbix"
  namespace  = kubernetes_namespace.zabbix.metadata[0].name

  values = [file("${path.module}/../zabbix/my-values.yaml")]

  depends_on = [
    kubernetes_namespace.zabbix,
    helm_release.longhorn
  ]
}
# Prometheus Alert Rules
resource "kubectl_manifest" "alert_rules" {
  yaml_body = file("${path.module}/../monitoring/alert-rules.yaml")

  depends_on = [helm_release.kube_prometheus_stack]
}

# Vault namespace
resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

# Vault
resource "helm_release" "vault" {
  name       = "vault"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  namespace  = kubernetes_namespace.vault.metadata[0].name

  values = [file("${path.module}/../vault/my-values.yaml")]

  depends_on = [
    kubernetes_namespace.vault,
    helm_release.longhorn
  ]
}

# External Secrets Operator
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = kubernetes_namespace.external_secrets.metadata[0].name

  values = [file("${path.module}/../external-secrets/my-values.yaml")]

  depends_on = [kubernetes_namespace.external_secrets]
}
