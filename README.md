# install-kubectl-from-pod
Installs kubectl in a Kubernetes Pod

kubectl create deployment k8s-ctl --image=nginx --replicas=1 --port=80 --dry-run=client -o yaml > k8s-ctl.yaml
kubectl apply -f  k8s-ctl.yaml
kubectl get deploy,po

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

