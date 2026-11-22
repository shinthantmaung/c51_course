## Assets

| asset_id | name | asset_type | cloud | owner | data_class | notes |
|---:|---|---|---|---|---|---|
| 1 | User (Browser/Mobile) | external | n/a | end users | confidential | User credentials, session tokens, personal files being uploaded. (PII) |
| 2 | CDN Edge | network | aws | platform-team | public | Cached static website assets (images, CSS, JS), public API responses. |
| 3 | Load Balancer | network | aws | platform-team | internal | IP addresses, routing rules, ephemeral TLS termination data. |
| 4 | Web App (Compute) | compute | aws | app-team | confidential | Frontend code, user session states, transient user data in memory, business logic, transient database queries. (classified Internal/Confidential — stored as confidential) |
| 5 | Managed Postgres (PaaS) | database | aws | data-team | restricted | The crown jewels: user accounts, hashed passwords, core business records, financial data. |
| 6 | Uploads Bucket | storage | aws | app-team | confidential | User-uploaded files (images, documents, PDFs). |
| 7 | CI/CD pipeline | compute | saas | devops-team | restricted | Deploy credentials, deploy artifacts, source code. (classified Confidential/Restricted — stored as restricted) |
| 8 | Admin (Ops engineer) IAM role | identity | aws | security-team | restricted | Admin credentials, IAM role credentials. |

## Entry Points

1. **The Public Web Interface**
- Who/What: The User (Browser/Mobile app).

2. **The Administrative Interface**
- Who/What: Admin / Op engineer.

3. **Image Upload Path(to Storage Bucket)**
◇ Who/What: External User

5. **The Code Deployment Path (CI/CD to Compute)**
- Who/What: The CI/CD Pipeline.

## Trust Boundaries

1. **The Perimeter Boundary (Untrusted to Semi-Trusted)**
- Where it is: Between the User and the CDN / Load Balancer

2. **The Data Boundary (Internal to Restricted)**
- Where it is: Between the Web App and the Managed Postgres

3. **The Storage Boundary (Untrusted to internal)**
- Where it is: Between the User and the Storage Bucket

4. **The Management Boundary (high-trust to internal/restricted)**
- Where it is: Between the admin and Web App / DB

5. **The Deployment Boundary (high-trust to internal)**
- Where it is: Between CI/CD and Web App 

## Threat Modeling
| # | Boundary | STRIDE | Threat | Likelihood | Impact | Responsible Party | Mitigation Control |
|---|----------|--------|--------|------------|--------|-------------------|---------------------|
| 1 | Perimeter | Spoofing | Stolen user session token via XSS | 3 | 4 | Customer | Set HttpOnly and Secure flags on session cookies so JavaScript cannot read them. Implement a strict Content Security Policy (CSP) to block XSS execution. |
| 2 | Perimeter | Tampering | User data in transit gets tampered with MITM attack since TLS key was exposed via TLS downgrading (like POODLE) | 3 | 4 | Customer | Enforce TLS 1.2 or 1.3 only at the Load Balancer/CDN; disable all legacy protocols and weak cipher suites. Implement HSTS (HTTP Strict Transport Security). |
| 3 | Perimeter | Repudiation | A normal user deleted his own account and denies the action ("My account was hacked") since the action was not properly logged with IP and exact timestamp | 3 | 2 | Customer | Enable edge access logging (WAF/LB logs) to capture source IPs and precise timestamps. Send these logs to an immutable storage bucket. |
| 4 | Perimeter | Information Disclosure | User sessions and data in transit get exposed due to TLS key leak via TLS downgrading (like POODLE) | 3 | 4 | Customer | Enforce TLS 1.2+ with AEAD ciphers (like AES-GCM); disable weak cipher suites. |
| 5 | Perimeter | DoS | Volumetric DDoS attack against Load balancer/webapp | 3 | 2 | Customer | Use a cloud provider's DDoS protection (e.g., AWS Shield) and a CDN to absorb traffic. Implement rate limiting at the Load Balancer. |
| 6 | Perimeter | Elevation of Privilege | Privileged users' tokens get stolen via XSS | 3 | 5 | Customer | Use short-lived tokens; require MFA for privileged actions; isolate admin privileges in a separate, highly secure context. |
| 7 | Data | Spoofing, Tampering, Information Disclosure | Attacker using stolen web app role token or DB user's static creds; performing SQLi; DB publicly accessible | 4 | 4 | Customer | Use IAM database authentication with short-lived tokens (valid for 15 minutes) instead of static passwords; store any remaining secrets in a Secrets Manager; restrict database network access to private subnets only; use parameterized queries; encrypt data at rest(TDE or disk-level encryption |
| 8 | Data | Elevation of Privilege | web app's DB access role is scoped more than it needs  | 4 | 5 | Customer | Enforce Principle of Least Privilege — scope the role only to specific DB actions (e.g., rds-db:connect). |
| 9 | Data | DoS | Resource locking on DB so it no longer functions properly (e.g., running a query that locks tables like `LOCK TABLE users IN EXCLUSIVE MODE;`) | 3 | 2 | Customer | Set strict query timeouts; implement connection pooling limits (DB will only receive limited number of connections it can handle); use a Read Replica for heavy read queries to protect the Primary DB. |
| 10 | Storage | Spoofing | Although this is web app flaw, spoofing is possible if the attacker can trick the web app to generate signed URL for another user | 2 | 4 | Customer | The API must verify the user's authorization to the exact target path before generating the signed URL. |
| 11 | Storage | Information Disclosure | Uploads bucket could be set to public, exposing data to everyone on the internet | 4 | 4 | Customer | Enable S3 Block Public Access at the account level. Serve files using time-limited signed URLs, not public ACLs. |
| 12 | Storage | Repudiation | The origin of upload as each user is not properly logged; the user can deny | 3 | 2 | Customer | Enable bucket access logging and log the S3 event metadata (IAM principal, source IP) inside the Thumbnail Function. |
| 13 | Storage | Tampering | Upload image as another user thereby tampering the victim's data | 2 | 4 | Customer | Scope signed URLs to unique, user-specific paths (/uploads/{user_id}/) and verify the uploader's identity via metadata. |
| 14 | Storage | Elevation of Privilege | Web App's S3 access role might be overpermissioned allowing the user to generate previleged signed urls | 3 | 5 | Customer | apply least privilege to the web app's IAM role. |
| 15 | Management | Spoofing | Admin console gets exposed to public network and hit with bruteforce attacks or context) | 4 | 5 | Customer | Place admin consoles behind a VPN or Zero Trust Network Access (ZTNA); require hardware MFA. |
| 16 | Management | Repudiation | Bad admin tampering web app code or DB is not logged | 3 | 4 | Customer | Send admin logs to an immutable, write-once-read-many (WORM) storage bucket in a separate, highly restricted security account. |
| 17 | Deployment | DoS | The "Oops" DoS: A developer pushes a config change that accidentally drops the database connection pool, causing the web app to crash globally (the damage can be done without any malice) | 1 | 2 | Customer | Implement automated canary deployments; require health checks and automatic rollbacks if error rates spike after a deployment. |
| 18 | Deployment | Elevation of Privilege | CI/CD role is over-permissioned | 4 | 5 | Customer | Strictly scope the CI/CD IAM role to only the specific deployment related resources; never grant AdministratorAccess. |
| 19 | Deployment | Spoofing | CI/CD pipeline gets compromised via malicious pull request | 3 | 4 | Customer | Enforce branch protection and mandatory code review for PRs |
| 20 | Deployment | Information Disclosure | Deployment artifacts containing API keys are not properly stored | 4 | 4 | Customer | Never hardcode secrets; inject secrets at runtime using a Secrets Manager (e.g., Vault, AWS Secrets Manager); scan repos for secrets before committing. |

