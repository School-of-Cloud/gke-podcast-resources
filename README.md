# gke-podcast-resources

### install the `kubectl` command line tool 

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