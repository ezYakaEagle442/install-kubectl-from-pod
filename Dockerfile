
# docker build --build-arg --no-cache -t "k8s-ctl" -f Dockerfile .
# docker login -u "myusername" -p "mypassword" docker.io
# docker tag k8s-ctl pinpindock/k8s-ctl
# docker push pinpindock/k8s-ctl

# docker tag k8s-ctl acrfootoo.azurecr.io/k8s-ctl
# az acr login --name acrfoototo.azurecr.io -u $acr_usr -p $acr_pwd
# docker push acrfoototo.azurecr.io/k8s-ctl
# docker pull acrfoototo.azurecr.io/k8s-ctl

# docker image ls
# docker run -it -p 4242:4242 k8s-ctl
# docker container ls
# docker ps
# docker exec -it b177880414c5 /bin/sh
# docker inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' <container>
# docker inspect k8s-ctl  '{{ ..[0].Config.ExposedPorts }}'
# docker images --filter reference=k8s-ctl --format "{{.Tag}}"

# https://mcr.microsoft.com/en-us/product/azure-cli/about
# FROM mcr.microsoft.com/azure-cli:latest 

FROM ubuntu:20.04 as builder

LABEL Maintainer="pinpin <noname@microsoft.com>"
LABEL Description="Pod installed with Kubectl - see Dockerfile at https://github.com/ezYakaEagle442/install-kubectl-from-pod/blob/main/Dockerfile"

# https://github.com/actions/runner-images/blob/main/images/linux/Ubuntu2004-Readme.md
# https://github.com/actions/runner/tags/
ENV RUNNER_VERSION=2.299.1

RUN useradd -m actions
RUN apt-get -yqq update && apt-get install -yqq curl jq wget

RUN \
  LABEL="$(curl -s -X GET 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')" \
  RUNNER_VERSION="$(echo ${latest_version_label:1})" \
  cd /home/actions && mkdir actions-runner && cd actions-runner \
    && wget https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
    && tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

WORKDIR /home/actions/actions-runner
RUN chown -R actions ~actions && /home/actions/actions-runner/bin/installdependencies.sh

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
USER actions

# EXPOSE ${APP_PORT}
# CMD ["bash"]
ENTRYPOINT ["./entrypoint.sh"]