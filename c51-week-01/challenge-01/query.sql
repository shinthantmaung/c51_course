/*
INSERT INTO assets (asset_id, name, asset_type, cloud, owner, data_class, notes) VALUES
(1, 'User (Browser/Mobile)', 'external', 'n/a', 'End Users', 'confidential', 'User credentials, session tokens, personal files being uploaded.'),
(2, 'CDN / Edge Cache', 'network', 'aws', 'Edge Team', 'public', 'Cached static website assets (images, CSS, JS), public API responses.'),
(3, 'Load Balancer', 'network', 'aws', 'Network Team', 'internal', 'IP addresses, routing rules, ephemeral TLS termination data.'),
(4, 'Web App (Compute)', 'compute', 'aws', 'Frontend Team', 'confidential', 'Frontend code, user session states, transient user data in memory. (Internal/Confidential)'),
(5, 'Public API Service (Compute)', 'compute', 'aws', 'Backend Team', 'restricted', 'API keys, business logic, user authentication tokens, transient database queries. (Confidential/Restricted)'),
(6, 'Primary Postgres', 'database', 'aws', 'DBA Team', 'restricted', 'The crown jewels. User accounts, hashed passwords, core business records, financial data.'),
(7, 'Read Replica', 'database', 'aws', 'DBA Team', 'restricted', 'A duplicate of the Primary Postgres data (read-only).'),
(8, 'Uploads Bucket', 'storage', 'aws', 'Storage Team', 'confidential', 'User-uploaded files (images, documents, PDFs).'),
(9, 'Thumbnail Function', 'compute', 'aws', 'Serverless Team', 'confidential', 'Transient image data in memory, emitting logs containing PII info, function code. (Internal/Confidential)'),
(10, 'Message Queue', 'messaging', 'aws', 'Messaging Team', 'confidential', 'Asynchronous job payloads (e.g., email addresses, notification text).'),
(11, 'Background Worker', 'compute', 'aws', 'Backend Team', 'confidential', 'Email templates, User email addresses.'),
(12, 'CI/CD Pipeline', 'compute', 'aws', 'DevOps Team', 'restricted', 'Source code, deployment artifacts, build secrets, OIDC deployment tokens.'),
(13, 'Admin/On-call Engineer', 'identity', 'aws', 'Security Team', 'restricted', 'Admin credentials, MFA tokens, break-glass authorization keys.'),
(14, 'External Email Provider', 'saas', 'saas', 'Third-party', 'confidential', 'User email addresses, email content.'),
(15, 'Third-party Integration', 'external', 'saas', 'Partnerships Team', 'confidential', 'API keys, partner business data.');
*/

