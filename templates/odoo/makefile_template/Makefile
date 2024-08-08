.PHONY: init
docker-container = {{ cookiecutter.odoo_container }}
docker-container-db = {{ cookiecutter.db_container }}
module_name = accounting_gateway
backup_zip = backup
access_db = docker exec -it -u0 $(docker-container-db) bash

init:
	docker-compose up -d
stop:
	docker-compose stop
down:
	docker-compose down
logs:
	docker-compose logs -f --tail 100
restart:
	docker-compose restart
	docker-compose logs -f --tail 100
odoo_shell:
	docker exec -it -u0 $(docker-container) bash -c "odoo shell -d $(db-name) -w odoo -r odoo --shell-interface ipython --db_host db"
odoo_shell_module_update:
	docker exec -it -u0 $(docker-container) bash -c "odoo shell -d $(db-name) -w odoo -r odoo --db_host db"
docker_shell:
	docker exec -it -u0 $(docker-container) bash
postgres_shell:
	docker exec -it -u0 $(docker-container-db) bash -c "psql --host=localhost --username=odoo --dbname=$(db-name)"
create_database:
	$(access_db) -c "psql -d postgres -U odoo -c 'CREATE DATABASE $(db-name);'"
create_dump:
	$(access_db) -c "pg_dump -U odoo -h localhost -p 5432 -W main > backup_main.sql"
copy_dump_to_conteiner:
	docker cp dump.sql $(docker-container-db):./dump.sql
restore_database:
	$(access_db) -c "psql -d $(db-name) -U odoo -f ./dump.sql"
unzip_filestore:
	unzip $(backup_zip)
unzip_tar_filestore:
	tar -xf $(backup_zip)
copy_filestore:
	mv filestore $(db-name)
	docker cp $(db-name) $(docker-container):/var/lib/odoo/filestore/
update_module:
	docker-compose restart
	docker exec -it $(docker-container) odoo -c /etc/odoo/odoo.conf -d $(db-name) -w odoo -r odoo --db_host db -u $(module_name) --stop-after-init
	docker-compose logs -f --tail 100
change_login:
	docker exec -it -u0 $(docker-container-db) bash -c "psql -d $(db-name) -U odoo -c \"UPDATE res_users SET password = 'admin' WHERE id=2; UPDATE res_users SET login = 'admin' WHERE id=2;\""