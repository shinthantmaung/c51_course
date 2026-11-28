### For dana-analytics

- `RunInstances` and `ListAllMyBuckets` are only called after june-5 attack and they are called from unusual regions, so we will exclude them
- These permissions seem a lot. That is because dana needs to call startQueryExecution, and for that call to work properly, we need several bg permissions: *Athena* needs to read the column and schema information of the source S3 objects, so it needs access to glue catalog, after query has been performed, the result has to be written into a S3 bucket, so it needs access to a dedicated result S3 bucket.
- We used resource ARN * for describeInstances, it is not least-privilege violation, it is required API call limitation.
- generalize with * for GetObject of crunchlabs-reports bucket

### For ci-deploy-role

- although only 3 actions are performed by ci-deploy-role in logs, I also took  real world bg permissions required for these actions into consideration and the final result is like this. I still can't say myself to understand all these actions, especially cloudformation ones, but I will get there
