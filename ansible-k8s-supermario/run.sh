#!/bin/bash

aws eks update-kubeconfig --name supermario-eks && \
ansible-playbook supermario_deploy_playbook.yaml