FROM ubuntu:20.04

# Stick to a working Ansible version
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository --yes --update ppa:ansible/ansible-2.10
RUN apt-get install -y ansible vim python-netaddr python3-pip python-yaml unzip curl sudo git
RUN pip install --upgrade --user openshift
RUN ansible-galaxy collection install community.kubernetes
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && bash /aws/install
RUN apt-get install -y apt-transport-https ca-certificates
RUN curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
RUN apt-get update && apt-get install -y kubectl



