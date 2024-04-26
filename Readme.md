# Orbidi Tech Assessment

This is the solution to the assessment sent by Orbidi.

## Requirement

You will need to have installed terraform 1 at least, I suggest using [tfenv](https://github.com/tfutils/tfenv) to install it:

```bash
TFENV_ARCH=arm64 tfenv install 1.5.5 && TFENV_ARCH=arm64 tfenv use 1.5.5
```

Of course, you will need an AWS account where to create the infrastructure (I suggest using [awsume](https://awsu.me/) to assume the role needed), I did not add a workflow to automatically create the infra so you will need to run it manually:

```bash
cd terraform/
terraform init
```

## Infrastructure Creation

```bash
cd terraform/
terraform apply -var 'environment=development'
```

## Infrastructure Deletion

```bash
cd terraform/
terraform destroy -var 'environment=development'
```

## How is this infrastructure security compliance?

- The VPC was created with a public and a private subnet, all that you need to be secured needs to be created on the private one
- Another thing to add is to encrypt the volumes (that's a TODO)
- A bastion host was created to access the database and private network (I prefer to create a VPN such like OpenVPN or wireguard but that's another TODO)
- All the sensitive information is being stored inside the cloud (such like secrets and keys)