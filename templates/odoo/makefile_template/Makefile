-include .env

.PHONY: init
docker-container={{ cookiecutter.odoo_container }}
docker-container-db={{ cookiecutter.db_container }}
db-name=main
module_name=loans
modele_path=
dumpfile=dump.sql
filestore_dump_name=filestore
backup_zip=main_2024-07-22_20-55-42.zip
access_db= docker exec -it -u0 $(docker-container-db) bash
TODAY := $(shell date +%Y-%m-%d)
CURRENT_DIR := $(shell pwd)
DOCKER_USER = USER
DOCKER_TOKEN = TOKEN
DOCKER_REPOSITORY = REPO
DOCKER_IMAGE_TAG = TAG

init:
	docker compose up -d
stop:
	docker compose stop
down:
	docker compose down
restart:
	docker compose restart
	docker compose logs -f --tail 100
logs:
	docker compose logs -f --tail 100
build_local_docker:
	docker compose build
odoo_shell:
	docker exec -it -u0 $(docker-container) bash -c "odoo shell -d $(db-name) -w $(POSTGRES_PASSWORD) -r $(POSTGRES_USER) --db_host db"
docker_shell:
	docker exec -it -u0 $(docker-container) bash
db_conteiner_shell: 
	docker exec -it -u0 $(docker-container-db) bash
postgres_shell:
	docker exec -it -u0 $(docker-container-db) bash -c "psql --host=localhost --username=$(POSTGRES_USER) --dbname=$(db-name)"
update_module:
	docker compose restart
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w $(POSTGRES_PASSWORD) -r $(POSTGRES_USER) --db_host db -u $(module_name) --stop-after-init
	clear
	$$HOME/dotfiles/tools/odoo_logo.sh
	@echo "\033[35m\nmodule update: $(module_name) completed!!!\033[0m"
	@sleep 2
	docker compose logs -f --tail 100
update_odoo_translation:
	docker compose restart
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w $(POSTGRES_PASSWORD) -r $(POSTGRES_USER) --db_host db -u $(module_name) --i18n-overwrite --stop-after-init
	@echo "\033[35m\nTranslation update: es_MX completed!!!\033[0m"
	@sleep 2
	docker compose logs -f --tail 100
export_odoo_translation:
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w $(POSTGRES_PASSWORD) -r $(POSTGRES_USER) --db_host db -l es_MX --i18n-export=/tmp/es_MX.po --modules $(module_name) --stop-after-init
	docker cp $(docker-container):/tmp/es_MX.po ./.
	~/dotfiles/tools/export_odoo_translation.sh $(module_name) $(module_path) $(CURRENT_DIR)
	@echo "\033[35m\nTranslations export completed: $(module_name) completed!!!\033[0m"
update_only_view:
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w $(POSTGRES_PASSWORD) -r $(POSTGRES_USER) --db_host db -u $(module_name) --stop-after-init
	docker compose logs -f --tail 100
change_login:
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U $(POSTGRES_USER) -c \"UPDATE res_users SET password = 'admin' WHERE id=2; UPDATE res_users SET login = 'admin' WHERE id=2;\""
docker_build_push:
	@echo "$(DOCKER_TOKEN)" | docker login -u $(DOCKER_USER) --password-stdin 
	docker build -t $(DOCKER_USER)/$(DOCKER_REPOSITORY):$(DOCKER_IMAGE_TAG) .
	docker push $(DOCKER_USER)/$(DOCKER_REPOSITORY):$(DOCKER_IMAGE_TAG)
remove_s3:
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U $(POSTGRES_USER) -c \"UPDATE ir_attachment SET store_fname = REPLACE(store_fname, 's3://multimoto-odoo/', '') WHERE store_fname LIKE 's3%' AND 1=1;\""
create_backup:
	$(access_db) -c "pg_dump -d $(db-name) -U $(POSTGRES_USER) -f ./$(dumpfile)"
	docker cp $(docker-container-db):./$(dumpfile) $(dumpfile)
	$(access_db) -c "rm -r ./$(dumpfile)"
	docker cp $(docker-container):/var/lib/odoo/filestore/$(db-name) $(db-name)
	zip -r $(db-name)_$(TODAY).zip $(db-name) $(dumpfile)
	rm $(dumpfile)
	rm -r $(db-name)
neutralize_db:
	docker exec -it -u0 $(docker-container) bash -c "odoo neutralize -d $(db-name) -w $(POSTGRES_PASSWORD) -r $(POSTGRES_USER) --db_host db"
restore_db:
	unzip $(backup_zip)
	mv $(filestore_dump_name) $(db-name)
	docker cp $(dumpfile) $(docker-container-db):./$(dumpfile)
	$(access_db) -c "psql -d $(POSTGRES_DB) -U odoo -c 'CREATE DATABASE $(db-name);'"
	$(access_db) -c "psql -d $(db-name) -U odoo -f ./$(dumpfile)"
	$(access_db) -c "rm -r $(dumpfile)"
	docker exec $(docker-container) bash -c "mkdir -p /var/lib/odoo/filestore"
	docker cp $(db-name) $(docker-container):/var/lib/odoo/filestore/$(db-name)
	docker exec -it -u0 $(docker-container) bash -c "chown -R odoo:odoo /var/lib/odoo/filestore/$(db-name)"
	docker exec -it -u0 $(docker-container) bash -c "chmod -R 755 /var/lib/odoo/filestore/$(db-name)"
	docker exec -it -u0 $(docker-container) bash -c "cd /var/lib/odoo/filestore/$(db-name) && chown odoo checklist/*"
	docker exec -it -u0 $(docker-container) bash -c "cd /var/lib/odoo/filestore/$(db-name) && chgrp odoo checklist/*"
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U $(POSTGRES_USER) -c \"UPDATE res_users SET password = 'admin' WHERE id=2; UPDATE res_users SET login = 'admin' WHERE id=2;\""

