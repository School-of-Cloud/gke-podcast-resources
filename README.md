# Google Kubernetes Engine (GKE

## Installing Kubernetes locally

To install the `kubectl` command line tool - this will let you interact with the main Kubernetes API and run commands against Kubernetes clusters. 

```bash
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
```

Make the Make the kubectl binary executable.

```bash
chmod +x ./kubectl
```

Move the binary in to your PATH.

```bash
sudo mv ./kubectl /usr/local/bin/kubectl
```

Test to ensure the version you installed is up-to-date:

```bash
kubectl version --client
```

You should also be able to run `kubectl --help` to get a list of available commands:

### Installing Kubernetes on a Virtual Machine

If you are using Ubuntu I have a helper script which can be found under `./bin/install.sh` 

```yaml
cd bin

chmod +x ./docker-install.sh
chmod +x ./k8s-install.sh

sudo ./docker-install.sh
sudo ./k8s-install.sh
```

Ensure that the script runs completely by checking that `kubectl --help` works ok at the end.

## A Kubernetes Primer

- Before we tell Kubernetes to create 2 pods with our container in it, we need to build a docker image of the source code itself. So if you're following along clone the companion repo:

```bash
git clone git@github.com:School-of-Cloud/gke-podcast-resources.git
```

- Navigate into the demo directory and build out your docker image using the `Dockerfile`. You should specify a tag in the format of `<docker hub username>/<image name>:<version>` and don't forget to add the `.` at the end which tells docker to build an image using the `Dockerfile` in this directory.

```bash
docker build -t schoolofcloud/demo:0.0.1 .
```

- Once docker has finished you can view your built image with

```yaml
docker image ls

REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
schoolofcloud/demo   0.0.1               480aa9779d22        32 seconds ago      12.8MB
```

### Pods

So how can we get Kubernetes to run our demo container in side a Pod? We can do this via the `pod-example.yml` file which can be found in the `infra` directory.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: demo
spec:
  containers:
    - name: demo
      image: schoolofcloud/demo:0.0.1
```

- Next we use `Kubectl apply` and pass in the path to the configuration file to create the pod using the `-f` flag.

```bash
kubectl apply -f infra/k8s/pod-example.yml
```

- If you now run `kubectl get pods` you should see a list of pods and their status. As you can see from the image above I had an `nginx` pod running as well.

### Deployments

- A deployment for our demo app would look something like this:

```bash
apiVersion: apps/v1
kind: Deployment
metadata:
  name: demo-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: demo
  template:
    metadata:
      labels:
        app: demo
    spec:
      containers:
        - name: demo
          image: schoolofcloud/demo:latest
```

- If we want to apply this change to our kubernetes cluster on our local machine, we can use the same `kubectl apply` and pass in the path to the deployment file.

```bash
kubectl apply -f infra/k8s/deployment-example.yml
```

- After you run this command you can do `kubectl get deployments` to see a list of your deployments and `kubectl get pods` to check whether the 2 replicas have been created.

### Services

- Lets create a simple service for our cluster. I'm going to focus on a NodePort because thats the most appropriate service to expose our simple pod in this development setting to the outside world. A LoadBalancer would be overkill for this app.

```yaml
apiVersion: apps/v1
kind: Service
metadata:
  name: demo-service
spec:
  type: NodePort
  selector:
    app: demo
  ports:
    - name: demo
      protocol: TCP
      port: 8080
      targetPort: 8080
```

- To capply this service you can use the usual `kubectl apply` command and pass it the path so the service config file as have done in the past.

```bash
kubectl apply -f infra/k8s/service-example.yml
```

- I can make a request to `[localhost:31079](http://localhost:31079)` (get the port for the node by running `kubectl get services`. I will get the response from my Go server running in the pod.

```bash
curl localhost:31079
# Hello, demo
```

## Google Kubernetes Engine (GKE)

### GKE Demo

- Log into the Google Cloud console using an incognito window and click on the activate cloud shell button in the top right hand corner.
- `gcloud` is the command-line tool for Google Cloud. It comes pre-installed on Cloud Shell and supports tab-completion. Activate the shell by listing the active account name using `gcloud auth list` you may also need to set your project (you can grab the project ID from the UI)

```bash
$ gcloud auth list

# ACTIVE  ACCOUNT
# *     <myaccount>@<mydomain>.com

$ gcloud config list project
# [core]
# project (unset)

$ gcloud config set project <project-name>
# Updated property [core/project].

$ gcloud config list project
# [core]
# project = playground-s-11-6ffb1e65
```

- `gcloud services list --enabled` will give you the list of services that have already been enabled for you, and `gcloud services list --available` will return a full list of API that you can enable based on the permissions you have.
- The Google Kubernetes Engine API is called `[container.googleapis.com](http://container.googleapis.com)` and can be enabled as follows.

```bash
$ gcloud services enable container.googleapis.com

# Operation "operations/acf.42bd6f85-854f-46ef-8e57-68e0bc772172" finished successfully.
```

- When deploying the Go demo application to this cluster, the easiest way to do this is to push our docker image to Google Container Registry (which is Google's version of Docker Hub). We can do this in the gcloud shell by cloning our repository, giving it a tag in the format of [`gcr.io/<YOUR_PROJECT_ID>/<demo>:<DEMO_APP_VERSION>`](http://gcr.io/$(PROJECT_ID)/courses:$(USERS_APP_VERSION))

```bash
$ git clone https://github.com/School-of-Cloud/gke-podcast-resources.git

$ cd gke-podcast-resources/demo

$ docker build -t demo .
# ---> 9c447a82c7e8
# Successfully built 9c447a82c7e8
# Successfully tagged demo:latest

$ docker tag demo gcr.io/<project-id>/demo:0.0.1

$ demo $ docker image ls
# REPOSITORY                             TAG                 IMAGE ID            CREATED             SIZE
# demo                                   latest              9c447a82c7e8        2 minutes ago       12.8MB
# gcr.io/playground-s-11-da6f4fc9/demo   0.0.1               9c447a82c7e8        2 minutes ago       12.8MB

$ docker push gcr.io/<project-id>/demo:0.0.1
```

- If you delete your cluster you can recreate everything via the command line, the process is very similar

```bash
gcloud beta container --project "playground-s-11-0f34511a" clusters create "demo-cluster" --zone "us-central1-c" --no-enable-basic-auth --cluster-version "1.16.13-gke.401" --machine-type "g1-small" --image-type "COS" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --num-nodes "1" --enable-stackdriver-kubernetes --enable-ip-alias --network "projects/playground-s-11-0f34511a/global/networks/default" --subnetwork "projects/playground-s-11-0f34511a/regions/us-central1/subnetworks/default" --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0
```

```bash
kubectl create deployment demo-app --image=gcr.io/<project-id>/demo:0.0.1
```

- When you have the demo app running in your pods, to create a service that will expose the port 8080:

```bash
kubectl expose deployment demo-app --port=8080 --type=LoadBalancer
```
