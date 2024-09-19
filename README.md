# Local Kubernetes
Toolbox of Local Kubernetes

## Provides
* Grafana with Loki, Promtail, and Tempo.

## Installing
Ensure your local k8s context is targeted then run `./install.sh`.

## Development
Fork and update your `root.yaml` to point to your repository.  Looking for a better method beyond writing a program
which will update them repository by editing the yaml.  Mabye using Gitea?

## Known working configurations
* Minikube - forwards ports
* Rancher for Desktop on MacOS -- Does not forward ports.
