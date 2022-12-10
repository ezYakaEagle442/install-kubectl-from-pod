# Installs kubectl in a Kubernetes Pod from k8s-ctl Image


## Docker Build

## Set Environment variables and Config files
```sh
# https://k8s-ctl.org/en/docs/faq/variables_in_config.html
# see at https://github.com/ezYakaEagle442/install-kubectl-from-pod/settings/actions/runners/new?arch=x64&os=linux

# your PAT must ahev permissions: Read access to metadata and secrets + Read and Write access to actions
export GHA_RUNNER_PAT=<PUT here the PAT from your repo>
export OWNER=ezYakaEagle442
export REPO=install-kubectl-from-pod
export NAME=dummy-runner
export APP_PORT=4242

envsubst < Dockerfile > deploy/Dockerfile
envsubst < k8s-ctl-deployment.yaml > deploy/k8s-ctl-deployment.yaml
envsubst < k8s-ctl-svc.yaml > deploy/k8s-ctl-svc.yaml
```

## Docker Build

Run manually the GHA Workflow from [https://github.com/ezYakaEagle442/install-kubectl-from-pod/actions/workflows/build-container-image.yaml](https://github.com/ezYakaEagle442/install-kubectl-from-pod/actions/workflows/build-container-image.yaml)

./config.sh --help

Commands:
 ./config.sh         Configures the runner
 ./config.sh remove  Unconfigures the runner
 ./run.sh            Runs the runner interactively. Does not require any options.

Options:
 --help     Prints the help for each command
 --version  Prints the runner version
 --commit   Prints the runner commit
 --check    Check the runner's network connectivity with GitHub server

Config Options:
 --unattended           Disable interactive prompts for missing arguments. Defaults will be used for missing options
 --url string           Repository to add the runner to. Required if unattended
 --token string         Registration token. Required if unattended
 --name string          Name of the runner to configure (default MININT-279OPT8)
 --runnergroup string   Name of the runner group to add this runner to (defaults to the default runner group)
 --labels string        Extra labels in addition to the default: 'self-hosted,Linux,X64'
 --work string          Relative runner work directory (default _work)
 --replace              Replace any existing runner with the same name (default false)
 --pat                  GitHub personal access token with repo scope. Used for checking network connectivity when executing `./run.sh --check`
 --disableupdate        Disable self-hosted runner automatic update to the latest released version`
 --ephemeral            Configure the runner to only take one job and then let the service un-configure the runner after the job finishes (default false)


[https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository](https://docs.github.com/en/actions/hosting-your-own-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository)
Running the config script to configure the self-hosted runner application and register it with GitHub Actions. 
The config script requires the destination URL and an automatically-generated time-limited token to authenticate the request.

[https://docs.github.com/rest/reference/actions#create-a-registration-token-for-a-repository](https://docs.github.com/rest/reference/actions#create-a-registration-token-for-a-repository)

[https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)


Go to [https://github.com/settings/tokens](https://github.com/settings/tokens) to generate your own PAT named: GHA_RUNNER_PAT
With repo, workflow scope authorizations

Test: 
BAD : curl -s X -H POST "Authorization: $GHA_RUNNER_PAT" https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token
{
  "message": "Must have admin rights to Repository.",
  "documentation_url": "https://docs.github.com/rest/reference/actions#get-a-self-hosted-runner-for-a-repository"
}
curl -s -X POST -H "Authorization: Bearer $GHA_RUNNER_PAT" https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token

Local test
```sh
docker run --env GHA_RUNNER_PAT=$GHA_RUNNER_PAT -e OWNER=$OWNER -e REPO=$REPO -e NAME=$NAME -it pinpindock/self-hosted-runnner:latest  --

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
kubectl create service clusterip k8s-ctl --tcp=${APP_PORT}:${APP_PORT} --dry-run=client -o yaml > k8s-ctl-svc.yaml
# https://kubernetes.io/docs/concepts/services-networking/service/#environment-variables
kubectl apply -f deploy/k8s-ctl-svc.yaml

kubectl apply -f deploy/k8s-ctl-deployment
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
az version
java --version
mvn --version
kubectl version
jq --version
helm version
git --version
whoami
uname -a
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

