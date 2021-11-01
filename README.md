# Enterprise Automation Stack - National Parks - Java Tomcat Application

[![CIS](https://app.soluble.cloud/api/v1/public/badges/b159c91d-706f-40f6-a343-a5ab57470e8a.svg)](https://app.soluble.cloud/repos/details/github.com/lhasadreams/national-parks-demo)  [![HIPAA](https://app.soluble.cloud/api/v1/public/badges/fb9223fc-f351-4714-99ad-2bda86fa723e.svg)](https://app.soluble.cloud/repos/details/github.com/lhasadreams/national-parks-demo)  [![IaC](https://app.soluble.cloud/api/v1/public/badges/4e5aec18-2ff8-4485-a225-343cc613054e.svg)](https://app.soluble.cloud/repos/details/github.com/lhasadreams/national-parks-demo)  
This is an example Java Tomcat application packaged by [Habitat](https://habitat.sh) on VMs hardened and patched by Chef Infra and Audited by Inspec using the "Effortless" pattern. This example app has existed for some time, and another example can be found [here](https://github.com/habitat-sh/national-parks). The differences with this example versus previous examples are the following:

- `core/mongodb` - Previous examples had you build a version of mongodb that was already populated with data before the application 
- `mongo.toml` - This repo includes a `user.toml` file for overriding the default configuration of mongodb
- `core/haproxy` = This repo uses the `core/haproxy` package as a loadbalancer in front of National Parks
- Scaling - In both the `terrform/azure` and `terraform/aws` plans there is a `count` variable which allows you to scale out the web instances to demonstrate the concept of choreography vs orchestration in Habitat.


## Usage
In order run this repo, you must first install Habitat. You can find setup docs on the [Habitat Website](https://www.habitat.sh/docs/install-habitat/).

## Demo Tracks
1. [Building national parks and running locally in the studio](docs/local_demo.md) (start here)
1. [Habitat via containers on Azure Kubernetes Service](docs/aks_demo.md)
1. [Habitat via containers on Google Kubernetes Engine](docs/gke_demo.md)
1. [Habitat + Terraform - Running natively on VMs](docs/terraform_demo.md)
1. [Continued local testing with Habitat + Docker Compose](docs/docker_compose_demo.md)
