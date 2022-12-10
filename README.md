# Installs kubectl in a Kubernetes Pod from k8s-ctl Image


## Docker Build

## Set Environment variables and Config files
```sh
# https://k8s-ctl.org/en/docs/faq/variables_in_config.html
export APP_PORT=4242
envsubst < Dockerfile > deploy/Dockerfile
envsubst < k8s-ctl_deployment.yaml > deploy/k8s-ctl_deployment.yaml
envsubst < k8s-ctl_svc.yaml > deploy/k8s-ctl_svc.yaml
```

## Docker Build
```sh

docker build --build-arg --no-cache -t "k8s-ctl" -f deploy/Dockerfile .
docker image ls
docker run -it -p ${APP_PORT}:${APP_PORT} --env APP_PORT=${APP_PORT} k8s-ctl
docker inspect k8s-ctl '{{ ..[0].Config.ExposedPorts }}'
docker container ls
```

## Test from inside the container or from your browser
```sh
az version
java --version
mvn --version
kubectl version
jq --version
helm version
git --version
```



## Deploy to K8S

```sh

source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
echo "source <(kubectl completion bash)" >> ~/.bashrc 
alias k=kubectl
complete -F __start_kubectl k

alias kn='kubectl config set-context --current --namespace '

export gen="--dry-run=client -o yaml" 
# ex: k run k8s-ctl --image k8s-ctl $gen

# Get K8S resources
alias kp="kubectl get pods -o wide"
alias kd="kubectl get deployment -o wide"
alias ks="kubectl get svc -o wide"
alias kno="kubectl get nodes -o wide"

# Describe K8S resources 
alias kdp="kubectl describe pod"
alias kdd="kubectl describe deployment"
alias kds="kubectl describe service"

vi ~/.vimrc
set ts=2 sw=2
. ~/.vimrc
```

https://kubernetes.io/docs/tasks/inject-data-application/define-interdependent-environment-variables/

```sh
kubectl create service clusterip k8s-ctl --tcp=${APP_PORT}:${APP_PORT} --dry-run=client -o yaml > k8s-ctl_svc.yaml
# https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables
kubectl apply -f deploy/k8s-ctl_svc.yaml

#kubectl create deployment k8s-ctl --image=k8s-ctl --replicas=1 --port=80 --dry-run=client -o yaml > k8s-ctl_deployment
#kubectl create configmap cm-cfg --from-literal=k8s-ctl.port=${APP_PORT}
#kubectl describe cm cm-cfg
kubectl apply -f deploy/k8s-ctl_deployment
kubectl get po,deploy
kubectl describe deploy k8s-ctl

# https://www.jsonquerytool.com/
podname=$(kubectl get po -l app=k8s-ctl -o=jsonpath={.items..metadata.name})
podip=$(kubectl get po -l app=k8s-ctl -o=jsonpath={.items[0].status.podIP})
podport=$(kubectl get po -l app=k8s-ctl -o=jsonpath={.items[0].spec.containers[0].ports[0].containerPort})

echo "podname=$podname"
echo "podip=$podip"
echo "podport=$podport"

kubectl describe po $podname
kubectl exec -it $podname -- sh
```

Test from inside the container :
```sh
x
x
x
```


See [https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/#without-using-a-proxy](https://kubernetes.io/docs/tasks/run-application/access-api-from-pod/#without-using-a-proxy)
```sh
whoami
ls -al /root/.kube

ls -al /var/run
ls -al /run/secrets/kubernetes.io/serviceaccount
ls -al /run/secrets/kubernetes.io/serviceaccount/..data
cat /run/secrets/kubernetes.io/serviceaccount/token

APISERVER=https://kubernetes.default.svc
SERVICEACCOUNT=/var/run/secrets/kubernetes.io/serviceaccount
NAMESPACE=$(cat ${SERVICEACCOUNT}/namespace)
CACERT=${SERVICEACCOUNT}/ca.crt
TOKEN=$(cat ${SERVICEACCOUNT}/token)

kubectl create token toktok 

curl -k  https://kubernetes.default/api/v1/namespaces/toto/pods -H 'Accept: application/json' -H "Authorization: Bearer $TOKEN"
curl -k  https://10.0.0.1/api/v1/namespaces/k8se-apps/pods -H 'Accept: application/json' -H "Authorization: Bearer $TOKEN"

```

