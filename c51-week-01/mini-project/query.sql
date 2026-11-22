/*(
CREATE TABLE assets (
    asset_id      INTEGER PRIMARY KEY,
    name          TEXT NOT NULL,
    asset_type    TEXT NOT NULL,      -- e.g. 'storage', 'compute', 'database', 'identity', 'network'
    cloud         TEXT NOT NULL,      -- 'aws' | 'gcp' | 'azure' | 'saas'
    owner         TEXT NOT NULL,      -- who on the (fictional) team owns this asset
    data_class    TEXT NOT NULL,      -- 'public' | 'internal' | 'confidential' | 'restricted'
    notes         TEXT
);
*/

/*
INSERT INTO assets
    (asset_id, name, asset_type, cloud, owner, data_class, notes)
VALUES
    (1,
     'User (Browser/Mobile)',
     'external',
     'n/a',
     'end users',
     'confidential',
     'User credentials, session tokens, personal files being uploaded. (PII)'),

    (2,
     'CDN Edge',
     'network',
     'aws',
     'platform-team',
     'public',
     'Cached static website assets (images, CSS, JS), public API responses.'),

    (3,
     'Load Balancer',
     'network',
     'aws',
     'platform-team',
     'internal',
     'IP addresses, routing rules, ephemeral TLS termination data.'),

    (4,
     'Web App (Compute)',
     'compute',
     'aws',
     'app-team',
     'confidential',
     'Frontend code, user session states, transient user data in memory, business logic, transient database queries. (classified Internal/Confidential — stored as confidential)'),

    (5,
     'Managed Postgres (PaaS)',
     'database',
     'aws',
     'data-team',
     'restricted',
     'The crown jewels: user accounts, hashed passwords, core business records, financial data.'),

    (6,
     'Uploads Bucket',
     'storage',
     'aws',
     'app-team',
     'confidential',
     'User-uploaded files (images, documents, PDFs).'),

    (7,
     'CI/CD pipeline',
     'compute',
     'saas',
     'devops-team',
     'restricted',
     'Deploy credentials, deploy artifacts, source code. (classified Confidential/Restricted — stored as restricted)'),

    (8,
     'Admin (Ops engineer) IAM role',
     'identity',
     'aws',
     'security-team',
     'restricted',
     'Admin credentials, IAM role credentials.');
*/

/*
CREATE TABLE threat_assets (
    threat_id INTEGER NOT NULL REFERENCES threats(threat_id),
    asset_id  INTEGER NOT NULL REFERENCES assets(asset_id),
    PRIMARY KEY (threat_id, asset_id)
);
*/



CREATE TABLE threats (
    threat_id      INTEGER PRIMARY KEY,
    stride_category TEXT NOT NULL,    -- Spoofing | Tampering | Repudiation | Info Disclosure | DoS | Elevation
    description    TEXT NOT NULL,
    likelihood     INTEGER NOT NULL,  -- 1 (rare) .. 5 (near certain)
    impact         INTEGER NOT NULL,  -- 1 (negligible) .. 5 (catastrophic)
    responsible_party TEXT NOT NULL,  -- 'provider' | 'customer' | 'shared'
    mitigating_control TEXT
);


-- ============================================================
-- 1) threats  (boundary column intentionally omitted)
-- ============================================================
INSERT INTO threats
    (threat_id, stride_category, description, likelihood, impact,
     responsible_party, mitigating_control)
