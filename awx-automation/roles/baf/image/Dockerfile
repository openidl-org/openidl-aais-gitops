FROM hyperledgerlabs/baf-build

RUN apt-get install -y curl

RUN curl -LO https://dl.k8s.io/release/v1.22.0/bin/linux/amd64/kubectl \
    && mv kubectl /usr/local/bin/ \
    && chmod +x /usr/local/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh \
    && ./get_helm.sh
    
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install

WORKDIR /home
