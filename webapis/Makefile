#! make

all: build up pause browse

build:
	docker build -t kthb/kontarion:apidemo .

browse:
	firefox http://localhost/__swagger__/

up:
	docker-compose up -d

pause:
	sleep 5
