variable "region" {
  default = "us-east-1"
}

variable "map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      userarn  = "arn:aws:iam::66666666666:user/user1"
      username = "user1"
      groups   = ["system:masters"]
    },
  ]
}

variable "ansible_image" {
  default     = "ansible:latest"
  description = "Ansible image for container."
}

variable "author" {
  default     = "basoyan"
  description = "Author."
}

variable "ansible_dockerfile_path" {
  default     = "./ansible_dockerfile"
  description = "Ansible dockerfile path."
}

variable "ansible_container" {
  default     = "ansible"
  description = "Ansible container name."
}