VALUES
    (1, 'Spoofing',
     'Stolen user session token via XSS',
     3, 4, 'customer',
     'Set HttpOnly and Secure flags on session cookies so JavaScript cannot read them. Implement a strict Content Security Policy (CSP) to block XSS execution.'),

    (2, 'Tampering',
     'User data in transit gets tampered with via MITM attack because the TLS key was exposed through TLS downgrading (e.g. POODLE)',
     3, 4, 'customer',
     'Enforce TLS 1.2 or 1.3 only at the Load Balancer/CDN; disable all legacy protocols and weak cipher suites. Implement HSTS.'),

    (3, 'Repudiation',
     'A normal user deleted their own account and denies the action ("my account was hacked") because the action was not properly logged with IP and exact timestamp',
     3, 2, 'customer',
     'Enable edge access logging (WAF/LB logs) to capture source IPs and precise timestamps. Send these logs to an immutable storage bucket.'),

    (4, 'Information Disclosure',
     'User sessions and data in transit get exposed due to TLS key leak via TLS downgrading (e.g. POODLE)',
     3, 4, 'customer',
     'Enforce TLS 1.2+ with AEAD ciphers (e.g. AES-GCM); disable weak cipher suites.'),

    (5, 'DoS',
     'Volumetric DDoS attack against the Load Balancer / web app',
     3, 2, 'Shared',
     'Use a cloud provider''s DDoS protection (e.g. AWS Shield) and a CDN to absorb traffic. Implement rate limiting at the Load Balancer(Shared since AWS shied is provider''s infra).'),

    (6, 'Elevation of Privilege',
     'Privileged users'' tokens get stolen via XSS',
     3, 5, 'customer',
     'Use short-lived tokens; require MFA for privileged actions; isolate admin privileges in a separate, highly secure context.'),

    (7, 'Spoofing',
     'Attacker uses a stolen web app role token or a DB user''s static creds; performs SQLi; DB is publicly accessible',
     4, 4, 'customer',
     'Use IAM database authentication with short-lived tokens (15 min) instead of static passwords; store remaining secrets in a Secrets Manager; restrict DB network access to private subnets only; use parameterized queries; encrypt data at rest (TDE or disk-level encryption).'),

    (8, 'Elevation of Privilege',
     'Web app''s DB access role is scoped more broadly than it needs',
     4, 5, 'customer',
     'Enforce Principle of Least Privilege — scope the role only to specific DB actions (e.g. rds-db:connect).'),

    (9, 'DoS',
     'Resource locking on the DB so it no longer functions properly (e.g. running LOCK TABLE users IN EXCLUSIVE MODE;)',
     3, 2, 'customer',
     'Set strict query timeouts; implement connection-pooling limits; use a Read Replica for heavy read queries to protect the Primary DB.'),

    (10, 'Spoofing',
     'Although this is a web app flaw, spoofing is possible if the attacker can trick the web app into generating a signed URL for another user',
     2, 4, 'customer',
     'The API must verify the user''s authorization to the exact target path before generating the signed URL.'),

    (11, 'Information Disclosure',
     'Uploads bucket could be set to public, exposing data to everyone on the internet',
     4, 4, 'customer',
     'Enable S3 Block Public Access at the account level. Serve files using time-limited signed URLs, not public ACLs.'),

    (12, 'Repudiation',
     'The origin of each upload per user is not properly logged, so the user can deny it',
     3, 2, 'customer',
     'Enable bucket access logging and log the S3 event metadata (IAM principal, source IP) inside the Thumbnail Function.'),

    (13, 'Tampering',
     'Upload an image as another user, thereby tampering with the victim''s data',
     2, 4, 'customer',
     'Scope signed URLs to unique, user-specific paths (/uploads/{user_id}/) and verify the uploader''s identity via metadata.'),

    (14, 'Elevation of Privilege',
     'Web App''s S3 access role might be over-permissioned, allowing the user to generate privileged signed URLs',
     3, 5, 'customer',
     'Apply least privilege to the web app''s IAM role.'),

    (15, 'Spoofing',
     'Admin console gets exposed to the public network and hit with brute-force attacks',
     4, 5, 'customer',
     'Place admin consoles behind a VPN or Zero Trust Network Access (ZTNA); require hardware MFA.'),

    (16, 'Repudiation',
     'Malicious admin tampering with web app code or the DB is not logged',
     3, 4, 'customer',
     'Send admin logs to an immutable, write-once-read-many (WORM) storage bucket in a separate, highly restricted security account.'),

    (17, 'DoS',
     'The "Oops" DoS: a developer pushes a config change that accidentally drops the DB connection pool, causing the web app to crash globally (no malice required)',
     1, 2, 'customer',
     'Implement automated canary deployments; require health checks and automatic rollbacks if error rates spike after a deployment.'),

    (18, 'Elevation of Privilege',
     'CI/CD role is over-permissioned',
     4, 5, 'customer',
     'Strictly scope the CI/CD IAM role to only the specific deployment-related resources; never grant AdministratorAccess.'),

    (19, 'Spoofing',
     'CI/CD pipeline gets compromised via a malicious pull request',
     3, 4, 'customer',
     'Enforce branch protection and mandatory code review for PRs.'),

    (20, 'Information Disclosure',
     'Deployment artifacts containing API keys are not properly stored',
     4, 4, 'customer',
     'Never hardcode secrets; inject secrets at runtime using a Secrets Manager (e.g. Vault, AWS Secrets Manager); scan repos for secrets before committing.');

-- ============================================================
-- 2) threat_assets  (boundary -> adjacent assets)
-- ============================================================
/*
INSERT INTO threat_assets (threat_id, asset_id) VALUES
    -- Perimeter boundary (User #1 <-> CDN #2 / LB #3, terminating at Web App #4)
    (1, 1), (1, 2), (1, 3), (1, 4),
    (2, 1), (2, 2), (2, 3),
    (3, 1), (3, 3), (3, 4),
    (4, 1), (4, 2), (4, 3),
    (5, 2), (5, 3), (5, 4),
    (6, 1), (6, 3), (6, 4),
    -- Data boundary (Web App #4 <-> Managed Postgres #5)
    (7, 4), (7, 5),
    (8, 4), (8, 5),
    (9, 4), (9, 5),
    -- Storage boundary (User #1 / Web App #4 <-> Uploads Bucket #6)
    (10, 4), (10, 6),
    (11, 6),
    (12, 4), (12, 6),
    (13, 1), (13, 4), (13, 6),
    (14, 4), (14, 6),
    -- Management boundary (Admin #8 <-> Web App #4 / Managed Postgres #5)
    (15, 8), (15, 4), (15, 5),
    (16, 8), (16, 4), (16, 5),
    -- Deployment boundary (CI/CD #7 <-> Web App #4, landing on DB #5)
    (17, 7), (17, 4), (17, 5),
    (18, 7), (18, 4), (18, 5),
    (19, 7), (19, 4),
    (20, 7), (20, 4);
*/
