WITH poison_transfers AS (
  SELECT 
    tx_to,
    COUNT(*) as transfers_per_address
  FROM 
    solana.core.fact_transfers
  WHERE 
    amount < 0.001
    AND LEFT(tx_from, 4) = LEFT(tx_to, 4)
    AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
    AND block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
    AND tx_from != tx_to
  GROUP BY 
    tx_to
)
SELECT 
  COUNT(DISTINCT tx_to) AS unique_targeted_addresses,
  SUM(transfers_per_address) AS total_poison_txn,
  AVG(transfers_per_address) AS avg_poison_txn_per_wallet
FROM 
  poison_transfers;