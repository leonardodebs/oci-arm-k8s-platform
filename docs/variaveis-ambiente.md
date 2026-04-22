# Exemplos de Variáveis de Ambiente

Este documento lista todas as variáveis de ambiente, configurações de segredos (Secrets) e variáveis necessárias para executar a infraestrutura via Terraform e os Pipelines de CI/CD.

Estes arquivos **nunca** devem ser commitados no repositório de código (certifique-se que o arquivo `.env` ou `.tfvars` final esteja listado no `.gitignore`).

---

## 1. Configuração Terraform (`terraform.tfvars` ou `.env` local)

Crie um arquivo chamado `terraform.tfvars` dentro do diretório `terraform/environments/dev/` com o seguinte formato:

```hcl
# OCIDs Base (Oracle Cloud IDs)
tenancy_ocid     = "ocid1.tenancy.oc1..aaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxx"
compartment_ocid = "ocid1.compartment.oc1..aaaaaaaaxxxxxxxxxxxxxxxxxxxxxxxxxx"
region           = "sa-saopaulo-1" # Região selecionada para implantação

# Configurações do Node Pool
node_pool_size      = 2
node_shape          = "VM.Standard.A1.Flex"
node_ocpus          = 2
node_memory_in_gbs  = 12

# Configurações de Rede (Opcional, assumindo defaults)
# vcn_cidr_block = "10.0.0.0/16"
```

---

## 2. Configurações para acesso local via OCI CLI

Para operar a OCI a partir da sua máquina local, você deve ter a CLI configurada (`~/.oci/config`). As variáveis abaixo podem ser exportadas em seu shell (bash/zsh) para simplificar scripts:

```bash
# ~/.bash_profile ou ~/.zshrc

export OCI_CLI_USER="ocid1.user.oc1..xxxx"
export OCI_CLI_FINGERPRINT="1a:2b:3c:4d:5e:6f:7g:8h:9i:0j:1k:2l:3m:4n:5o:6p"
export OCI_CLI_TENANCY="ocid1.tenancy.oc1..xxxx"
export OCI_CLI_REGION="sa-saopaulo-1"
export OCI_CLI_KEY_FILE="~/.oci/oci_api_key.pem"
```

---

## 3. Segredos do GitHub Actions (CI/CD)

Para o perfeito funcionamento do Github Actions configurado neste projeto (arquivos `ci-cd.yaml` e `terraform.yaml`), você deve navegar no seu repositório em: 
**Settings** > **Secrets and variables** > **Actions** > **New repository secret**

Crie os seguintes secrets:

| Nome do Secret | Descrição | Exemplo de Valor |
|----------------|-----------|------------------|
| `OCI_USERNAME` | Seu usuário da OCI para autenticação no Registry. Deve seguir o formato `namespace/usuario`. | `ax5xxxyz/meu.usuario@email.com` |
| `OCI_AUTH_TOKEN` | Token de Autenticação gerado no console da OCI para empurrar imagens Docker. | `*Yh!x9b#L7m[zWq1` |
| `OCI_API_KEY` | O conteúdo do seu arquivo de chave privada PEM para acesso às APIs da OCI. | `-----BEGIN RSA PRIVATE KEY-----...` |
| `OCI_TENANCY_OCID` | OCID principal da sua conta. | `ocid1.tenancy.oc1..xxxx` |
| `OCI_COMPARTMENT_OCID`| OCID do compartimento onde a infraestrutura será criada. | `ocid1.compartment.oc1..xxxx` |
| `OCI_CLUSTER_ID` | OCID do Cluster OKE (obtido após executar o Terraform) para o pipeline fazer o deploy. | `ocid1.cluster.oc1.sa-saopaulo-1.xxxx` |
| `OCI_NAMESPACE` | O "Object Storage Namespace" atribuído ao seu tenant na OCI (necessário para o OCIR). | `ax5xxxyz` |

---

## 4. Kubernetes Secrets de Exemplo (Opcional)

Se a sua aplicação precisar de chaves para acessar banco de dados ou APIs, a melhor prática é declará-las da seguinte forma via `.yaml` no Kubernetes (convertidas para base64), em um arquivo separado:

```yaml
# app-secrets.yaml (não commitar)
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
  namespace: production
type: Opaque
data:
  DB_PASSWORD: c2VuaGExMjMK # 'senha123' em base64
  API_KEY: Zm9vYmFyYmF6Cg==
```
