SELECT a.name, t.stride_category, t.description, (t.likelihood * t.impact) AS risk_score
FROM threats t
JOIN assets a ON a.asset_id = t.asset_id
ORDER BY risk_score DESC;

--output
/*
╭──────┬──────────────────────┬───────────────────────┬──────────╮
│ name │   stride_category    │      description      │risk_score│
╞══════╪══════════════════════╪═══════════════════════╪══════════╡
│Aurora│Information Disclosure│access confidential    │        15│
│      │                      │customer information   │          │
├──────┼──────────────────────┼───────────────────────┼──────────┤
│Aurora│Tampering             │modify customer's      │        15│
│      │                      │sensitive data for     │          │
│      │                      │malicious purposes     │          │
├──────┼──────────────────────┼───────────────────────┼──────────┤
│lambda│Elevation Of Privilege│assume over-privileged │        12│
│      │                      │execution role to      │          │
│      │                      │modify IAM policy      │          │
├──────┼──────────────────────┼───────────────────────┼──────────┤
│EC2   │Information Disclosure│access orgainization's │         9│
│      │                      │internal data          │          │
├──────┼──────────────────────┼───────────────────────┼──────────┤
│lambda│Information Disclosure│access internal data   │         9│
│      │                      │from env var and logs  │          │
├──────┼──────────────────────┼───────────────────────┼──────────┤
│EC2   │Tampering             │modify the running code│         6│
│      │                      │to the attacker's      │          │
│      │                      │advantage              │          │
╰──────┴──────────────────────┴───────────────────────┴──────────╯
*/

SELECT COUNT(*) FROM threats WHERE responsible_party = 'customer';

/*
╭──────────╮
│ COUNT(*) │
╞══════════╡
│        6 │
╰──────────╯

*/

SELECT a.asset_type, COUNT(t.threat_id) AS threat_count FROM   assets  a JOIN   threats t ON t.asset_id = a.asset_id GROUP  BY a.asset_type ORDER  BY threat_count DESC, a.asset_type;

/*
╭────────────┬──────────────╮
│ asset_type │ threat_count │
╞════════════╪══════════════╡
│ compute    │            4 │
│ database   │            2 │
╰────────────┴──────────────╯

*/
