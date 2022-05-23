# Blockchain Automation Framework

For additional documentation, use [Blockchain Automation Framework](https://blockchain-automation-framework.readthedocs.io/en/latest/gettingstarted.html).


- [Short Description](#short-description)
- [Scope of Lab](#scope-of-lab)
  - [Getting Started](#getting-started)
  - [Hyperledger Fabric](#hyperledger-fabric)

## Short Description
An automation framework for rapidly and consistently deploying production-ready DLT platforms.

## Scope of Lab
Blockchain Automation Framework delivers an automation framework for rapidly and consistently deploying production-ready DLT platforms to cloud infrastructure.

![What is Blockchain Automation Framework?](./docs/images/blockchain-automation-framework-overview.png "What is Blockchain Automation Framework?")

Blockchain Automation Framework makes use of Ansible, Helm, and Kubernetes to deploy production DLT networks. Specifically, it makes use of Ansible for configuration of the network by DevOps Engineers. It then uses Helm charts as instructions for deploying the necessary components to Kubernetes. Kubernetes was chosen to allow for Blockchain Automation Framework to deploy the DLT networks to any cloud that supports Kubernetes.

Blockchain Automation Framework currently supports Corda, Hyperledger Fabric, Hyperledger Indy and Quorum. It is the intention to add support for Hyperledger Besu and Corda Enterprise in the near future. Other DLT platforms can easily be added.

### Getting Started

To get started with the framework quickly, follow our [Getting Started guidelines](https://blockchain-automation-framework.readthedocs.io/en/latest/gettingstarted.html).

Detailed operator and developer documentation is available on [our ReadTheDocs site](https://blockchain-automation-framework.readthedocs.io/en/latest/index.html).

The documentation can also be built locally be following instructions in the `docs` folder.

### Hyperledger Fabric
For Hyperledger Fabric, we use the official Docker containers provided by that project. A number of different Ansible scripts will allow you to either create a new network (across clouds) or join an existing network.

![Blockchain Automation Framework - Fabric](./docs/images/blockchain-automation-framework-fabric.png "Blockchain Automation Framework for Hyperledger Fabric")
