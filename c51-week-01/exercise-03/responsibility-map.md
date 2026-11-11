## 1. EC2 — `asset_type = compute`, `data_class = internal`

| Provider secures (AWS) | You secure (customer) |
|---|---|
| Physical data centers, hardware, networking, and the virtualization layer that host the instance | The **guest operating system**, including all updates and security patches |
| The managed network fabric and availability-zone infrastructure behind the instance | **Application software and utilities** installed on the instance, including their patching |
| Compliance auditing and third-party verification of the underlying infrastructure | **Security group** rules for each instance — the AWS-provided firewall that you configure |
| The physical host and hypervisor, which you never patch or log into | **IAM roles** attached to the instance and the exact permissions granted to those roles |
|  | **Network access controls** — VPC, subnets, NACLs, and route tables that decide what can reach the instance |
|  | **Credentials** used to connect to the instance (SSH keys, session tokens) |

> AWS categorizes EC2 as IaaS, which "requires the customer to perform all of the
> necessary security configuration and management tasks." Customers deploying an
> EC2 instance are responsible for "management of the guest operating system
> (including updates and security patches), any application software or utilities
> installed … and the configuration of the AWS-provided firewall (called a
> security group)."
>
> Service doc: <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security.html>

---

## 2. Aurora — `asset_type = database`, `data_class = confidential`

| Provider secures (AWS) | You secure (customer) |
|---|---|
| The **host operating system, database engine, and platform** that run Aurora, including patching them | **Data classification and sensitivity** — you decide what data goes in, and you own its confidentiality |
| Physical security of the facilities, hardware, and network that run the database | **IAM policies** that determine who can create, describe, modify, or delete DB clusters and instances |
| Storage durability, replication, and the managed control plane of the service | **Security group rules** controlling which IP addresses or EC2 instances may connect to the database |
| The managed backup infrastructure (though you choose retention and restore points) | **Encryption choices** — KMS keys, encryption at rest, and whether TLS is enforced in transit |
|  | **Database user accounts and credentials**, including rotation and Secrets Manager usage |
|  | **Network placement** — running the cluster in a VPC and deciding whether it is publicly accessible |

> AWS frames customer responsibility as "determined by the AWS service that you
> use," plus "the sensitivity of your data, your organization's requirements, and
> applicable laws and regulations." For Aurora specifically, the customer controls
> access through IAM, security groups, and SSL/TLS, and chooses whether the
> cluster runs in a VPC.
>
> Service doc: <https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.html>

---

## 3. Lambda — `asset_type = compute`, `data_class = internal`

| Provider secures (AWS) | You secure (customer) |
|---|---|
| The **underlying infrastructure, host OS, and application platform/runtime** that execute the function | **Function code** — its vulnerabilities and dependencies, including patching libraries such as log4j |
| Physical security of facilities, hardware, and the network | The **execution role** and the exact IAM permissions granted to the function |
| Patching of the managed runtime environment and container layer | **Resource configuration** — VPC subnets, security groups, memory, timeout, and concurrency limits |
| Operation of the Lambda service control plane and data plane | **Environment variables and secrets** — not hardcoding credentials, and encrypting what you do store |
|  | **The data the function processes**, and its sensitivity — you own the classification decision |
|  | **Event-source permissions and resource policies** that decide who may invoke the function |

> AWS describes Lambda's split as: AWS "manages the underlying infrastructure and
> core services, the operating system, and the application platform," while "the
> user is responsible for the security of their code and for managing identity and
> access (IAM) to the Lambda service and within their function." Customer
> responsibility is determined by the service used and includes "the sensitivity
> of your data, your company's requirements, and applicable laws and regulations."
>
> Service doc: <https://docs.aws.amazon.com/lambda/latest/dg/lambda-security.html>
> Whitepaper: <https://docs.aws.amazon.com/whitepapers/latest/security-overview-aws-lambda/the-shared-responsibility-model.html>
