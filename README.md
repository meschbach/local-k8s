# Local Kubernetes
Toolbox of Local Kubernetes

## Provides
* ArgoCD
* Grafana with Loki, Promtail, and Tempo.
* Postgres 16

## Installing
Ensure your local k8s context is targeted then run `./local-k8s.sh install.sh`.

To view the current state of the installation run `./local-k8s.sh argocd` to be given the URL and authentication information.
Due to image pulling this may take a few minutes.

Once the services are running you may get the configurations for each by running `./local-k8s.sh services`

## Development
Fork and update your `root.yaml` to point to your repository.  Looking for a better method beyond writing a program
which will update them repository by editing the yaml.  Mabye using Gitea?

## Known working configurations
* Minikube

## k8s with challenges
* Rancher for Desktop on MacOS: Services are not exposed in a way which are accessible from the machine.
