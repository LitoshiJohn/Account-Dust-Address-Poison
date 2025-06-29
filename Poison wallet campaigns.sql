WITH poisoning_suspects AS (
  SELECT 
    tx_from,
    COUNT(DISTINCT tx_to) as unique_recipients,
    COUNT(*) as total_transfers,
    AVG(amount) as avg_transfer_amount,
    MIN(block_timestamp) as first_activity,
    MAX(block_timestamp) as last_activity
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
  AND LEFT(tx_from, 4) = LEFT(tx_to, 4)
  AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
  AND tx_from != tx_to
  GROUP BY tx_from

)
SELECT 
  COUNT(DISTINCT p.tx_from) as total_suspected_attackers,
  AVG(p.unique_recipients) as avg_victims_per_attacker,
  AVG(p.total_transfers) as avg_transfers_per_attacker,
  AVG(DATEDIFF('hour', p.first_activity, p.last_activity)) as avg_campaign_duration_hours,
  SUM(CASE WHEN l.label_type IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*) as pct_labeled_attackers
FROM poisoning_suspects p
LEFT JOIN solana.core.dim_labels l ON p.tx_from = l.address;