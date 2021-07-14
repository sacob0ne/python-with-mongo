## Python microservice with Mongo DB instance

### Configure Database
#### Use [db_config.json](src/db_config.json) in order to configure database URL, name, username and password. These are the default values:

```json
 {
   "db": {
            "url" : "mongodb://mongodb:27017/",
            "name" :"database_name",  
            "user" :"",
            "password" :""
    }
 }
``` 

##### These are the required/optional fields for APIs:

```py
fields = {   
    "title"     : "string",  #REQUIRED
    "body"      : "string",  #REQUIRED
    "created"   : "datetime" #OPTIONAL
} 
```

#### Into [Database](src/factory/database.py) file you can find methods that are called from [model](src/models):
- `insert` method store data to database after confirm validation from model 
- `find` method retries all data from MongoDB database 
- `find_by_id` method retries back a single search data
- `update` method stores updated data to database with corresponding ID
- and `delete` method deletes data from database with corresponding ID

#### APIs description:
| Request | Endpoint |  Details |
| --- | --- | --- |
| `GET` | `http://ip:5000/api/v1/todos`| Get all created users|
| `GET` | `http://ip:5000/api/v1/todos/<ID>`| Get single user by ID|
| `POST` | `http://ip:5000/api/v1/todos`| Insert an user|
| `PUT` | `http://ip:5000/api/v1/todos/<ID>`| Update an user|
| `DELETE` | `http://ip:5000/api/v1/todos/<ID>`| Delete an user|

## Docker Compose

If you want to run _python-microservice_ and MongoDB database locally with Docker Compose:

```
docker-compose up -d --build
```

Then, remove everything once finished with your tests:

```
docker-compose down
```

## Test the APIs locally

Once started both containers with `docker-compose`, access into Python's container and execute following commands, in order to add an user on MongoDB database - mentioned on [db_config.json](src/db_config.json) file - through APIs:

```
docker exec -it python-microservice /bin/bash
curl --location --request POST 'localhost:5000/api/v1/todos' --header 'Content-Type: application/json' -d '{ "name": "Homer", "surname": "Simpson" }'
```

The output will print the <ID> related to user previously created:

```
"Inserted Id 60df396757b9ac16feb40214"
```

If you want to check that user has been inserted correctly into MongoDB database:

```
docker exec -it mongodb /bin/bash
mongo mongodb://localhost:27017/replicaSet=rs0
> use database_name
> db.todos.find()
```

Expected output:

```
{ "_id" : ObjectId("60df396757b9ac16feb40214"), "name" : "Homer", "surname" : "Simpson", "created" : ISODate("2021-07-02T16:05:59.193Z"), "updated" : ISODate("2021-07-02T16:05:59.193Z")}
```

If you want to search a specific user by ID on MongoDB:

```
> db.todos.find("<ID>")

eg.
> db.todos.find("60df396757b9ac16feb40214")
```

Expected output:

```
{ "_id" : ObjectId("60df396757b9ac16feb40214"), "name" : "Homer", "surname" : "Simpson", "created" : ISODate("2021-07-02T16:05:59.193Z"), "updated" : ISODate("2021-07-02T16:05:59.193Z")}
```

If you want details about specific user by ID, use the following command into Python microservice's pod:

```
curl -X GET 'localhost:5000/api/v1/todos/<ID>'

eg.
curl -X GET 'localhost:5000/api/v1/todos/60df36f49a1d4e3d7dd31539'
```

Expected output:

```
{"_id":"60df36f49a1d4e3d7dd31539","created":"Fri, 02 Jul 2021 15:55:32 GMT","name":"Homer-2","surname":"Simpson-2","updated":"Fri, 02 Jul 2021 15:55:32 GMT"}
```

If you want to retrieve all users hosted into MongoDB database:

```
curl -X GET 'localhost:5000/api/v1/todos'
```

Expected output:
```
[{"_id":"60df36e89a1d4e3d7dd31537","created":"Fri, 02 Jul 2021 15:55:20 GMT","name":"Homer","surname":"Simpson","updated":"Fri, 02 Jul 2021 15:55:20 GMT"},{"_id":"60df36ee9a1d4e3d7dd31538","created":"Fri, 02 Jul 2021 15:55:26 GMT","name":"Homer-1","surname":"Simpson-1","updated":"Fri, 02 Jul 2021 15:55:26 GMT"},{"_id":"60df36f49a1d4e3d7dd31539","created":"Fri, 02 Jul 2021 15:55:32 GMT","name":"Homer-2","surname":"Simpson-2","updated":"Fri, 02 Jul 2021 15:55:32 GMT"}]
```

If you want to delete a specific user by ID:

