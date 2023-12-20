
AWS_PROFILE_DEV := default
AWS_PROFILE_PROD := production
PROJECTNAME=$(shell basename "$(PWD)")
PACKAGE_PREFIX := home-assignment
PACKAGE := ${PROJECTNAME}
STORAGE := ${PROJECTNAME}-storage
REQ_FILE = ./aws-glue-home-assignment/requirements.txt
PYTHON := $(shell which python)
PIP := $(shell which pip)
PYV := $(shell $(PYTHON) -c "import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));sys.stdout.write(t)")
PWD := $(shell pwd)
AWS := $(shell which aws)
SHELL = /bin/bash

.PHONY: clean

.DEFAULT_GOAL: help

help: ## Show this help
	@printf "\n\033[33m%s:\033[1m\n" 'Choose available commands run in "$(PROJECTNAME)"'
	@echo "======================================================"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[32m%-14s		\033[35;1m-- %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@printf "\033[33m%s\033[1m\n"
	@echo "======================================================"


envs: ## Print environment variables
	@echo "======================================================"
	@echo "AWS_PROFILE_DEV: $(AWS_PROFILE_DEV)"
	@echo "AWS_PROFILE_PROD: $(AWS_PROFILE_PROD)"
	@echo "PROJECTNAME: $(PROJECTNAME)"
	@echo "PACKAGE_PREFIX: $(PACKAGE_PREFIX)"
	@echo "PACKAGE: $(PACKAGE)"
	@echo "STORAGE: $(STORAGE)"
	@echo "REQ_FILE: $(REQ_FILE)"
	@echo "PYTHON: $(PYTHON)"
	@echo "PIP: $(PIP)"
	@echo "PYV: $(PYV)"
	@echo "PWD: $(PWD)"
	@echo "AWS: $(AWS)"
	@echo "SHELL: $(SHELL)"
	@echo "======================================================"


install-requirements: ## Install requirements
	@echo "======================================================"
	$(PIP) install --upgrade pip
	$(PIP) install -r $(REQ_FILE)
	@echo "======================================================"


run-sync-from-local: ## aws cli cp etl_glue_job.py stock_prices.csv others...
	@echo "======================================================"
	@echo "AWS: $(AWS)"
	@echo "aws-profile $(AWS_PROFILE_DEV)"
	@cd aws-glue-home-assignment && aws s3 cp aws-glue-etl-job.py s3://aws-glue-home-assignment-serverless/etl-glue-script/
	@aws s3 cp stock_prices.csv s3://aws-glue-home-assignment-serverless/data/input/


run-glue-job: ## Run glue job by aws cli command with arguments
	@echo "======================================================"
	@echo "Script Run glue job: " ./aws-glue-home-assignment/run_glue_job_from_cli.sh
	sudo chmod +x ./aws-glue-home-assignment/run_glue_job_from_cli.sh
	./aws-glue-home-assignment/run_glue_job_from_cli.sh


create-clue-catalog-table-by_athena: ## Create Glue Catalog Table by Athena Queries
	@echo "======================================================"
	@echo "Script create anthena tables by execute sqls ./aws-glue-home-assignment/athena_queries.sql"
	@$(PYTHON) ./aws-glue-home-assignment/create_clue_catalog_table_by_athena.py


create-clue-catalog-table-by_glue: ## Create Glue Catalog Table by Glue AWS CLI
	@echo "======================================================"
	@echo "Script create anthena tables by running the script: " ./aws-glue-home-assignment/create_clue_catalog_table_by_glue.sh
	sudo chmod +x ./aws-glue-home-assignment/create_clue_catalog_table_by_glue.sh
	./aws-glue-home-assignment/create_clue_catalog_table_by_glue.sh


clean: ## Clean sources
	@echo "======================================================"
	@echo clean $(PROJECTNAME)
	@echo $(find ./* -maxdepth 0 -name "*.pyc" -type f)
	echo $(find . -name ".DS_Store" -type f)
	@rm -fR __pycache__ venv "*.pyc"
	@find ./* -maxdepth 0 -name "*.pyc" -type f -delete
	@find ./* -name '*.py[cod]' -delete
	@find ./* -name '__pycache__' -delete
	find . -name '*.DS_Store' -delete


list: ## Makefile target list
	@echo "======================================================"
	@echo Makefile target list
	@echo "======================================================"
	@cat Makefile | grep "^[a-z]" | awk '{print $$1}' | sed "s/://g" | sort


#deploy-aws-glue-home-assignment: ## Deploying aws-glue-home-assignment
#	@echo "======================================================"
#	@cd aws-glue-home-assignment && npm install
#	@cd aws-glue-home-assignment && serverless deploy --stage dev --aws-profile $(AWS_PROFILE_DEV) -v
#	@echo "======================================================"
#	@echo "DEBUG"
#	@cd aws-glue-home-assignment && serverless info --stage dev --aws-profile $(AWS_PROFIL_DEV) -v
#
#
#install-serverless: ## Install serverless via npm (npm must be installed)
#	@echo "======================================================"
#	@echo "Install serverless via npm (npm must be installed)"
#	@echo "======================================================"
#	@npm install -g serverless
#
#remove-aws-glue-home-assignment: ## Remove aws-glue-home-assignment
#	@echo "======================================================"
#	@cd aws-glue-home-assignment && serverless remove --stage localstack --aws-profile $(AWS_PROFILE_DEV) -v
#
#update: ## Do apt upgrade and autoremove
#	@echo "======================================================"
#	sudo apt update && sudo apt upgrade -y
#	sudo apt autoremove -y
