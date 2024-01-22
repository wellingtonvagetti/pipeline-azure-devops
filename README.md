# Exercício 1
## 1. Criar uma conta gratuita no Azure (oferece uso de R$ 750 em créditos

- 2. Criar um cluster de Kubernetes Gerenciado

- 2.1 Conectar no cluster via cloudshell Azure

- 3. Implementar a stack abaixo no cluster
https://github.com/microservices-demo/microservices-demo/blob/master/internal-docs/design.md
https://github.com/microservices-demo/microservices-demo/blob/master/deploy/kubernetes/complete-demo.yaml

Após a implementação, você deve alterar o serviço (service de frontend, conforme descrição para tipo load balancer, e expor o mesmo para internet.)

apiVersion: v1
kind: Service
metadata:
  name: front-end

* O entregavel final é ter a aplicação funcionando e exposta para internet.

* Dica. Para buscar o service - kubectl get service -n sock-shop

# Exercício 2
- 1.Criar a mesma estrutura da etapa 1, usando terraform
Importante que seja implementando o nat gateway para centralizar saida de trafego

- 2.Construir uma pipeline para deployment dos códigos terraform com Azure DevOps
  - Objetivo é que a cada mudança feita no repositório git do azure devops, seja feito um deploy dessa mudança no Azure.
