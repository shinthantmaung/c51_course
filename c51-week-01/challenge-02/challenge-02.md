## Incident 1 — Capital One (2019)

**Source**: [Wiz threat intelligence writeup](https://threats.wiz.io/all-incidents/capital-one-incident-march-2019) and [AWS Builder Center technical deconstruction](https://builder.aws.com/content/3KBRZoplywlsVic8Ao6UotwADpR/the-waf-that-open-sourced-the-bank-deconstructing-capital-ones-aws-cloud-breach)

**Summary**: A former cloud engineer exploited a server-side request forgery (SSRF) flaw in an open-source WAF running on an EC2 instance to query the instance metadata service (IMDSv1). The metadata service returned temporary STS credentials for an attached IAM role that had far broader S3 read permissions than the WAF needed, allowing the attacker to list and exfiltrate data from over 700 S3 buckets—nearly 30GB of consumer credit application data.

**Shared-responsibility classification**: Customer side (IaaS). The provider's metadata service behaved as designed for its era; the failure was in how the customer configured identity. The source states the compromised instance had an IAM role "with excessive read permissions to AWS S3", and the root cause was a combination of "the SSRF vulnerability" and the WAF being "assigned excessive IAM permissions". 

**Failure mode**: Over-permissioned identity. The attached IAM role granted S3 read access well beyond the WAF's actual job.

**Later-week defense**: Week 2 — IAM.

## Incident 2 — Microsoft Midnight Blizzard (2024)

**Sources** : [Cloud Security Alliance reflection on the breach](https://cloudsecurityalliance.org/blog/2025/09/15/reflecting-on-the-2024-microsoft-breach) and [Safeguard.sh technical analysis](https://safeguard.sh/resources/blog/midnight-blizzard-microsoft-email-breach-analysis)

**Summary**: A Russia-aligned threat actor password-sprayed a legacy, non-production test tenant that lacked MFA, then discovered a test OAuth application in that tenant that had been granted elevated Exchange Online permissions. The actor used that application to created additional malicious OAuth apps and grant `full_access_as_app` roles to them, which grant access to every mailbox in the organization, and read corporate email without any interactive user session.

**Shared-responsibility classification**: Customer side (SaaS/PaaS identity layer). Microsoft is both the provider and the customer here, but the failure sits on the customer side of the line: the provider's identity platform enforced the permissions it was told to enforce, while the customer (Microsoft's own corporate IT) left a legacy OAuth app with elevated access in a tenant without MFA. The CSA writeup notes the app “had elevated access to the Microsoft corporate environment”, and the Safeguard analysis states the actor “found a test OAuth application with high Exchange privileges”. Nothing in the provider's service malfunctioned; the trust granted to a neglected application was the point of failure.

**Failure mode**: Over-permissioned identity. The legacy OAuth application held `full_access_as_app`—the maximal Exchange Online mailbox permission—without a corresponding operational need in a test tenant.

**Later-week defense**: Week 2 — IAM 

## Incident 3 — Okta (2023)

**Sources**: [Okta's own root-cause and remediation disclosure](https://sec.okta.com/articles/2023/11/unauthorized-access-oktas-support-case-management-system-root-cause/) and [Help Net Security postmortem summary](https://www.helpnetsecurity.com/2023/11/06/okta-support-compromised-service-account/)

**Summary**: A service-account credential for Okta's customer support case management system was saved into an employee's personal Google profile after they signed into Chrome with that profile on an Okta-managed laptop. The attacker used that credential to access support cases and downloaded HAR files that contained live session tokens, which were then used to hijack the Okta sessions of five customers.

**Shared-responsibility classification**: Provider side. The failure occurred inside Okta's own support infrastructure, and Okta's customers had no configuration control over the compromised service account or the HAR-file retention workflow. Okta's postmortem states that an employee's personal Google profile exposed the credential; the remediation Okta later prescribed — blocking personal-profile sign-in on managed browsers and binding sessions to network location — are provider-side controls Okta alone could implement.

**Failure mode**: Leaked long-lived credentials. The service-account password was a static, long-lived secret that ended up synced to a personal consumer account—exactly the pattern that secret managers and short-lived tokens are designed to eliminate.

**Later-week defense**: Week 2 — IAM
