# install-kubectl-from-pod
Installs kubectl in a Kubernetes Pod


## Docker Build

```sh
export NGINX_PORT=1025
# https://nginx.org/en/docs/faq/variables_in_config.html
export NGINX_PORT=${NGINX_PORT}
envsubst < nginx.conf > deploy/nginx.conf
envsubst < k8s-ctl.yaml > deploy/k8s-ctl.yaml
envsubst < nginx_svc.yaml > deploy/nginx_svc.yaml

docker build --build-arg --no-cache -t "k8s-ctl" -f Dockerfile .
docker login -u "myusername" -p "mypassword" docker.io
docker tag k8s-ctl "myusername"/k8s-ctl
docker push "myusername"/k8s-ctl

#docker tag k8s-ctl acrfootoo.azurecr.io/k8s-ctl
#az acr login --name acrfoototo.azurecr.io -u $acr_usr -p $acr_pwd
#docker push acrfoototo.azurecr.io/k8s-ctl
#docker pull acrfoototo.azurecr.io/k8s-ctl

docker image ls
docker run -it -p 1025:1025 --env NGINX_PORT=1025 k8s-ctl
docker container ls
```

Test from inside the container or from your browser
```sh
curl -X GET http://localhost:1025/index.html
curl -X GET http://host.docker.internal:1025/index.html
curl -X GET http://127.0.0.1:1025/index.html

curl -X GET http://10.2.0.96:1025

curl -X GET http://host.docker.internal:1025/index2.html
curl -X GET http://host.docker.internal:1025/demo-index.html
```

## Deploy to K8S

https://kubernetes.io/docs/tasks/inject-data-application/define-interdependent-environment-variables/

```sh
kubectl create service clusterip nginx --tcp=${NGINX_PORT}:${NGINX_PORT} --dry-run=client -o yaml > nginx_svc.yaml
# https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables
kubectl apply -f deploy/nginx_svc.yaml

# kubectl create deployment k8s-ctl --image=nginx --replicas=1 --port=80 --dry-run=client -o yaml > k8s-ctl.yaml
kubectl create configmap cm-cfg --from-literal=nginx.port=${NGINX_PORT}
kubectl describe cm cm-cfg
kubectl apply -f deploy/k8s-ctl.yaml
kubectl get deploy,po

# https://www.jsonquerytool.com/
podname=$(kubectl get po -l app=k8s-ctl -o=jsonpath={.items..metadata.name})
kubectl describe po $podname
podip=$(kubectl get po -l app=k8s-ctl -o=jsonpath={.items[0].status.podIP})
podport=$(kubectl get po -l app=k8s-ctl -o=jsonpath={.items[0].spec.containers[0].ports[0].containerPort})

echo "podname=$podname"
echo "podip=$podip"
echo "podport=$podport"

kubectl exec -it $podname -- sh
```

Test from inside the container :
```sh

nginx -t
#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful

curl -X GET http://localhost:1025/index.html
curl -X GET http://host.docker.internal:1025/index.html
curl -X GET http://127.0.0.1:1025/index.html

curl -X GET http://10.2.0.96:1025

curl -X GET http://host.docker.internal:1025/index2.html
curl -X GET http://host.docker.internal:1025/demo-index.html
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


```sh
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: k8s-ctl
  name: k8s-ctl
spec:
  replicas: 1
  selector:
    matchLabels:
      app: k8s-ctl
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: k8s-ctl
    spec:
      volumes:
      - name: kubectl
        emptyDir: {}
      initContainers:
      - name: k8s-ctl
        image: pinpindock/k8s-ctl
        volumeMounts:
        - name: kubectl
          mountPath: /data
        command: ["cp", "/usr/local/bin/kubectl", "/data/kubectl"]    
      containers:
      - image: nginx
        name: nginx
        volumeMounts:
        - name: kubectl
          subPath: kubectl
          mountPath: /usr/local/bin/kubectl        
        ports:
        - containerPort: 80
        resources: {}
```


https://learn.microsoft.com/en-us/azure/spring-apps/how-to-deploy-with-custom-container-image?tabs=azure-cli#prerequisites

/!\ IMPORTANT:  The web application must listen on port 1025 for Standard tier and on port 8080 for Enterprise tier. The way to change the port depends on the framework of the application. For example, specify SERVER_PORT=1025 for Spring Boot applications or ASPNETCORE_URLS=http://+:1025/ for ASP.Net Core applications.


```sh
az spring app deploy \
   --resource-group rg-iac-asa-petclinic-mic-srv \
   --name k8s-ctl \
   --container-image pinpindock/k8s-ctl \
   --service asa-petcliasa \
   --disable-probe true \
   --language-framework "" \
   --disable-validation true \
   --container-command /bin/sh \
   --debug

az spring app logs --name k8s-ctl -s asa-petcliasa -g rg-iac-asa-petclinic-mic-srv

```
   
