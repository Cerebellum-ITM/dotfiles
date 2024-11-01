.PHONY: init
docker-container={{ cookiecutter.odoo_container }}
docker-container-db={{ cookiecutter.db_container }}
db-name=main
module_name=loans
dumpfile=dump.sql
filestore_dump_name=filestore
backup_zip=main_2024-07-22_20-55-42.zip
access_db= docker exec -it -u0 $(docker-container-db) bash
# Start local instance
init:
	{{ cookiecutter.docker_compose_cmd }} up -d
stop:
	{{ cookiecutter.docker_compose_cmd }} stop
down:
	{{ cookiecutter.docker_compose_cmd }} down
restart:
	{{ cookiecutter.docker_compose_cmd }} restart
	{{ cookiecutter.docker_compose_cmd }} logs -f --tail 100
logs:
	{{ cookiecutter.docker_compose_cmd }} logs -f --tail 100
odoo_shell:
	docker exec -it -u0 $(docker-container) bash -c "odoo shell -d $(db-name) -w odoo -r odoo --db_host db"
docker_shell:
	docker exec -it -u0 $(docker-container) bash
db_conteiner_shell: 
	docker exec -it -u0 $(docker-container-db) bash
postgres_shell:
	docker exec -it -u0 $(docker-container-db) bash -c "psql --host=localhost --username=odoo --dbname=$(db-name)"
update_module:
	{{ cookiecutter.docker_compose_cmd }} restart
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w odoo -r odoo --db_host db -u $(module_name) --stop-after-init
	{{ cookiecutter.docker_compose_cmd }} logs -f --tail 100
update_only_view:
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w odoo -r odoo --db_host db -u $(module_name) --stop-after-init
	{{ cookiecutter.docker_compose_cmd }} logs -f --tail 100
change_login:
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U odoo -c \"UPDATE res_users SET password = 'admin' WHERE id=2; UPDATE res_users SET login = 'admin' WHERE id=2;\""
remove_s3:
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U odoo -c \"UPDATE ir_attachment SET store_fname = REPLACE(store_fname, 's3://multimoto-odoo/', '') WHERE store_fname LIKE 's3%' AND 1=1;\""
restore_db:
	unzip $(backup_zip)
	mv $(filestore_dump_name) $(db-name)
	docker cp $(dumpfile) $(docker-container-db):./$(dumpfile)
	$(access_db) -c "psql -d postgres -U odoo -c 'CREATE DATABASE $(db-name);'"
	$(access_db) -c "psql -d $(db-name) -U odoo -f ./$(dumpfile)"
	$(access_db) -c "rm -r $(dumpfile)"	
	docker exec $(docker-container) bash -c "mkdir -p /var/lib/odoo/filestore"
	docker cp $(db-name) $(docker-container):/var/lib/odoo/filestore/$(db-name)
	docker exec -it -u0 $(docker-container) bash -c "chown odoo /var/lib/odoo/filestore/$(db-name)/*"
	docker exec -it -u0 $(docker-container) bash -c "chgrp odoo /var/lib/odoo/filestore/$(db-name)/*"
	docker exec -it -u0 $(docker-container) bash -c "cd /var/lib/odoo/filestore/$(db-name) && chown odoo checklist/*"
	docker exec -it -u0 $(docker-container) bash -c "cd /var/lib/odoo/filestore/$(db-name) && chgrp odoo checklist/*"
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U odoo -c \"UPDATE res_users SET password = 'admin' WHERE id=2; UPDATE res_users SET login = 'admin' WHERE id=2;\""