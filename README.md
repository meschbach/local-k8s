# Local Kubernetes
Toolbox of Local Kubernetes

## Provides
* ArgoCD
* Grafana with Loki, Promtail, and Tempo.
* Postgres 16

## Installing
Ensure your local k8s context is targeted then run `./install.sh`.

To view the current state of the installation run `argo-config.sh` to be given the URL and authentication information.
Due to image pulling this may take a few minutes.

Once the services are running you may get the configurations for each by running `./exported-services.sh`

## Development
Fork and update your `root.yaml` to point to your repository.  Looking for a better method beyond writing a program
which will update them repository by editing the yaml.  Mabye using Gitea?

## Known working configurations
* Minikube - forwards ports
* Rancher for Desktop on MacOS -- Does not forward ports.
