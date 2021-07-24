.PHONY: gogo build stop-services start-services truncate-logs kataribe bench

gogo: stop-services build kenji minako  truncate-logs start-services bench

build:
	make -C webapp/go app

stop-services:
	sudo systemctl stop nginx
	sudo systemctl stop isuxi.go
	sudo systemctl stop mysql

start-services:
	sudo systemctl start mysql
	sleep 5
	sudo systemctl start isuxi.go
	sudo systemctl start nginx

truncate-logs:
	sudo truncate --size 0 /var/log/nginx/access.log
	sudo truncate --size 0 /var/log/nginx/error.log

kataribe:
	sudo cat /var/log/nginx/access.log | ./kataribe

bench:
	cd ../ && sh bench.sh
kenji: TS=$(shell date "+%Y%m%d_%H%M%S")
kenji: 
	mkdir /home/isucon/logs/$(TS)
	sudo  cp -p /var/log/nginx/access.log  /home/isucon/logs/$(TS)/access.log
	sudo  cp -p /var/log/mysql/mysql-slow.log  /home/isucon/logs/$(TS)/mysql-slow.log
	sudo chmod -R 777 /home/isucon/logs/*
minako:
	scp -C kataribe.toml ubuntu@18.183.128.212:~/
	rsync -av -e ssh /home/isucon/logs ubuntu@18.183.128.212:/home/ubuntu  
satuki:
	ssh ubuntu@18.183.128.212 "sh push_github.sh"
couple: kenji minako satuki
