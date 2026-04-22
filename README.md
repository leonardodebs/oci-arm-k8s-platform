<div align="center">
  <h1>OCI ARM Kubernetes Platform</h1>
  <p>Plataforma Kubernetes de produção usando OKE com instâncias Ampere A1 ARM na Oracle Cloud Infrastructure.</p>

  [![OCI](https://img.shields.io/badge/OCI-Oracle%20Cloud-orange?style=for-the-badge&logo=oracle)](https://www.oracle.com/cloud/)
  [![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30+-326CE5?style=for-the-badge&logo=kubernetes)](https://kubernetes.io/)
  [![ARM](https://img.shields.io/badge/Architecture-ARM64-blue?style=for-the-badge&logo=arm)](https://amperecomputing.com/)
  [![Terraform](https://img.shields.io/badge/Terraform-1.5+-7B42BC?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
  [![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
</div>

<br />

## 🚀 Tecnologias Utilizadas

Este projeto utiliza o que há de mais moderno em infraestrutura como código e cloud native:

- **Cloud Provider:** [Oracle Cloud Infrastructure (OCI)](https://www.oracle.com/cloud/)
- **Orquestração:** [Oracle Kubernetes Engine (OKE)](https://www.oracle.com/cloud/cloud-native/kubernetes-engine/)
- **Infraestrutura como Código:** [Terraform](https://www.terraform.io/)
- **Arquitetura de Processador:** [ARM64 (Ampere A1 Flex)](https://www.oracle.com/cloud/compute/arm/)
- **CI/CD:** [GitHub Actions](https://github.com/features/actions)
- **Containerização:** [Docker](https://www.docker.com/) & [Oracle Cloud Infrastructure Registry (OCIR)](https://www.oracle.com/cloud/cloud-native/container-registry/)
- **Gerenciamento de Pacotes:** [Helm](https://helm.sh/)
- **Ingress Controller:** [NGINX Ingress](https://kubernetes.github.io/ingress-nginx/)


## Arquitetura

![Arquitetura do Sistema](docs/architecture.png)

```mermaid
graph TB
    subgraph OCI["Oracle Cloud Infrastructure"]
        subgraph VCN["Virtual Cloud Network"]
            subgraph Subnet["Subnet Pública"]
                IGW["Internet Gateway"]
                NGW["NAT Gateway"]
                LB["Load Balancer 10Mbps"]
                OKE["OKE Cluster 1.30+"]
            end
            subgraph NodePool["Node Pool"]
                NODE1["Node 1: 2 OCPU<br/>12GB RAM"]
                NODE2["Node 2: 2 OCPU<br/>12GB RAM"]
            end
        end
        subgraph OCIR["Container Registry"]
            IMG["nginx-demo:latest"]
        end
    end

    subgraph External["External"]
        GH["GitHub Actions<br/>CI/CD Pipeline"]
        USR["Usuários<br/>Final"]
    end

    GH -->|push image| OCIR
    GH -->|kubectl apply| LB
    USR -->|HTTP/HTTPS| LB
    LB -->|route| NODE1
    LB -->|route| NODE2
    NODE1 -->|pods| NGINX1["nginx-demo"]
    NODE2 -->|pods| NGINX2["nginx-demo"]
    OKE -->|manage| NODE1
    OKE -->|manage| NODE2
```

```mermaid
graph LR
    subgraph Internet["Internet"]
        USER["Usuário"]
    end
    
    subgraph OCI["OCI"]
        LB["Load Balancer"]
        NGINX["Ingress NGINX"]
        APP["nginx-demo"]
    end
    
    USER -->|HTTPS| LB
    LB -->|/healthz| NGINX
    NGINX -->|proxy| APP
```

## Por que OCI para Kubernetes?

| Critério | OCI OKE | AWS EKS |
|---------|---------|---------|
| **Custo mensal (2 nodes)** | ~$45 USD | ~$73 USD |
| **Always Free Tier** | Sim (ARM 4 cores) | Não |
| **Type instances** | Ampere A1 Flex | t4g.medium |
| **Região Brasil** | São Paulo | São Paulo |
| **Managed Control Plane** | Gratuito | $73/mês |
| **OCI Free Tier Credits** | $300 | $100 |

### Comparação de Custos Detalhada

| Recurso | OCI OKE | AWS EKS |
|---------|---------|---------|
| **Control Plane** | Gratuito | $73/mês |
| **Nodes (2x A1 Flex)** | $28/mês | $41/mês |
| **Load Balancer** | $10/mês (10Mbps) | $16/mês (classic) |
| **Egress Internet** | ~$5/mês | ~$8/mês |
| **Block Volume (100GB)** | $10/mês | $10/mês |
| **Total Estimado** | **~$53/mês** | **~$148/mês** |

> **Economia:** ~$95/mês usando OCI OKE vs AWS EKS para workloads equivalentes.

## Especificações Técnicas

### OKE Cluster
- **Versão Kubernetes:** 1.30+
- **CNI:** Flannel Overlay
- **Endpoint:** Público (acesso kubectl)
- **Região:** sa-saopaulo-1

### Node Pool
- **Shape:** VM.Standard.A1.Flex
- **Quantidade:** 2 nodes
- **OCPUs por node:** 2 (4 cores total)
- **Memória por node:** 12 GB (24 GB total)
- **Imagem:** Oracle Linux 8 (ARM)
- **Volume Boot:** 50 GB

### Recursos Kubernetes
- **Namespace:** production
- **Deployment:** nginx-demo (ARM-compatible)
- **HPA:** min 1, max 3 réplicas
- **PDB:** minAvailable 1
- **Service:** LoadBalancer (flexible 10Mbps)
- **Ingress:** NGINX Controller via Helm

## Pré-requisitos

| Ferramenta | Versão | Instalação |
|------------|-------|------------|
| Terraform | >= 1.5 | [Guia](https://developer.hashicorp.com/terraform/install) |
| OCI CLI | Latest | `brew install oci-cli` |
| kubectl | 1.30+ | `brew install kubectl` |
| Helm | 3.14+ | `brew install helm` |
| Docker | 24+ | [Guia](https://docs.docker.com/get-docker/) |

## Instalação Rápida

### 1. Configurar credenciais OCI

```bash
# Configurar OCI CLI
oci setup config

# Variáveis de ambiente
export OCI_REGION=sa-saopaulo-1
export TF_VAR_tenancy_ocid="ocid1.tenancy.oc1..xxxxxxx"
export TF_VAR_compartment_ocid="ocid1.compartment.oc1..xxxxxxx"
```

### 2. Aplicar Terraform

```bash
cd terraform/environments/dev

terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 3. Configurar kubectl

```bash
# Obter kubeconfig do cluster
oci ce cluster create-kubeconfig \
  --cluster-id ocid1.cluster.oc1.sa-saopaulo-1.xxxxxxxx \
  --file kubeconfig \
  --region sa-saopaulo-1

# Configurar kubectl
export KUBECONFIG=kubeconfig
kubectl get nodes
```

### 4. Instalar NGINX Ingress via Helm

```bash
# Adicionar repo Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Instalar com valores customizados
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  -f kubernetes/helm/ingress-nginx-values.yaml
```

### 5. Deploy da aplicação

```bash
kubectl apply -f kubernetes/namespaces/production.yaml
kubectl apply -f kubernetes/deployments/nginx-demo.yaml
kubectl apply -f kubernetes/ingress/
kubectl apply -f kubernetes/hpa/
```

## Estrutura do Projeto

```
oci-arm-k8s-platform/
├── terraform/
│   ├── modules/
│   │   ├── oke-cluster/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── node-pool/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── load-balancer/
│   │       ├── main.tf
│   │       └── variables.tf
│   └── environments/
│       └── dev/
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           └── terraform.tfvars
├── kubernetes/
│   ├── namespaces/
│   │   └── production.yaml
│   ├── deployments/
│   │   └── nginx-demo.yaml
│   ├── ingress/
│   │   ├── ingress-class.yaml
│   │   └── nginx-demo-ingress.yaml
│   ├── helm/
│   │   └── ingress-nginx-values.yaml
│   └── hpa/
│       └── ingress.yaml
├── app/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── index.html
│   └── health.html
├── .github/
│   └── workflows/
│       ├── ci-cd.yaml
│       └── terraform.yaml
├── docs/
│   ├── arquitetura.md
│   ├── runbook.md
│   └── variaveis-ambiente.md
└── README.md
```

## Verificar Workload ARM

```bash
# Verificar arquitetura dos nodes
kubectl get nodes -o wide

# Descrever node para verificar arquitetura
kubectl describe node | grep -i architecture
kubectl describe node | grep ProviderID

# Verificar pods em execução
kubectl get pods -n production -o wide

# Verificar se pods estão em nodes ARM
kubectl get pods -n production -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.nodeName}{"\t"}{.status.conditions[*].type}{"\n"}{end}'
```

### Saída esperada:

```
NAME                        NODE           STATUS
nginx-demo-7f9c4b8a5-x2h9p  oke-node-1    Running
nginx-demo-7f9c4b8a5-y4k8n  oke-node-2    Running
```

## GitHub Actions Secrets

| Secret | Descrição |
|--------|---------|
| `OCI_USERNAME` | Username OCI (formato: tenancy/nome) |
| `OCI_AUTH_TOKEN` | Token de autenticação OCIR |
| `OCI_API_KEY` | Chave API OCI |
| `OCI_TENANCY_OCID` | OCID do Tenancy |
| `OCI_COMPARTMENT_OCID` | OCID do Compartment |
| `OCI_CLUSTER_ID` | OCID do Cluster OKE |
| `OCI_NAMESPACE` | Namespace do OCIR |

## Pipeline CI/CD

### Fluxo

```mermaid
sequenceDiagram
    participant DEV as Desenvolvedor
    participant GH as GitHub Actions
    participant OCIR as Container Registry
    participant OKE as OKE Cluster
    
    DEV->>GH: git push
    GH->>GH: Build Docker ARM64
    GH->>OCIR: Push imagem
    OCIR-->>GH: Image tagged
    GH->>OKE: kubectl apply
    OKE-->>OKE: Rolling update
    GH->>OKE: Verificar deployment
    OKE-->>GH: Ready
```

## Recursos CRIados

### Terraform Modules
- [x] **oke-cluster** - Módulo OKE Cluster
- [x] **node-pool** - Módulo Node Pool ARM
- [x] **load-balancer** - Módulo Subnet e Route Table
- [x] VCN com CIDR 10.0.0.0/16
- [x] Subnet pública
- [x] Internet Gateway
- [x] NAT Gateway
- [x] Route Tables
- [x] Security Lists
- [x] OKE Cluster
- [x] Node Pool (2 nodes A1 Flex)

### Kubernetes
- [x] Namespace: production
- [x] ResourceQuota
- [x] LimitRange
- [x] Deployment: nginx-demo
- [x] Service: LoadBalancer
- [x] ConfigMap: nginx-config
- [x] HorizontalPodAutoscaler (app + ingress)
- [x] PodDisruptionBudget
- [x] IngressClass: nginx
- [x] Ingress: nginx-demo

## Troubleshooting

### Verificar logs do cluster

```bash
# Status do cluster
oci ce cluster get --cluster-id $CLUSTER_ID --query 'data.status'

# Logs do node pool
kubectl logs -n kube-system -l k8s-app=oci-node-init

# Verificar eventos
kubectl get events -n production --sort-by='.lastTimestamp'
```

### Problemas comuns

| Problema | Solução |
|----------|--------|
| Node não ready | Verificar CNI (`kubectl get pods -n kube-system`) |
| Image pull error | Verificar credenciais OCIR |
| HPA não escala | Verificar métricas server |
| LB sem IP | Aguardar 2-5 minutos |

## Licença

MIT - See [LICENSE](LICENSE) for details.

## Referências

- [Documentação OCI OKE](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm)
- [Terraform Provider OCI](https://registry.terraform.io/providers/oracle/oci/latest)
- [Ampere A1 Instances](https://docs.oracle.com/en-us/iaas/Content/Compute/References/amperecompute.htm)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Ingress NGINX Helm Chart](https://kubernetes.github.io/ingress-nginx/)

---

**Tópicos:** `oracle-cloud` `oci` `kubernetes` `oke` `arm` `ampere` `terraform` `devops` `always-free`