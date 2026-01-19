# GitOps 初步完整流程（ArgoCD + GitLab + Harbor）

目标：通过 Git 仓库声明式管理 K8s 应用部署（GitOps 方式）

## 架构总览

![GitOps 整体架构图](https://github.com/user-attachments/assets/e248291c-d16c-4e0f-835e-8bf8dc2f281e)  
*图：典型 GitOps 闭环流程（ArgoCD 监听 GitLab → 拉取 manifests → 应用到 K8s）*

## 前置条件

- K8s 集群能访问 Internet、Harbor (10.0.0.41)、GitLab (10.0.0.200)
- 集群已部署 **Argo CD**
- 集群已部署 **gitlab-runner**（可选，用于 CI 构建镜像）
- 操作主机已安装 git，并能访问 GitLab 和 Harbor
- Harbor 已创建 robot 账号（示例：robot$apidemotest）

## 步骤一：K8s 集群内准备（手动执行一次）

1. 创建命名空间
   ```bash
   kubectl create namespace apidemo

2. 创建 Harbor 镜像拉取凭证（Secret）
   ```bash
   kubectl create secret docker-registry  harbor-secret \
   -n apidemo \
   --docker-server=10.0.0.41 \
   --docker-username='robot$apidemotest' \
   --docker-password='xxxxxxxxxxxx'
![Harbor机器人账户](https://github.com/user-attachments/assets/5ec91f7c-4da8-4ab1-8736-3f49ee1774b4)

3. 创建 Argo CD Application（声明式定义）创建文件 apidemo-app.yaml：
   ```yaml
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

4. 应用 Application
   ```bash
   kubectl apply -f apidemo-app.yaml


## 步骤二：Argo CD 添加私有 GitLab 仓库权限（只需执行一次）
 Argo CD 需要有权限拉取你的 GitLab 仓库。
```bash
   argocd repo add http://10.0.0.200/apidemo/apidemo.git \
     --username lawtest \
     --password glpat-u-xxxxxxxxxxxxxxxxxxxxxxxxxx
 ```
## 步骤三：GitLab 项目配置（CI/CD + Token）
![GitLab Access Token 创建页面](https://github.com/user-attachments/assets/b7c68c64-15f8-4bb8-bcf6-205ef4328188)
![GitLab Access Token 创建页面](https://github.com/user-attachments/assets/9913bea8-0cd6-4b44-9cea-16ae712adf49)
*图：创建 Project Access Token（建议命名为 GITLAB_PUSH_TOKEN）*
### 创建 Project Access Token
- 位置：项目 → Settings → Access Tokens
### 添加 CI/CD 变量
- 位置：项目 → Settings → CI/CD → Variables
- 常见其他变量（视 .gitlab-ci.yml 需要）：
   - HARBOR_USERNAME
   - HARBOR_PASSWORD
   - HARBOR_REGISTRY=10.0.0.41
   - IMAGE_NAME=apidemo


## 验证完整闭环

### 1.提交代码变更到 main 分支（包含 deploy/k8s/ 下的 yaml 更新）
### 2.Argo CD 自动检测 → 同步（约 3 分钟内）
### 3.检查
```bash
  argocd app get apidemo --refresh
  kubectl get pods,svc -n apidemo
  curl <svc 的 ClusterIP 或 Ingress 地址>
```
## 下一步打算
- 使用 ApplicationSet + 目录结构多环境管理
- 引入 Image Updater 自动更新镜像 tag
- 添加健康检查、回滚策略、通知（Wecom/Dingtalk）

