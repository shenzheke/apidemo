初步的gitops完整流程


<img width="1621" height="806" alt="image" src="https://github.com/user-attachments/assets/e248291c-d16c-4e0f-835e-8bf8dc2f281e" />

架构如下：
K8S集群（能访问Internet，并与harbor和Gitlab通信。部署有Argocd和gitlab-runner）
Harbor 10.0.0.41
Gitlab 10.0.0.200 
操作主机有Git，并与以上能通信。

步骤：
K8S集群内的操作：
  kubectl create ns apidemo
  kubectl create secret docker-registry harbor-secret \
  -n apidemo \
  --docker-server=10.0.0.41 \
  --docker-username='robot$apidemotest' \
  --docker-password=xxxxxxx

  然后还要创建 Argo CD Application（apidemo-app.yaml）
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apidemo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://10.0.0.200/apidemo/apidemo.git
    targetRevision: main
    path: deploy/k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: apidemo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true

不要忘记：
  kubectl apply -f apidemo-app.yaml

一切就绪后可测试：
  argocd app get apidemo
  argocd app sync apidemo   # 第一次可手动
  kubectl get pods -n apidemo
  curl svcIP


  
argocd执行的操作：（username随意，password是自己建的Token，建好还要添加变量）
  argocd repo add http://10.0.0.200/apidemo/apidemo.git   --username lawtest   --password glpat-u-xxxxxxxtx5xWbzSD
Gitlab的操作：
  添加各种变量和Token
  创建 Token：在项目设置 Settings -> Access Tokens 中创建一个名为 GITLAB_PUSH_TOKEN 的 Token，勾选 write_repository 权限，角色选 Maintainer。
  设置变量：在 Settings -> CI/CD -> Variables 中添加该变量。

<img width="1875" height="883" alt="image" src="https://github.com/user-attachments/assets/b7c68c64-15f8-4bb8-bcf6-205ef4328188" />
<img width="1882" height="776" alt="image" src="https://github.com/user-attachments/assets/9913bea8-0cd6-4b44-9cea-16ae712adf49" />




<img width="1145" height="692" alt="image" src="https://github.com/user-attachments/assets/5ec91f7c-4da8-4ab1-8736-3f49ee1774b4" />

