PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE assets (
    asset_id      INTEGER PRIMARY KEY,
    name          TEXT NOT NULL,
    asset_type    TEXT NOT NULL,      -- e.g. 'storage', 'compute', 'database', 'identity', 'network'
    cloud         TEXT NOT NULL,      -- 'aws' | 'gcp' | 'azure' | 'saas'
    owner         TEXT NOT NULL,      -- who on the (fictional) team owns this asset
    data_class    TEXT NOT NULL,      -- 'public' | 'internal' | 'confidential' | 'restricted'
    notes         TEXT
);
INSERT INTO assets VALUES(1,'User (Browser/Mobile)','external','n/a','end users','confidential','User credentials, session tokens, personal files being uploaded. (PII)');
INSERT INTO assets VALUES(2,'CDN Edge','network','aws','platform-team','public','Cached static website assets (images, CSS, JS), public API responses.');
INSERT INTO assets VALUES(3,'Load Balancer','network','aws','platform-team','internal','IP addresses, routing rules, ephemeral TLS termination data.');
INSERT INTO assets VALUES(4,'Web App (Compute)','compute','aws','app-team','confidential','Frontend code, user session states, transient user data in memory, business logic, transient database queries. (classified Internal/Confidential — stored as confidential)');
INSERT INTO assets VALUES(5,'Managed Postgres (PaaS)','database','aws','data-team','restricted','The crown jewels: user accounts, hashed passwords, core business records, financial data.');
INSERT INTO assets VALUES(6,'Uploads Bucket','storage','aws','app-team','confidential','User-uploaded files (images, documents, PDFs).');
INSERT INTO assets VALUES(7,'CI/CD pipeline','compute','saas','devops-team','restricted','Deploy credentials, deploy artifacts, source code. (classified Confidential/Restricted — stored as restricted)');
INSERT INTO assets VALUES(8,'Admin (Ops engineer) IAM role','identity','aws','security-team','restricted','Admin credentials, IAM role credentials.');
CREATE TABLE threat_assets (
    threat_id INTEGER NOT NULL REFERENCES threats(threat_id),
    asset_id  INTEGER NOT NULL REFERENCES assets(asset_id),
    PRIMARY KEY (threat_id, asset_id)
);
INSERT INTO threat_assets VALUES(1,1);
INSERT INTO threat_assets VALUES(1,2);
INSERT INTO threat_assets VALUES(1,3);
INSERT INTO threat_assets VALUES(1,4);
INSERT INTO threat_assets VALUES(2,1);
INSERT INTO threat_assets VALUES(2,2);
INSERT INTO threat_assets VALUES(2,3);
INSERT INTO threat_assets VALUES(3,1);
INSERT INTO threat_assets VALUES(3,3);
INSERT INTO threat_assets VALUES(3,4);
INSERT INTO threat_assets VALUES(4,1);
INSERT INTO threat_assets VALUES(4,2);
INSERT INTO threat_assets VALUES(4,3);
INSERT INTO threat_assets VALUES(5,2);
INSERT INTO threat_assets VALUES(5,3);
INSERT INTO threat_assets VALUES(5,4);
INSERT INTO threat_assets VALUES(6,1);
INSERT INTO threat_assets VALUES(6,3);
INSERT INTO threat_assets VALUES(6,4);
INSERT INTO threat_assets VALUES(7,4);
INSERT INTO threat_assets VALUES(7,5);
INSERT INTO threat_assets VALUES(8,4);
INSERT INTO threat_assets VALUES(8,5);
INSERT INTO threat_assets VALUES(9,4);
INSERT INTO threat_assets VALUES(9,5);
INSERT INTO threat_assets VALUES(10,4);
INSERT INTO threat_assets VALUES(10,6);
INSERT INTO threat_assets VALUES(11,6);
INSERT INTO threat_assets VALUES(12,4);
INSERT INTO threat_assets VALUES(12,6);
INSERT INTO threat_assets VALUES(13,1);
INSERT INTO threat_assets VALUES(13,4);
INSERT INTO threat_assets VALUES(13,6);
INSERT INTO threat_assets VALUES(14,4);
INSERT INTO threat_assets VALUES(14,6);
INSERT INTO threat_assets VALUES(15,8);
INSERT INTO threat_assets VALUES(15,4);
INSERT INTO threat_assets VALUES(15,5);
INSERT INTO threat_assets VALUES(16,8);
INSERT INTO threat_assets VALUES(16,4);
INSERT INTO threat_assets VALUES(16,5);
INSERT INTO threat_assets VALUES(17,7);
INSERT INTO threat_assets VALUES(17,4);
INSERT INTO threat_assets VALUES(17,5);
INSERT INTO threat_assets VALUES(18,7);
INSERT INTO threat_assets VALUES(18,4);
INSERT INTO threat_assets VALUES(18,5);
INSERT INTO threat_assets VALUES(19,7);
INSERT INTO threat_assets VALUES(19,4);
INSERT INTO threat_assets VALUES(20,7);
INSERT INTO threat_assets VALUES(20,4);
CREATE TABLE threats (
    threat_id      INTEGER PRIMARY KEY,
    stride_category TEXT NOT NULL,    -- Spoofing | Tampering | Repudiation | Info Disclosure | DoS | Elevation
    description    TEXT NOT NULL,
    likelihood     INTEGER NOT NULL,  -- 1 (rare) .. 5 (near certain)
    impact         INTEGER NOT NULL,  -- 1 (negligible) .. 5 (catastrophic)
    responsible_party TEXT NOT NULL,  -- 'provider' | 'customer' | 'shared'
    mitigating_control TEXT
);
INSERT INTO threats VALUES(1,'Spoofing','Stolen user session token via XSS',3,4,'customer','Set HttpOnly and Secure flags on session cookies so JavaScript cannot read them. Implement a strict Content Security Policy (CSP) to block XSS execution.');
INSERT INTO threats VALUES(2,'Tampering','User data in transit gets tampered with via MITM attack because the TLS key was exposed through TLS downgrading (e.g. POODLE)',3,4,'customer','Enforce TLS 1.2 or 1.3 only at the Load Balancer/CDN; disable all legacy protocols and weak cipher suites. Implement HSTS.');
INSERT INTO threats VALUES(3,'Repudiation','A normal user deleted their own account and denies the action ("my account was hacked") because the action was not properly logged with IP and exact timestamp',3,2,'customer','Enable edge access logging (WAF/LB logs) to capture source IPs and precise timestamps. Send these logs to an immutable storage bucket.');
INSERT INTO threats VALUES(4,'Information Disclosure','User sessions and data in transit get exposed due to TLS key leak via TLS downgrading (e.g. POODLE)',3,4,'customer','Enforce TLS 1.2+ with AEAD ciphers (e.g. AES-GCM); disable weak cipher suites.');
INSERT INTO threats VALUES(5,'DoS','Volumetric DDoS attack against the Load Balancer / web app',3,2,'Shared','Use a cloud provider''s DDoS protection (e.g. AWS Shield) and a CDN to absorb traffic. Implement rate limiting at the Load Balancer(Shared since AWS shied is provider''s infra).');
INSERT INTO threats VALUES(6,'Elevation of Privilege','Privileged users'' tokens get stolen via XSS',3,5,'customer','Use short-lived tokens; require MFA for privileged actions; isolate admin privileges in a separate, highly secure context.');
INSERT INTO threats VALUES(7,'Spoofing','Attacker uses a stolen web app role token or a DB user''s static creds; performs SQLi; DB is publicly accessible',4,4,'customer','Use IAM database authentication with short-lived tokens (15 min) instead of static passwords; store remaining secrets in a Secrets Manager; restrict DB network access to private subnets only; use parameterized queries; encrypt data at rest (TDE or disk-level encryption).');
INSERT INTO threats VALUES(8,'Elevation of Privilege','Web app''s DB access role is scoped more broadly than it needs',4,5,'customer','Enforce Principle of Least Privilege — scope the role only to specific DB actions (e.g. rds-db:connect).');
INSERT INTO threats VALUES(9,'DoS','Resource locking on the DB so it no longer functions properly (e.g. running LOCK TABLE users IN EXCLUSIVE MODE;)',3,2,'customer','Set strict query timeouts; implement connection-pooling limits; use a Read Replica for heavy read queries to protect the Primary DB.');
INSERT INTO threats VALUES(10,'Spoofing','Although this is a web app flaw, spoofing is possible if the attacker can trick the web app into generating a signed URL for another user',2,4,'customer','The API must verify the user''s authorization to the exact target path before generating the signed URL.');
INSERT INTO threats VALUES(11,'Information Disclosure','Uploads bucket could be set to public, exposing data to everyone on the internet',4,4,'customer','Enable S3 Block Public Access at the account level. Serve files using time-limited signed URLs, not public ACLs.');
INSERT INTO threats VALUES(12,'Repudiation','The origin of each upload per user is not properly logged, so the user can deny it',3,2,'customer','Enable bucket access logging and log the S3 event metadata (IAM principal, source IP) inside the Thumbnail Function.');
INSERT INTO threats VALUES(13,'Tampering','Upload an image as another user, thereby tampering with the victim''s data',2,4,'customer','Scope signed URLs to unique, user-specific paths (/uploads/{user_id}/) and verify the uploader''s identity via metadata.');
INSERT INTO threats VALUES(14,'Elevation of Privilege','Web App''s S3 access role might be over-permissioned, allowing the user to generate privileged signed URLs',3,5,'customer','Apply least privilege to the web app''s IAM role.');
INSERT INTO threats VALUES(15,'Spoofing','Admin console gets exposed to the public network and hit with brute-force attacks',4,5,'customer','Place admin consoles behind a VPN or Zero Trust Network Access (ZTNA); require hardware MFA.');
INSERT INTO threats VALUES(16,'Repudiation','Malicious admin tampering with web app code or the DB is not logged',3,4,'customer','Send admin logs to an immutable, write-once-read-many (WORM) storage bucket in a separate, highly restricted security account.');
INSERT INTO threats VALUES(17,'DoS','The "Oops" DoS: a developer pushes a config change that accidentally drops the DB connection pool, causing the web app to crash globally (no malice required)',1,2,'customer','Implement automated canary deployments; require health checks and automatic rollbacks if error rates spike after a deployment.');
INSERT INTO threats VALUES(18,'Elevation of Privilege','CI/CD role is over-permissioned',4,5,'customer','Strictly scope the CI/CD IAM role to only the specific deployment-related resources; never grant AdministratorAccess.');
INSERT INTO threats VALUES(19,'Spoofing','CI/CD pipeline gets compromised via a malicious pull request',3,4,'customer','Enforce branch protection and mandatory code review for PRs.');
INSERT INTO threats VALUES(20,'Information Disclosure','Deployment artifacts containing API keys are not properly stored',4,4,'customer','Never hardcode secrets; inject secrets at runtime using a Secrets Manager (e.g. Vault, AWS Secrets Manager); scan repos for secrets before committing.');
COMMIT;
