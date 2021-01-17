# k8s-charts
helm charts for apps

Steps to Run:

1. git clone this repo (git clone https://github.com/vineetx/k8s-charts.git)
2. cd k8s-charts/MediaWiki
3. helm install mediawiki . --namespace <namespace name>

Important points:
Running this will be a little different in an existing environment and with a CI tool.


Have added pdb and hpa for scaling and for high availability.

HPA:
Pods will automatically scale when memory reaches more than 70%.


PDB:
At any given point of time (like draining a node) max unavailable pods will be 3, if a service is running with 10 pods and one or two nodes moved to draining state service will be running atleast 7 of the pods at anytime.