/*
CREATE TABLE threat_assets (
    threat_id INTEGER NOT NULL REFERENCES threats(threat_id),
    asset_id  INTEGER NOT NULL REFERENCES assets(asset_id),
    PRIMARY KEY (threat_id, asset_id)
);

-- 3. Insert the threats
INSERT INTO threats (threat_id, stride_category, description, likelihood, impact, responsible_party, mitigating_control) VALUES
(1, 'Spoofing', 'Stolen user session token via XSS', 3, 4, 'Customer', 'Set HttpOnly and Secure flags on session cookies so JavaScript cannot read them. Implement a strict Content Security Policy (CSP) to block XSS execution.'),
(2, 'Tampering', 'User data in transit gets tampered with MITM attack since TLS key was exposed via TLS downgrading (like POODLE)', 3, 4, 'Customer', 'Enforce TLS 1.2 or 1.3 only at the Load Balancer/CDN; disable all legacy protocols and weak cipher suites. Implement HSTS (HTTP Strict Transport Security).'),
(3, 'Repudiation', 'A normal user deleted his own account and denies the action ("My account was hacked") since the action was not properly logged with IP and exact timestamp', 3, 2, 'Customer', 'Enable edge access logging (WAF/LB logs) to capture source IPs and precise timestamps. Send these logs to an immutable storage bucket.'),
(4, 'Info Disclosure', 'User sessions and data in transit get exposed due to TLS key leak via TLS downgrading (like POODLE)', 3, 4, 'Customer', 'Enforce TLS 1.2+ with AEAD ciphers (like AES-GCM); disable weak cipher suites.'),
(5, 'DoS', 'Volumetric DDoS attack against Load balancer/webapp', 3, 2, 'Customer', 'Use a cloud provider''s DDoS protection (e.g., AWS Shield) and a CDN to absorb traffic. Implement rate limiting at the Load Balancer.'),
(6, 'Elevation', 'Privileged users'' tokens get stolen via XSS', 3, 5, 'Customer', 'Use short-lived tokens; require MFA for privileged actions; isolate admin privileges in a separate, highly secure context.'),
(7, 'Spoofing', 'Stolen user token and spoofing as web app (attacker directly requesting API bypassing webapp)', 2, 4, 'Customer', 'Validate the Web App''s identity to the API using mTLS (Mutual TLS) or a strict service-to-service JWT, not just relying on the user''s token.'),
(8, 'Tampering', 'Tampers another user''s data with IDOR', 3, 4, 'Customer', 'Implement strict object-level authorization (BOLA/BFLA checks) in the API to ensure the authenticated user actually owns the resource they are modifying.'),
(9, 'Info Disclosure', 'Access another user''s data with stolen token', 2, 4, 'Customer', 'Apply the Principle of Least Privilege to tokens; restrict data returned to only what the user needs (prevent over-fetching).'),
(10, 'Elevation', 'Letting web app use master token access to API instead of normal user token so if the web app gets compromised, not just user related stuff gets exposed, the other data stored gets exposed too', 4, 5, 'Customer', 'Never give the Web App a master token. Forward the user''s specific token to the API and enforce user-level authorization on every request.'),
(11, 'Spoofing', 'Attacker spoofing as API via stolen API role token or DB user''s static creds', 2, 4, 'Customer', 'Use IAM database authentication with short-lived tokens (valid for 15 minutes) instead of static passwords; store any remaining secrets in a Secrets Manager; restrict database network access to private subnets only.'),
(12, 'Tampering', 'Modifying sensitive data stored on DB (e.g., SQL injection)', 3, 4, 'Customer', 'Use parameterized queries (prepared statements) to prevent SQL injection; enforce strict database-level write constraints.'),
(13, 'Info Disclosure', 'Exposing sensitive user data', 2, 4, 'Customer', 'Encrypt data at rest (TDE or disk-level encryption).'),
(14, 'Elevation', 'Modifying IAM if the API role''s DB access policy is over-permissioned', 4, 5, 'Customer', 'Enforce Principle of Least Privilege at the database level (GRANT SELECT, INSERT on specific tables only; never SUPERUSER); scope the role only to specific DB actions (e.g., rds-db:connect).'),
(15, 'DoS', 'Resource locking on DB so it no longer functions properly (e.g., running a query that locks tables like LOCK TABLE users IN EXCLUSIVE MODE;)', 3, 2, 'Customer', 'Set strict query timeouts; implement connection pooling limits (DB will only receive limited number of connections it can handle); use a Read Replica for heavy read queries to protect the Primary DB.'),
(16, 'Spoofing', 'Although this is API flaw, spoofing is possible if the attacker can trick the API to generate signed URL for another user', 2, 4, 'Customer', 'The API must verify the user''s authorization to the exact target path before generating the signed URL.'),
(17, 'DoS', 'Uploading a malicious image (e.g., zip bomb: highly compressed file) crashing the function', 3, 2, 'Customer', 'Implement strict file size limits and memory/timeout constraints on the serverless function. Validate image dimensions before unpacking.'),
(18, 'Info Disclosure', 'Uploads bucket could be set to public, exposing data to everyone on the internet', 4, 4, 'Customer', 'Enable S3 Block Public Access at the account level. Serve files using time-limited signed URLs, not public ACLs.'),
(19, 'Repudiation', 'The origin of upload as each user is not properly logged', 3, 2, 'Customer', 'Enable bucket access logging and log the S3 event metadata (IAM principal, source IP) inside the Thumbnail Function.'),
(20, 'Tampering', 'Upload image as another user thereby tampering the victim''s data', 2, 4, 'Customer', 'Scope signed URLs to unique, user-specific paths (/uploads/{user_id}/) and verify the uploader''s identity via metadata.'),
(21, 'Elevation', 'Uploading malicious image and cause remote code execution as function role', 3, 5, 'Customer', 'Run the function in an isolated VPC with no internet access; validate file "magic bytes" (true file type); apply least privilege to the function''s IAM role.'),
(22, 'Spoofing', 'Admin console gets exposed to public network and hit with bruteforce attacks or CI/CD pipeline gets compromised via malicious pull request (e.g., Code execution in base repository context)', 4, 5, 'Customer', 'Place admin consoles behind a VPN or Zero Trust Network Access (ZTNA); require hardware MFA. Enforce branch protection and mandatory code review for PRs.'),
(23, 'Tampering', 'Tampering API code as a result of spoofing', 3, 5, 'Customer', 'Require cryptographic code signing for deployment artifacts; enforce strict CI/CD pipeline access controls.'),
(24, 'Repudiation', 'Bad admin tampering API code is not logged', 3, 4, 'Customer', 'Send CI/CD and admin logs to an immutable, write-once-read-many (WORM) storage bucket in a separate, highly restricted security account.'),
(25, 'Info Disclosure', 'Deployment artifacts containing API keys are not properly stored', 4, 4, 'Customer', 'Never hardcode secrets; inject secrets at runtime using a Secrets Manager (e.g., Vault, AWS Secrets Manager); scan repos for secrets before committing.'),
(26, 'DoS', 'The "Oops" DoS: A developer pushes a config change that accidentally drops the database connection pool, causing the API to crash globally (the damage can be done without any malice)', 1, 2, 'Customer', 'Implement automated canary deployments; require health checks and automatic rollbacks if error rates spike after a deployment.'),
(27, 'Elevation', 'CI/CD role is over-permissioned', 4, 5, 'Customer', 'Strictly scope the CI/CD IAM role to only the specific deployment resources needed; never grant AdministratorAccess.'),
(28, 'Spoofing', 'Provider spoofing by DNS poisoning, MITM or worker spoofing by stolen API key', 3, 4, 'Customer', 'Store the API key in Secrets Manager, TLS enforcing with strict certificate validation, IP allow listing.'),
(29, 'Tampering', 'MITM email tampering', 3, 4, 'Customer', 'Use TLS.'),
(30, 'Info Disclosure', 'Worker lazily sends the whole user profile instead of email to provider, if provider gets breached, all hell will break loose', 4, 4, 'Customer', 'Data minimization.'),
(31, 'Elevation', 'The API key is scoped too broad more than sending email. The entire email domain can get exposed', 4, 5, 'Customer', 'Principle of least privilege.'),
(32, 'Spoofing, Tampering, Info Disclosure, DoS', 'Stolen API key via MITM, code and logs', 3, 4, 'Customer', 'Don''t hardcode API key, use strict TLS enforcing, there is upgraded version called mTLS (mutual TLS) which also requires client''s certificate.'),
(33, 'Repudiation', 'Partner API call is not properly logged', 3, 2, 'Customer', 'Immutable Audit Logging (Write-Once-Read-Many / WORM storage), log API Key ID, Source IP, Timestamp, Endpoint, HTTP Method, and Response Code.'),
(34, 'Elevation', 'API key is scoped too broad for API access', 4, 4, 'Customer', 'Principle of least privilege.'),
(35, 'Spoofing', 'Publisher and subscriber are not properly authenticated', 4, 4, 'Customer', 'Queue level access policy with strictly scoped API and worker IAM roles.'),
(36, 'DoS', 'Malicious message crashes the background worker', 3, 2, 'Customer', 'Properly sanitize the message schema and send the message to Dead Letter Queue if fail to sanitize properly.');
*/

