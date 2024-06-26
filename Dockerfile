FROM registry.access.redhat.com/ubi9/ubi as builder

# Get target architecture
ARG TARGETARCH

RUN dnf install -y unzip golang-bin git

# eksctl cli
RUN PLATFORM="Linux_${TARGETARCH}" && \
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" && \
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check && \
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && \
    rm eksctl_$PLATFORM.tar.gz

# helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

# https://github.com/awslabs/amazon-ecr-credential-helper
RUN go install github.com/awslabs/amazon-ecr-credential-helper/ecr-login/cli/docker-credential-ecr-login@latest

# k9s tool - https://github.com/derailed/k9s
RUN curl -sS https://webinstall.dev/k9s | bash

RUN curl -sSfL https://raw.githubusercontent.com/crowdstrike/gofalcon/main/examples/install | sh -s


FROM registry.access.redhat.com/ubi9/ubi

COPY --from=builder /tmp/eksctl /usr/local/bin/helm /bin/
COPY --from=builder /root/go/bin/docker-credential-ecr-login /usr/bin/falcon_sensor_download /usr/bin/falcon_registry_token /usr/bin/falcon_get_cid /bin/
COPY --from=builder /root/.local/bin/k9s /bin/
COPY .docker /root/.docker
COPY demo-yamls /root/demo-yamls
COPY kubernetes.repo google-cloud-sdk.repo /etc/yum.repos.d/
COPY falcon-node-sensor-build falcon-node-sensor-push falcon-container-sensor-push falcon-image-pull-token /bin/

RUN : \
    && dnf update -y \
    && dnf install -y kubectl groff-base bash-completion google-cloud-sdk git \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-$(uname -m).zip" -o "awscliv2.zip" \
    && dnf install -y zip \
    && unzip awscliv2.zip \
    && dnf history undo last -y \
    && ./aws/install \
    && curl  https://download.docker.com/linux/centos/docker-ce.repo > /etc/yum.repos.d/docker-ce.repo \
    && rpm --import https://packages.microsoft.com/keys/microsoft.asc \
    && dnf install -y https://packages.microsoft.com/config/rhel/9.0/packages-microsoft-prod.rpm \
    && dnf install -y docker-ce docker-ce-cli containerd.io azure-cli \
    && dnf install -y skopeo --nobest --allowerasing jq \
    && dnf clean all \
    && rm -rf ./aws awscliv2.zip /var/cache/dnf

RUN echo $'\n\
  complete -C '/usr/local/bin/aws_completer' aws \n\
  ' >> /etc/bashrc \
  && kubectl completion bash >/etc/bash_completion.d/kubectl \
  && eksctl completion bash >/etc/bash_completion.d/eksctl \
  && helm completion bash >/etc/bash_completion.d/helm
