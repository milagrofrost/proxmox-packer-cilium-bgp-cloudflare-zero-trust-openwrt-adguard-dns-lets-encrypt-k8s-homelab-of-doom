# ArgoCD 

- ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes.  That's a word salad, amirite?  
- I've not used this before but I've heard good things about it.  I'm going to give it a try and see if it's worth the hype.
- I'll use this to deploy any new applications that I want to run on my cluster.  I'll also use this to deploy any updates to existing applications.

## Installation

- RTFM - https://argo-cd.readthedocs.io/en/stable/getting_started/
- Steps are pretty well documented on the ArgoCD website. Follow those.
- Since I'm on a Windows machine, I used choco to install the argocd-cli with `choco install argocd-cli`
- I made the the API server accessible from outside the cluster by running `kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'`

## What now?

I just installed this honestly and I'm not quite sure if I'll use it, but it's here if I need it.  I'll update this with more information as/if I use it more.


