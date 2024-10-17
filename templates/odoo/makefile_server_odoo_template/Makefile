DB_NAME=pybodoo2016
logs:
	tail -f -n 100 /var/log/odoo/odoo-server.log | ccze -A
restart:
	sudo service odoo-server restart
psql:
	sudo postgress
odoo_shell:
	sudo -u odoo python3 /odoo/odoo-server/odoo-bin shell -c /etc/odoo-server.conf -d pyb-calidad