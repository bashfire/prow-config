# GKE cluster variables
PROJECT ?= spiffxp-gke-dev
ZONE ?= us-central1-f
CLUSTER ?= prow

# prow docker image variables
REPO ?= gcr.io/k8s-prow
TAG ?= v20200423-af610499d

CWD = $(shell pwd)

get-cluster-credentials:
	gcloud container clusters get-credentials $(CLUSTER) --project=$(PROJECT) --zone=$(ZONE)

.PHONY: get-cluster-credentials

update-config: get-cluster-credentials check-config
	kubectl create configmap config --from-file=config.yaml=$(CWD)/config/prow/config.yaml --dry-run -o yaml | kubectl replace configmap config -f -

update-plugins: get-cluster-credentials check-config
	kubectl create configmap plugins --from-file=plugins.yaml=$(CWD)/config/prow/plugins.yaml --dry-run -o yaml | kubectl replace configmap plugins -f -

.PHONY: update-config update-plugins

check-config:
	docker run -v $(CWD)/config/prow:/prow $(REPO)/checkconfig:$(TAG) \
		--config-path /prow/config.yaml \
		--plugin-config /prow/plugins.yaml \
		--strict

.PHONY: check-config