/*
-- ==========================================
-- THREAT TO ASSET MAPPING (Boundary-Aligned)
-- ==========================================

-- ------------------------------------------------------------------
-- 1. THE PERIMETER BOUNDARY (Untrusted to Semi-Trusted)
-- Between: User/Partner (1, 15) <--> CDN (2) / Load Balancer (3) / Web App (4)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(1, 1),  -- XSS: User's browser executes malicious script
(1, 4),  -- XSS: Web App serves the vulnerable page
(2, 2), (2, 3), (2, 4), -- MITM TLS downgrade: Affects CDN, LB, Web App in transit
(3, 2), (3, 3), (3, 4), -- Repudiation: Missing logs at CDN, LB, Web App
(4, 2), (4, 3), (4, 4), -- Info Disc TLS leak: Affects CDN, LB, Web App
(5, 2), (5, 3), (5, 4), -- DDoS: Attack targets CDN, LB, Web App
(6, 1), (6, 4), (6, 13); -- Priv XSS: User's token stolen via Web App, impacting Admin

-- ------------------------------------------------------------------
-- 2. THE APPLICATION SEGMENTATION BOUNDARY (Semi-Trusted to Internal)
-- Between: Load Balancer (3) / Web App (4) <--> Public API (5)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(7, 4), (7, 5),  -- Spoofing Web App: Attacker bypasses Web App (4) to hit API (5)
(8, 4), (8, 5),  -- IDOR: Web App (4) passes request, API (5) fails auth check
(9, 4), (9, 5),  -- Info Disc stolen token: Web App (4) compromised, API (5) leaks data
(10, 4), (10, 5); -- Master Token: Web App (4) uses over-privileged token to API (5)

-- ------------------------------------------------------------------
-- 3. THE DATA BOUNDARY (Internal to Restricted)
-- Between: Public API (5) / Thumbnail Fn (9) / Bg Worker (11) <--> Primary DB (6) / Uploads (8)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(11, 5), (11, 6),  -- Spoofing API role: API (5) credentials used to access DB (6)
(12, 5), (12, 6),  -- SQLi: API (5) query exploited to modify DB (6)
(13, 5), (13, 6), (13, 7), (13, 8), -- Info Disc: API (5) exposes DB (6, 7) or Uploads (8)
(14, 5), (14, 6),  -- Over-permissioned IAM: API (5) role has too much power on DB (6)
(15, 5), (15, 6), (15, 7); -- Resource Locking: API (5) query locks DB (6) or Read Replica (7)

-- ------------------------------------------------------------------
-- 4. THE EXECUTION BOUNDARY (Untrusted to Internal)
-- Between: Uploads Bucket (8) <--> Thumbnail Function (9)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(16, 5), (16, 8),  -- Spoofed URL: API (5) generates URL, Bucket (8) accepts it
(17, 8), (17, 9),  -- Zip Bomb: Uploaded to Bucket (8), crashes Thumbnail Fn (9)
(18, 8),           -- Public Bucket: Uploads Bucket (8) exposed
(19, 8), (19, 9),  -- Repudiation: Missing logs in Bucket (8) and Thumbnail Fn (9)
(20, 8),           -- Tampering: Attacker overwrites data in Bucket (8)
(21, 8), (21, 9);  -- RCE: Malicious file in Bucket (8) exploits Thumbnail Fn (9)

-- ------------------------------------------------------------------
-- 5. THE MANAGEMENT BOUNDARY (High-Trust to Internal)
-- Between: CI/CD (12) / Admin (13) <--> Production Compute (4, 5)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(22, 12), (22, 13), (22, 4), (22, 5), -- Spoofing: CI/CD (12) or Admin (13) compromised to hit Prod (4,5)
(23, 12), (23, 5),  -- Tampering: CI/CD (12) deploys tampered code to API (5)
(24, 12), (24, 13), -- Repudiation: Admin (13) or CI/CD (12) logs deleted
(25, 12),           -- Info Disc: Secrets leak from CI/CD (12) artifacts
(26, 12), (26, 4), (26, 5), -- Oops DoS: CI/CD (12) deploys bad config to Web App (4) and API (5)
(27, 12), (27, 4), (27, 5); -- Over-permissioned: CI/CD (12) role can take over Web App (4) and API (5)

-- ------------------------------------------------------------------
-- 6. THE EGRESS BOUNDARY (Internal to Untrusted)
-- Between: Background Worker (11) <--> External Email Provider (14)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(28, 11), (28, 14), -- Spoofing: Worker (11) spoofed or Provider (14) spoofed
(29, 11), (29, 14), -- MITM Email: Tampering between Worker (11) and Provider (14)
(30, 11), (30, 14), -- Info Disc: Worker (11) sends excess PII to Provider (14)
(31, 11), (31, 14); -- Broad API Key: Worker (11) key gives admin access to Provider (14)

-- ------------------------------------------------------------------
-- 7. THE PARTNER API BOUNDARY (Untrusted to Internal)
-- Between: Third-party Integration (15) <--> Public API (5)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(32, 15), (32, 5),  -- Stolen API Key: Partner (15) key used to attack API (5)
(33, 15), (33, 5),  -- Repudiation: Partner (15) denies request to API (5)
(34, 15), (34, 5);  -- Broad API Key: Partner (15) key has too much access to API (5)

-- ------------------------------------------------------------------
-- 8. THE BACKGROUND WORKER BOUNDARY (Internal to Internal)
-- Between: Public API (5) <--> Message Queue (10) / Background Worker (11)
-- ------------------------------------------------------------------
INSERT INTO threat_assets (threat_id, asset_id) VALUES
(35, 5), (35, 10), (35, 11), -- Spoofing: API (5) spoofed to Queue (10) or Worker (11) spoofed to Queue (10)
(36, 10), (36, 11);          -- Poison Pill: Malicious message in Queue (10) crashes Worker (11)
*/

-- top 10 risks
-- SELECT t.threat_id, t.stride_category, t.description, t.likelihood, t.impact, (t.likelihood * t.impact) AS risk_score, t.mitigating_control, GROUP_CONCAT(a.name, ' | ') AS affected_assets FROM threats t JOIN threat_assets ta ON t.threat_id = ta.threat_id JOIN assets a ON ta.asset_id = a.asset_id GROUP BY t.threat_id ORDER BY risk_score DESC LIMIT 10;

-- Everything touching the third-party partner
-- SELECT DISTINCT t.threat_id, t.stride_category, t.description, t.likelihood, t.impact, t.mitigating_control, a2.name AS other_affected_asset FROM threats t JOIN threat_assets ta1 ON t.threat_id = ta1.threat_id JOIN assets a1 ON ta1.asset_id = a1.asset_id JOIN threat_assets ta2 ON t.threat_id = ta2.threat_id JOIN assets a2 ON ta2.asset_id = a2.asset_id WHERE a1.name = 'Third-party Integration' AND a2.name != 'Third-party Integration';

-- Threats with no mitigating control yet
-- SELECT threat_id, stride_category, description, likelihood, impact FROM threats WHERE mitigating_control IS NULL OR TRIM(mitigating_control) = '';
