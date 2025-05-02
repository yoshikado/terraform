# Prerequisites
## Install LXD snap
If you are going to run terraform not from one of the LXD cluster node,
install the LXD snap
```
sudo snap install lxd --channel 5.21/stable
```
## SSH access to one of the LXD cluster node
The terraform script will first need access to one of LXD cluster node
to create a terraform user and add client certificate.
Please make sure that you have SSH access and fill in the necessary variables
in `demo_multitenancy.tfvars`
## Generate client certificates
The terraform script will create two users for the LXD cluster, 
and in order to do this it requires the client certificates.
Generate those with the following commands:
```bash
clients="client1 client2"
for client in $clients; do
  openssl req \
    -new \
    -newkey ec:<(openssl ecparam -name secp384r1) \
    -x509 \
    -noenc \
    -days 365 \
    -out ~/"$client".crt \
    -keyout ~/"$client".key \
    -subj "/CN="$client""
done
```
## Prepare variables
Copy the example tfvars file and fill in with the necessary values.
```
$ cp demo_multitenancy.tfvars.example demo_multitenancy.tfvars
```

# Launch terraform
```
terraform init

terraform plan -var-file=./demo_multitenancy.tfvars

terraform apply -var-file=./demo_multitenancy.tfvars
```