```
curl -X DELETE 'localhost:5000/api/v1/todos/<ID>'

eg.
curl -X DELETE 'localhost:5000/api/v1/todos/60df36f49a1d4e3d7dd31539'
```

## Test the APIs on Minikube

1. Install [Minikube](https://minikube.sigs.k8s.io/docs/start/) on your PC.

2. Launch following command in order to start Minikube:

```
minikube start
```

3. Build image to run on Minikube with following commands:

```
eval $(minikube docker-env)
docker build -t python-app:1.0 .
```

Set image previously built into [Python](k8s/python-microservice.yaml) manifest, in the following section:

```
...
...
      containers:
        - name: python-app
          image: python-app:1.0     # Set image name here
          imagePullPolicy: Never
          ports:
            - name: python-app
              containerPort: 5000
...
...
```

4. Then, deploy MongoDB instance and Python microservice on Minikube with following commands:

```
kubectl apply -f k8s/mongodb-microservice.yaml
kubectl apply -f k8s/python-microservice.yaml
```

N.B. The commands of step 3 and 4 *must* be launched from same terminal.

5. Once started both pods, access into Python microservice's pod and execute following commands, in order to add a user on MongoDB database - mentioned on [db_config.json](src/db_config.json) file - through APIs:

```
kubectl exec -it <PYTHON_POD_NAME> /bin/bash
curl --location --request POST 'localhost:5000/api/v1/todos' --header 'Content-Type: application/json' -d '{ "name": "Homer", "surname": "Simpson" }'
```

The output will print the ID related to user previously created:

```
"Inserted Id 60df396757b9ac16feb40214"
```

If you want to check that user has been inserted correctly into MongoDB instance:

```
kubectl exec -it <MONGODB_POD_NAME> /bin/bash
mongo mongodb://localhost:27017/replicaSet=rs0
> use database_name
> db.todos.find()
```

Expected output:

```
{ "_id" : ObjectId("60df396757b9ac16feb40214"), "name" : "Homer", "surname" : "Simpson", "created" : ISODate("2021-07-02T16:05:59.193Z"), "updated" : ISODate("2021-07-02T16:05:59.193Z")}
```

If you want to search a specific user by ID on MongoDB:

```
> db.todos.find("<ID>")

eg.
> db.todos.find("60df396757b9ac16feb40214")
```

Expected output:

```
{ "_id" : ObjectId("60df396757b9ac16feb40214"), "name" : "Homer", "surname" : "Simpson", "created" : ISODate("2021-07-02T16:05:59.193Z"), "updated" : ISODate("2021-07-02T16:05:59.193Z")}
```

If you want details about specific user by ID, use the following command into Python microservice's pod:

```
curl -X GET 'localhost:5000/api/v1/todos/<ID>'

eg.
curl -X GET 'localhost:5000/api/v1/todos/60df36f49a1d4e3d7dd31539'
```

Expected output:

```
{"_id":"60df36f49a1d4e3d7dd31539","created":"Fri, 02 Jul 2021 15:55:32 GMT","name":"Homer-2","surname":"Simpson-2","updated":"Fri, 02 Jul 2021 15:55:32 GMT"}
```

If you want to retrieve all users hosted into MongoDB database:

```
curl -X GET 'localhost:5000/api/v1/todos'
```

Expected output:
```
[{"_id":"60df36e89a1d4e3d7dd31537","created":"Fri, 02 Jul 2021 15:55:20 GMT","name":"Homer","surname":"Simpson","updated":"Fri, 02 Jul 2021 15:55:20 GMT"},{"_id":"60df36ee9a1d4e3d7dd31538","created":"Fri, 02 Jul 2021 15:55:26 GMT","name":"Homer-1","surname":"Simpson-1","updated":"Fri, 02 Jul 2021 15:55:26 GMT"},{"_id":"60df36f49a1d4e3d7dd31539","created":"Fri, 02 Jul 2021 15:55:32 GMT","name":"Homer-2","surname":"Simpson-2","updated":"Fri, 02 Jul 2021 15:55:32 GMT"}]
```

If you want to delete a specific user by ID:

```
curl -X DELETE 'localhost:5000/api/v1/todos/<ID>'

eg.
curl -X DELETE 'localhost:5000/api/v1/todos/60df36f49a1d4e3d7dd31539'
```

# Deploy on Minikube with setup.sh

If you want to run Python microservice and MongoDB instance automatically, there is a script named `setup.sh` that will do following tasks for you:

1. Install Minikube if not present
2. Start Minikube
3. Build of Python microservice's image
4. Set new image on K8S manifest of Python microservice
5. Deploy K8S manifests of MongoDB instance and Python microservice

The script has been tested in `Ubuntu 20.04` operating system