## Insights
### Top 10 Risks(Ordered by Risk Score)
| threat_id | stride_category | description | likelihood | impact | risk_score | mitigating_control | affected_assets |
|---:|---|---|---:|---:|---:|---|---|
| 18 | Elevation of Privilege | CI/CD role is over-permissioned | 4 | 5 | 20 | Strictly scope the CI/CD IAM role to only the specific deployment-related resources; never grant AdministratorAccess. | CI/CD pipeline \| Web App (Compute) \| Managed Postgres (PaaS) |
| 15 | Spoofing | Admin console gets exposed to the public network and hit with brute-force attacks | 4 | 5 | 20 | Place admin consoles behind a VPN or Zero Trust Network Access (ZTNA); require hardware MFA. | Admin (Ops engineer) IAM role \| Web App (Compute) \| Managed Postgres (PaaS) |
| 8 | Elevation of Privilege | Web app's DB access role is scoped more broadly than it needs | 4 | 5 | 20 | Enforce Principle of Least Privilege — scope the role only to specific DB actions (e.g. rds-db:connect). | Web App (Compute) \| Managed Postgres (PaaS) |
| 20 | Information Disclosure | Deployment artifacts containing API keys are not properly stored | 4 | 4 | 16 | Never hardcode secrets; inject secrets at runtime using a Secrets Manager (e.g. Vault, AWS Secrets Manager); scan repos for secrets before committing. | CI/CD pipeline \| Web App (Compute) |
| 11 | Information Disclosure | Uploads bucket could be set to public, exposing data to everyone on the internet | 4 | 4 | 16 | Enable S3 Block Public Access at the account level. Serve files using time-limited signed URLs, not public ACLs. | Uploads Bucket |
| 7 | Spoofing | Attacker uses a stolen web app role token or a DB user's static creds; performs SQLi; DB is publicly accessible | 4 | 4 | 16 | Use IAM database authentication with short-lived tokens (15 min) instead of static passwords; store remaining secrets in a Secrets Manager; restrict DB network access to private subnets only; use parameterized queries; encrypt data at rest (TDE or disk-level encryption). | Web App (Compute) \| Managed Postgres (PaaS) |
| 14 | Elevation of Privilege | Web App's S3 access role might be over-permissioned, allowing the user to generate privileged signed URLs | 3 | 5 | 15 | Apply least privilege to the web app's IAM role. | Web App (Compute) \| Uploads Bucket |
| 6 | Elevation of Privilege | Privileged users' tokens get stolen via XSS | 3 | 5 | 15 | Use short-lived tokens; require MFA for privileged actions; isolate admin privileges in a separate, highly secure context. | User (Browser/Mobile) \| Load Balancer \| Web App (Compute) |
| 19 | Spoofing | CI/CD pipeline gets compromised via a malicious pull request | 3 | 4 | 12 | Enforce branch protection and mandatory code review for PRs. | CI/CD pipeline \| Web App (Compute) |
| 16 | Repudiation | Malicious admin tampering with web app code or the DB is not logged | 3 | 4 | 12 | Send admin logs to an immutable, write-once-read-many (WORM) storage bucket in a separate, highly restricted security account. | Admin (Ops engineer) IAM role \| Web App (Compute) \| Managed Postgres (PaaS) |

## Threats with no mitigation controls yet
│ threat_id │ stride_category │ description │ likelihood │ impact │
|-----------|-----------------|-------------|------------|--------|
|  |  | --No Threats without mitigation controls-- |  |  |
