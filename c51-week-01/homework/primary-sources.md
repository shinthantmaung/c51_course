## **AWS Shared Responsibility Model**: [Source](https://aws.amazon.com/compliance/shared-responsibility-model/)

### Applying the Model in practice
AWS recommends several steps:
1. Consider: Plan your cloud architecture using AWS Cloud Adoption Framework and Well-Architected best practices.
2. Review: Understand the security configurations of the AWS services you use.
3. Determine: Identify applicable security and compliance requirements.
4. Evaluate: Explore AWS security, identity, and compliance services.
5. Verify: Review AWS audit reports and compliance documentation to understand which controls you inherit.

### Factors That Shape Customer Responsibility
A customer’s exact responsibilities vary based on several factors, including the AWS services and **Region** they select, how those services are integrated into their IT environment, and the applicable laws and regulations for their business and workloads

## **GCP Shared Responsibility Model**: [Source](https://cloud.google.com/architecture/framework/security/shared-responsibility-shared-fate)

### Applying the Model in practice
Google recommends the following approach:
1. Identify the workloads you intend to deploy and determine whether they require IaaS, PaaS, or SaaS.
2. Identify applicable regulatory and compliance requirements.
3. Review Google's security blueprints and recommended controls.
4. Design your resource hierarchy and network architecture.
5. Deploy workloads using secure configurations.
6. Continuously verify your security posture using Google Cloud security tools

## **Azure Shared Responsibility Model**: [Source](https://learn.microsoft.com/en-us/azure/security/fundamentals/shared-responsibility)
### Cloud Security Advantages
Traditional on-premises environments often suffer from:
- Delayed security patching.
- Inadequate physical security.
- Incomplete network monitoring.
- Outdated hardware.
- Insufficient backup and disaster recovery.

## How the provider in each case differs in emphasis from the other two

AWS and Azure follow a similar traditional shared responsibility approach, explaining how security duties are divided between the provider and customer, whereas Google Cloud distinguishes itself through Shared Fate, emphasizing active collaboration and assistance in achieving better security outcomes
