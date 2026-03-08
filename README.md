# START v1

* ruby 4
* rails 8
* inertia.js
* postgresql

### local dev

* ```/bin/dev```
* to reset migrations: ```rails db:migrate:reset:primary```
* to reset solid queue db: (1) ```rails db:drop:queue``` (2) ```rails db:prepare```