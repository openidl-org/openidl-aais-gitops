terraform {
  cloud {
    organization = "openIDL"

    workspaces {
      name = "testnet-openidl-k8s-resources"
    }
  }
}