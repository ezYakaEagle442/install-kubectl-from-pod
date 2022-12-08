
# docker build --build-arg --no-cache -t "k8s-ctl" -f Dockerfile .
# docker login -u "myusername" -p "mypassword" docker.io
# docker tag k8s-ctl pinpindock/k8s-ctl
# docker push pinpindock/k8s-ctl

# docker tag k8s-ctl acrfootoo.azurecr.io/k8s-ctl
# az acr login --name acrfoototo.azurecr.io -u  -p 
# docker push acrfoototo.azurecr.io/k8s-ctl
# docker pull acrfoototo.azurecr.io/k8s-ctl

# docker image ls
# docker run -it -p 1025:1025 k8s-ctl
# docker container ls
# docker ps
# docker exec -it b177880414c5 /bin/sh
# docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' <container>
# docker inspect k8s-ctl  '{{ ..[0].Config.ExposedPorts }}'
# docker images --filter reference=petclinic-admin-server --format "{{.Tag}}"

# https://hub.docker.com/_/nginx/
FROM nginx

LABEL Maintainer="pinpin <noname@microsoft.com>"
LABEL Description="Pod installed with Kubectl - see Dockerfile at https://github.com/ezYakaEagle442/install-kubectl-from-pod/blob/main/Dockerfile"

RUN mkdir /tmp/app

#http://nginx.org/en/docs/beginners_guide.html
# By default, the configuration file is named nginx.conf and placed in the directory 
# /usr/local/nginx/conf, /etc/nginx, or /usr/local/etc/nginx.

# /§\ DEFAULT_CONF_FILE="/etc/nginx/conf.d/default.conf"
COPY index2.html /usr/share/nginx/html
COPY dashboard.html /usr/share/nginx/html
COPY demo-index.html /usr/share/nginx/html
COPY deploy/nginx.conf /etc/nginx/
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf
#COPY /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.back
#COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir /tmp/nginx
RUN touch /tmp/nginx/nginx.pid

# https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
#RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#RUN curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
#RUN echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

COPY "kubectl" "/usr/local/bin/kubectl"
RUN chmod +x "/usr/local/bin/kubectl"
RUN kubectl version --client
# /usr/local/bin/kubectl

# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# https://helm.sh/docs/intro/install/
# https://git.io/get_helm.sh
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN helm version
# helm installed into /usr/local/bin/helm

# https://stackoverflow.com/questions/40358923/docker-nginx-disable-default-exposed-port-80
# https://github.com/nginxinc/docker-nginx/blob/master/stable/debian/Dockerfile
EXPOSE 1025
CMD ["nginx", "-g", "daemon off;"]