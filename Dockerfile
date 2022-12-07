
# docker build --build-arg --no-cache -t "k8s-ctl" -f "./k8s-ctl" .
# docker tag petclinic-adm-cmd acrfootoo.azurecr.io/k8s-ctl
# az acr login --name acrfoototo.azurecr.io -u $acr_usr -p $acr_pwd

# docker push acrfoototo.azurecr.io/k8s-ctl
# docker pull acrfoototo.azurecr.io/k8s-ctl
# docker image ls
# docker run -p 80:80 k8s-ctl
# docker container ls
# docker ps
# docker exec -it b177880414c5 /bin/sh
# docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' <container>  
# docker images --filter reference=petclinic-admin-server --format "{{.Tag}}"

FROM nginx

LABEL Maintainer="pinpin <noname@microsoft.com>"
LABEL Description="Pod installed with Kubectl"

RUN sudo apt-get update
RUN sudo apt-get install -y kubectl
RUN kubectl api-versions
# /usr/local/bin/kubectl

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# https://helm.sh/docs/intro/install/
# https://git.io/get_helm.sh
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
# helm installed into /usr/local/bin/helm

RUN source <(kubectl completion bash) # setup autocomplete in bash into the current shell, bash-completion package should be installed first.
RUN echo "source <(kubectl completion bash)" >> ~/.bashrc 
RUN alias k=kubectl
RUN complete -F __start_kubectl k

RUN mkdir /tmp/app
WORKDIR /tmp/app

EXPOSE 80 8080
CMD ["bash"]
