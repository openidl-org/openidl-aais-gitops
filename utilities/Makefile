export AAIS_ORG=aais
export AAIS_ORG_SHORT=aais
export AWS_AAIS_ROLE=aais-role
export ANALYTICS_ORG=analtyics
export ANALYTICS_ORG_SHORT=anal
export AWS_ANALYTICS_ROLE=anal-role

kubectl_aais_config_aais_app_cluster:
	aws --profile $(AWS_AAIS_ROLE) eks update-kubeconfig --region us-east-1 --name ${AAIS_ORG_SHORT}-dev-app-cluster

kubectl_aais_config_aais_blk_cluster:
	aws --profile $(AWS_AAIS_ROLE) eks update-kubeconfig --region us-east-1 --name ${AAIS_ORG_SHORT}-dev-blk-cluster

kubectl_analytics_config_analytics_app_cluster:
	aws --profile $(AWS_ANALYTICS_ROLE) eks update-kubeconfig --region us-east-1 --name ${ANALYTICS_ORG_SHORT}-dev-app-cluster

kubectl_analytics_config_analytics_blk_cluster:
	aws --profile $(AWS_ANALYTICS_ROLE) eks update-kubeconfig --region us-east-1 --name ${ANALYTICS_ORG_SHORT}-dev-blk-cluster

kubectl_carrier_config_carrier_app_cluster:
	@echo AWS_CARRIER_ROLE = [$(AWS_CARRIER_ROLE)] if this is empty please set the environment variable
	@echo CARRIER_ORG = [$(CARRIER_ORG)] if this is empty please set the environment variable
	@echo CARRIER_ORG_SHORT = [$(CARRIER_ORG_SHORT)] if this is empty please set the environment variable
	aws --profile $(AWS_CARRIER_ROLE) eks update-kubeconfig --region us-east-1 --name ${CARRIER_ORG_SHORT}-dev-app-cluster

kubectl_carrier_config_carrier_blk_cluster:
	@echo AWS_CARRIER_ROLE = [$(AWS_CARRIER_ROLE)] if this is empty please set the environment variable
	@echo CARRIER_ORG = [$(CARRIER_ORG)] if this is empty please set the environment variable
	@echo CARRIER_ORG_SHORT = [$(CARRIER_ORG_SHORT)] if this is empty please set the environment variable
	aws --profile $(AWS_CARRIER_ROLE) eks update-kubeconfig --region us-east-1 --name ${CARRIER_ORG_SHORT}-dev-blk-cluster

kubectl_aais_port_forward_database:
	kubectl port-forward -n database svc/${AAIS_ORG_SHORT}-mongodb-headless 28017:27017

kubectl_analytics_port_forward_database:
	kubectl port-forward -n database svc/${ANALYTICS_ORG_SHORT}-mongodb-headless 28017:27017

kubectl_carrier_port_forward_database:
	kubectl port-forward -n database svc/${CARRIER_ORG_SHORT}-mongodb-headless 28017:27017

kubectl_port_forward_vault:
	kubectl -n vault port-forward svc/vault 8200:8200