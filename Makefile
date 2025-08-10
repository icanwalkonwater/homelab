.PHONY: help
help:
	@echo "Available commands:"
	@echo "  - make up"
	@echo "  - make down"

.PHONY: up
up:
	kubectl apply -k charts
	kubectl apply -k cert-manager-issuers
	kubectl apply -k auth
	kubectl apply -k monitoring
	kubectl apply -k mealie

.PHONY: down
down:
	kubectl delete -k mealie
	kubectl delete -k monitoring
	kubectl delete -k auth
	kubectl delete -k cert-manager-issuers
	kubectl delete -k charts
