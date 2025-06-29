WITH dust_senders AS (
  SELECT 
    tx_from,
    COUNT(DISTINCT tx_to) as recipient_count,
    COUNT(DISTINCT tx_id) as tx_count,
    AVG(amount) as avg_amount,
    MIN(block_timestamp) as first_dust,
    MAX(block_timestamp) as last_dust
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
    AND amount < 0.001 -- Define dust amount threshold
    AND mint in ('So11111111111111111111111111111111111111111')
  GROUP BY tx_from
  HAVING recipient_count > 10 -- Filter for addresses targeting multiple recipients
)
SELECT 
  d.*
FROM dust_senders d
ORDER BY recipient_count DESC
LIMIT 100;