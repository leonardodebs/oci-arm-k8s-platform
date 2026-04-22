# Runbook Operacional e Troubleshooting

Este documento contém os procedimentos padrão para a operação, manutenção e resolução de problemas comuns do cluster Kubernetes na Oracle Cloud (OCI) rodando em instâncias ARM.

---

## 1. Operações Básicas

### 1.1. Conectar-se ao Cluster
Para operar o cluster, você precisa configurar seu `kubeconfig` local através do CLI da OCI.
```bash
# Gere o kubeconfig (o token de autenticação será renovado automaticamente via CLI)
oci ce cluster create-kubeconfig \
  --cluster-id <OCID_DO_CLUSTER> \
  --file ~/.kube/config \
  --region sa-saopaulo-1 \
  --token-version 2.0.0
```

### 1.2. Escalar os Nós (Node Pool)
Caso seja necessário sair do Tier Gratuito e aumentar a capacidade do cluster:
1. Acesse o diretório `terraform/environments/dev/`
2. Edite o arquivo `terraform.tfvars` ou passe a variável durante a execução:
```bash
# Exemplo alterando para 3 nós
terraform apply -var="node_pool_size=3"
```
3. O OKE criará o novo nó automaticamente e o registrará no cluster.

### 1.3. Atualizar a Versão do Kubernetes
A OCI gerencia o Control Plane, mas você deve iniciar a atualização. O processo recomendado é:
1. Atualize o Control Plane pelo Console da OCI para a nova versão desejada (Ex: `1.30.1` -> `1.31.0`).
2. Atualize o Node Pool no Terraform e aplique as mudanças. A OCI lidará com o ciclo de vida rotacionando as máquinas virtuais.

---

## 2. Troubleshooting (Resolução de Problemas)

### 2.1. Problema: Pods em estado `Pending` ou falhando em rodar
**Causa Comum:** Como estamos operando nós ARM (Ampere), tentar rodar uma imagem baseada em arquitetura `amd64`/`x86-64` (Intel) causará falha instantânea no contêiner ou o pod não subirá (Erro *Exec format error*).

**Solução:**
Verifique os logs e eventos do Pod:
```bash
kubectl describe pod -n production <NOME_DO_POD>
kubectl logs -n production <NOME_DO_POD>
```
*Garantia ARM:* Verifique se a imagem Docker no repositório foi construída especificamente para `linux/arm64`.

### 2.2. Problema: Load Balancer sem IP público ou "Pending"
**Causa:** A OCI pode demorar alguns minutos para alocar um IP público, ou os limites (Quotas) do tenant podem ter sido atingidos.
**Solução:**
1. Verifique o status do serviço do Ingress no K8s:
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```
2. Se o External-IP continuar `<pending>` por mais de 5 minutos, vá ao console da OCI > "Networking" > "Load Balancers" e verifique as requisições de trabalho (Work Requests).

### 2.3. Problema: "ImagePullBackOff" ou "ErrImagePull"
**Causa:** O cluster não tem permissão para baixar a imagem do OCIR (Container Registry privado) ou a tag não existe.
**Solução:**
1. Verifique se o secret do tipo `docker-registry` foi criado no namespace `production`.
2. O manifesto de deployment deve conter `imagePullSecrets:`.
3. Verifique se a senha (Auth Token OCI) expirou.

### 2.4. Verificar métricas e consumo dos Nós
Como temos recursos limitados (4 OCPUs totais no ambiente Free), é crucial monitorar o uso:
```bash
# Requer Metrics Server instalado no cluster
kubectl top nodes
kubectl top pods -n production
```

### 2.5. Consultar informações de Hardware dos Nós
Para validar a topologia ARM em operação:
```bash
# Pega o label arch
kubectl get nodes -L kubernetes.io/arch

# Exibe detalhes completos (deve mostrar Architecture: arm64)
kubectl describe node | grep -i architecture
```

---

## 3. Comandos Úteis Rápidos

* **Forçar restart da aplicação (Rolling Update)**:
  `kubectl rollout restart deployment/nginx-demo -n production`
* **Ver logs do Ingress NGINX para debugar erros HTTP (502, 404)**:
  `kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx`
* **Checar saúde dos recursos do Kubernetes no geral**:
  `kubectl get all -n production`
