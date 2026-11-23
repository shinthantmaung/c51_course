**1.Physical security of an AWS datacenter.**  
Provider  
Why: Provider always is responsible for physical security of datacenters in all three providers across all service types

**2.Patching the guest OS on an EC2 instance.**  
Customer  
Why: Customer is the one responsible for guest OS patching in IaaS

**3.Patching the database engine inside RDS.**  
Provider  
Why: The underlying database engine is patched by provider for RDS

**4.Whether an RDS instance is publicly reachable.**  
Customer  
Why: Database network config has to be managed by customer

**5.The strength of an RDS master password.**  
Customer  
Why: Customer is the one responsible for DB password setting

**6.Whether an S3 bucket has public read enabled.**  
Customer  
Why: S3 bucket IAM policy has to be managed by customer

**7.Durability/redundancy of objects stored in S3.**  
Provider  
Why: Provider is responsible for durability and physical redundancy(like multi AZ zones) of objects

**8.The IAM policy attached to a Lambda function's execution role.**  
Customer  
Why: IAM policy configuration is to be performed by customer in PaaS

**9.The underlying compute isolation between two different AWS customers' Lambda functions.**  
Provider  
Why: Customer don't have to manage underlying platform infrastructure in PaaS

**10.Whether TLS is enabled on your load balancer.**  
Customer  
Why: TLS/HTTPS application protocol decision is to be made by customer while provider provides the underlying TLS engine. LB is mostly PaaS btw and network seurity groups and firewall rules are decided by customer even though the provider provides the mechanisms required. 

**11.The physical security of Google's network backbone.**  
Provider  
Why: Physical network security of routers and switches are enforced by provider

**12.Which OAuth apps are authorized to access your Google Workspace data.**  
Customer  
Why: This is application level access decision and to be made by customer in SaaS

**13.Google's patching of the underlying Workspace application itself.**  
Provider  
Why: underlying application management is done by provider in SaaS

**14.The MFA setting on your own cloud account's root/owner identity.**  
Customer  
Why: Customer has to configure account level MFA setting

**15.Encryption-at-rest availability as a feature, on a managed database.**  
Provider  
Why: Data encryption feature has to be provided by provider

**16.Whether encryption-at-rest is actually turned on for a specific database instance.**  
Customer  
Why: Data Encryption falls under customer's responsibility

**17.The default deny/allow posture of a newly created VPC/VNet.**  
Provider  
Why: newly created VPC denies all inbound traffic and allows all outbound traffic by default and that default setting is done by provider.

**18.A security group/firewall rule you configured to allow 0.0.0.0/0 on port 22.**  
Customer  
Why: Provider provides security group mechanism and customer is the one to set the rules

**19.The isolation between your VPC and another customer's VPC on shared physical hardware.**  
Provider  
Why: I think this kind of thing is provider's responsibility

**20.Timely patching of a zero-day in the hypervisor itself.**  
Provider  
Why: hypervisor layer is to be patched by provider across all three types
