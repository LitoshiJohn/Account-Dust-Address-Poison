SELECT 
  DATE_TRUNC('day', block_timestamp) AS date,
  COUNT(*) AS num_poisoning_tx
FROM 
  solana.core.fact_transfers
WHERE 
  amount < 0.001
  AND LEFT(tx_from, 4) = LEFT(tx_to, 4)
  AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
  AND tx_from != tx_to
  AND block_timestamp >= DATEADD ('day', -30, CURRENT_DATE) -- last 30 days
GROUP BY 
  1
ORDER BY 
  1