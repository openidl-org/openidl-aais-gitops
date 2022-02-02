copy_config_files:
	./copy-config-files-aais-dev.sh
	./copy-config-files-analytics-dev.sh
	./copy-config-files-carrier-dev.sh

apply_aais_secrets:
	node apply-secrets.js aais
	
apply_analytics_secrets:
	node apply-secrets.js analytics
	
apply_carrier_secrets:
	node apply-secrets.js carrier
	
copy_aais_secrets:
	./copy-config-files-aais-dev.sh
	node apply-secrets.js aais

copy_analytics_secrets:
	./copy-config-files-analytics-dev.sh
	node apply-secrets.js analytics

copy_carrier_secrets:
	./copy-config-files-carrier-dev.sh
	node apply-secrets.js carrier


