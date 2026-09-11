# Policy do AWS Load Balancer Controller

Antes do primeiro `terraform apply`, baixe a policy oficial mantida pelo projeto
`aws-load-balancer-controller` e salve como `alb-controller-policy.json` nesta pasta:

```bash
curl -o alb-controller-policy.json \
  https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
```

Não reproduzimos o conteúdo aqui porque a AWS/o projeto atualiza essa policy com
alguma frequência (novas ações de ELBv2/EC2/ACM) — usar a versão desatualizada
commitada travaria funcionalidades do controller silenciosamente. O arquivo é lido
por `alb-controller.tf` via `file("./iam/alb-controller-policy.json")`.
