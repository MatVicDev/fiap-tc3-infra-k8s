# Datadog Agent como DaemonSet: coleta métricas de CPU/memória dos nós e pods,
# logs de todos os containers e recebe os traces do dd-java-agent embarcado na
# imagem da aplicação principal (ver Dockerfile de fiap-TC1-oficina).
#
# count em vez de recurso incondicional: datadog_api_key vazia (ainda sem
# conta Datadog) desativa o Agent sem quebrar o apply do resto do cluster.
resource "kubernetes_secret" "datadog_api_key" {
  count = var.datadog_api_key != "" ? 1 : 0

  metadata {
    name      = "datadog-secret"
    namespace = "default"
  }

  data = {
    api-key = var.datadog_api_key
  }
}

resource "helm_release" "datadog" {
  count      = var.datadog_api_key != "" ? 1 : 0
  name       = "datadog"
  repository = "https://helm.datadoghq.com"
  chart      = "datadog"
  namespace  = "default"

  set {
    name  = "datadog.apiKeyExistingSecret"
    value = kubernetes_secret.datadog_api_key[0].metadata[0].name
  }

  set {
    name  = "datadog.site"
    value = "datadoghq.com"
  }

  set {
    name  = "datadog.logs.enabled"
    value = "true"
  }

  set {
    name  = "datadog.logs.containerCollectAll"
    value = "true"
  }

  set {
    name  = "datadog.apm.portEnabled"
    value = "true"
  }

  set {
    name  = "datadog.processAgent.enabled"
    value = "true"
  }

  set {
    name  = "clusterAgent.enabled"
    value = "true"
  }

  set {
    name  = "clusterAgent.metricsProvider.enabled"
    value = "true"
  }

  depends_on = [aws_eks_node_group.oficina]
}
