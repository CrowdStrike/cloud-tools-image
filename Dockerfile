FROM registry.centos.org/centos/centos:8 as builder

RUN dnf install -y unzip golang-bin git

# eksctl cli
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp

# helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# https://github.com/awslabs/amazon-ecr-credential-helper
RUN go get -u github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login

RUN go get -u github.com/crowdstrike/gofalcon/examples/falcon_sensor_download


FROM registry.centos.org/centos/centos:8

COPY --from=builder /tmp/eksctl /usr/local/bin/helm /bin/
COPY --from=builder /root/go/bin/docker-credential-ecr-login /root/go/bin/falcon_sensor_download /bin/

COPY .docker /root/.docker
COPY demo-yamls /root/demo-yamls
COPY kubernetes.repo google-cloud-sdk.repo azure-cli.repo /etc/yum.repos.d/
COPY falcon-node-sensor-build /bin

RUN : \
    && dnf install -y kubectl groff-base bash-completion google-cloud-sdk tmux git \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && dnf install -y zip \
    && unzip awscliv2.zip \
    && dnf history undo last -y \
    && ./aws/install \
    && rm -rf ./aws \
    && rm awscliv2.zip \
    && curl  https://download.docker.com/linux/centos/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo \
    && dnf install -y docker-ce docker-ce-cli containerd.io \
    && rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && dnf install azure-cli -y \
    && dnf clean all \
    && rm -rf /var/cache/dnf

       
RUN echo $'\n\
complete -C '/usr/local/bin/aws_completer' aws \n\
' >> /etc/bashrc \
  && kubectl completion bash >/etc/bash_completion.d/kubectl \
  && eksctl completion bash >/etc/bash_completion.d/eksctl \
  && helm completion bash >/etc/bash_completion.d/helm
     
