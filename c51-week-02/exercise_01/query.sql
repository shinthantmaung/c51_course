/*
CREATE TABLE iam_access_log (
    event_id          INTEGER PRIMARY KEY,
    event_time         TEXT    NOT NULL,   -- ISO-8601 UTC
    principal_arn       TEXT    NOT NULL,
    principal_type       TEXT    NOT NULL,   -- IAMUser | AssumedRole | FederatedUser
    event_source        TEXT    NOT NULL,   -- e.g. 'iam.amazonaws.com'
    event_name          TEXT    NOT NULL,   -- e.g. 'CreateAccessKey'
    resource_arn         TEXT,
    source_ip           TEXT    NOT NULL,
    aws_region           TEXT    NOT NULL,
    mfa_authenticated     BOOLEAN NOT NULL,
    error_code           TEXT              -- NULL means the call succeeded
);

INSERT INTO iam_access_log VALUES
(1,'2026-06-01T08:02:11Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','s3.amazonaws.com','GetObject','arn:aws:s3:::crunchlabs-reports/q2.csv','203.0.113.10','us-east-1',TRUE,NULL),
(2,'2026-06-01T08:03:47Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','s3.amazonaws.com','ListBucket','arn:aws:s3:::crunchlabs-reports','203.0.113.10','us-east-1',TRUE,NULL),
(3,'2026-06-01T08:10:02Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','athena.amazonaws.com','StartQueryExecution','arn:aws:athena:us-east-1:100200300400:workgroup/analytics','203.0.113.10','us-east-1',TRUE,NULL),
(4,'2026-06-01T08:11:55Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','ec2.amazonaws.com','DescribeInstances',NULL,'203.0.113.10','us-east-1',TRUE,NULL),
(5,'2026-06-01T09:00:00Z','arn:aws:iam::100200300400:role/ci-deploy-role','AssumedRole','lambda.amazonaws.com','UpdateFunctionCode','arn:aws:lambda:us-east-1:100200300400:function:crunchlabs-api','198.51.100.20','us-east-1',FALSE,NULL),
(6,'2026-06-01T09:00:04Z','arn:aws:iam::100200300400:role/ci-deploy-role','AssumedRole','cloudformation.amazonaws.com','UpdateStack','arn:aws:cloudformation:us-east-1:100200300400:stack/crunchlabs-api','198.51.100.20','us-east-1',FALSE,NULL),
(7,'2026-06-01T09:15:30Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','s3.amazonaws.com','PutObject','arn:aws:s3:::crunchlabs-raw/2026-06-01.json','198.51.100.44','us-east-1',FALSE,NULL),
(8,'2026-06-01T09:16:02Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','dynamodb.amazonaws.com','PutItem','arn:aws:dynamodb:us-east-1:100200300400:table/etl-state','198.51.100.44','us-east-1',FALSE,NULL),
(9,'2026-06-01T09:16:10Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','iam.amazonaws.com','ListUsers',NULL,'198.51.100.44','us-east-1',FALSE,NULL),
(10,'2026-06-01T09:16:12Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','ec2.amazonaws.com','RunInstances','arn:aws:ec2:us-east-1:100200300400:instance/*','198.51.100.44','us-east-1',FALSE,NULL),
(11,'2026-06-02T14:02:00Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','ListPolicies',NULL,'192.0.2.77','us-east-1',FALSE,NULL),
(12,'2026-06-02T14:02:20Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','GetPolicyVersion','arn:aws:iam::100200300400:policy/legacy-etl-policy','192.0.2.77','us-east-1',FALSE,NULL),
(13,'2026-06-02T14:04:10Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','CreatePolicyVersion','arn:aws:iam::100200300400:policy/legacy-etl-policy','192.0.2.77','us-east-1',FALSE,NULL),
(14,'2026-06-02T14:04:45Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','SetDefaultPolicyVersion','arn:aws:iam::100200300400:policy/legacy-etl-policy','192.0.2.77','us-east-1',FALSE,NULL),
(15,'2026-06-02T14:06:00Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','sts.amazonaws.com','AssumeRole','arn:aws:iam::100200300400:role/lab-admin-break-glass','192.0.2.77','us-east-1',FALSE,NULL),
(16,'2026-06-02T14:06:05Z','arn:aws:iam::100200300400:role/lab-admin-break-glass','AssumedRole','iam.amazonaws.com','CreateAccessKey','arn:aws:iam::100200300400:user/marco-intern','192.0.2.77','us-east-1',FALSE,NULL),
(17,'2026-06-02T14:06:40Z','arn:aws:iam::100200300400:role/lab-admin-break-glass','AssumedRole','iam.amazonaws.com','AttachUserPolicy','arn:aws:iam::100200300400:user/marco-intern','192.0.2.77','us-east-1',FALSE,NULL),
(18,'2026-06-02T14:07:10Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','ec2.amazonaws.com','RunInstances','arn:aws:ec2:us-east-1:100200300400:instance/*','192.0.2.77','us-east-1',FALSE,NULL),
(19,'2026-06-02T14:09:00Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','PassRole','arn:aws:iam::100200300400:role/lab-admin-break-glass','192.0.2.77','us-east-1',FALSE,NULL),
(20,'2026-06-02T14:09:05Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','lambda.amazonaws.com','CreateFunction','arn:aws:lambda:us-east-1:100200300400:function:innocuous-helper','192.0.2.77','us-east-1',FALSE,NULL),
(21,'2026-06-03T07:40:00Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','s3.amazonaws.com','GetObject','arn:aws:s3:::crunchlabs-reports/q3.csv','203.0.113.10','us-east-1',TRUE,NULL),
(22,'2026-06-03T07:41:00Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','s3.amazonaws.com','PutObject','arn:aws:s3:::crunchlabs-reports/scratch.csv','203.0.113.10','us-east-1',TRUE,'AccessDenied'),
(23,'2026-06-03T10:00:00Z','arn:aws:iam::100200300400:role/ci-deploy-role','AssumedRole','lambda.amazonaws.com','UpdateFunctionCode','arn:aws:lambda:us-east-1:100200300400:function:crunchlabs-api','198.51.100.20','us-east-1',FALSE,NULL),
(24,'2026-06-03T10:00:03Z','arn:aws:iam::100200300400:role/ci-deploy-role','AssumedRole','secretsmanager.amazonaws.com','GetSecretValue','arn:aws:secretsmanager:us-east-1:100200300400:secret:crunchlabs-api-db','198.51.100.20','us-east-1',FALSE,NULL),
(25,'2026-06-04T11:12:00Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','s3.amazonaws.com','PutObject','arn:aws:s3:::crunchlabs-raw/2026-06-04.json','198.51.100.44','us-east-1',FALSE,NULL),
(26,'2026-06-04T11:12:05Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','dynamodb.amazonaws.com','PutItem','arn:aws:dynamodb:us-east-1:100200300400:table/etl-state','198.51.100.44','us-east-1',FALSE,NULL),
(27,'2026-06-05T03:15:00Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','CreateAccessKey','arn:aws:iam::100200300400:user/dana-analytics','192.0.2.201','ap-southeast-1',FALSE,NULL),
(28,'2026-06-05T03:15:20Z','arn:aws:iam::100200300400:user/marco-intern','IAMUser','iam.amazonaws.com','AttachUserPolicy','arn:aws:iam::100200300400:user/dana-analytics','192.0.2.201','ap-southeast-1',FALSE,NULL),
(29,'2026-06-05T03:16:00Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','s3.amazonaws.com','ListAllMyBuckets',NULL,'192.0.2.201','ap-southeast-1',FALSE,NULL),
(30,'2026-06-05T03:16:40Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','ec2.amazonaws.com','RunInstances','arn:aws:ec2:us-east-1:100200300400:instance/*','192.0.2.201','ap-southeast-1',FALSE,NULL),
(31,'2026-06-06T08:00:00Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','s3.amazonaws.com','GetObject','arn:aws:s3:::crunchlabs-reports/q2.csv','203.0.113.10','us-east-1',TRUE,NULL),
(32,'2026-06-06T08:05:00Z','arn:aws:iam::100200300400:user/dana-analytics','IAMUser','athena.amazonaws.com','StartQueryExecution','arn:aws:athena:us-east-1:100200300400:workgroup/analytics','203.0.113.10','us-east-1',TRUE,NULL),
(33,'2026-06-06T09:30:00Z','arn:aws:iam::100200300400:role/ci-deploy-role','AssumedRole','lambda.amazonaws.com','UpdateFunctionCode','arn:aws:lambda:us-east-1:100200300400:function:crunchlabs-api','198.51.100.20','us-east-1',FALSE,NULL),
(34,'2026-06-06T09:30:03Z','arn:aws:iam::100200300400:role/ci-deploy-role','AssumedRole','cloudformation.amazonaws.com','UpdateStack','arn:aws:cloudformation:us-east-1:100200300400:stack/crunchlabs-api','198.51.100.20','us-east-1',FALSE,NULL),
(35,'2026-06-07T09:00:00Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','s3.amazonaws.com','PutObject','arn:aws:s3:::crunchlabs-raw/2026-06-07.json','198.51.100.44','us-east-1',FALSE,NULL),
(36,'2026-06-07T09:00:05Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','iam.amazonaws.com','DeleteUser','arn:aws:iam::100200300400:user/marco-intern','198.51.100.44','us-east-1',TRUE,NULL),
(37,'2026-06-07T09:01:00Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','iam.amazonaws.com','DeleteAccessKey','arn:aws:iam::100200300400:user/dana-analytics','198.51.100.44','us-east-1',TRUE,NULL),
(38,'2026-06-07T09:01:30Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','iam.amazonaws.com','DetachUserPolicy','arn:aws:iam::100200300400:user/dana-analytics','198.51.100.44','us-east-1',TRUE,NULL),
(39,'2026-06-07T09:02:00Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','iam.amazonaws.com','DeletePolicyVersion','arn:aws:iam::100200300400:policy/legacy-etl-policy','198.51.100.44','us-east-1',TRUE,NULL),
(40,'2026-06-07T09:03:00Z','arn:aws:iam::100200300400:user/legacy-svc-etl','IAMUser','cloudtrail.amazonaws.com','LookupEvents',NULL,'198.51.100.44','us-east-1',TRUE,NULL);
*/

SELECT event_name, resource_arn, error_code FROM iam_access_log WHERE principal_arn = 'arn:aws:iam::100200300400:user/dana-analytics' AND event_name = 'PutObject';

