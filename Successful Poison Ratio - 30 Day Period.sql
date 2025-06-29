WITH poisoning_suspects AS (
  SELECT tx_from
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
  AND LEFT(tx_from, 4) = LEFT(tx_to, 4)
  AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
  AND tx_from != tx_to
  GROUP BY tx_from
  
)
SELECT 
  COUNT(DISTINCT ft.tx_id) / COUNT(*) as successful_transfer_ratio,
  COUNT(DISTINCT ft.tx_to) / COUNT(DISTINCT ft.tx_from) as victim_to_attacker_ratio
FROM solana.core.fact_transfers ft
INNER JOIN poisoning_suspects p ON ft.tx_from = p.tx_from
WHERE ft.block_timestamp >= DATEADD('day', -30, CURRENT_DATE);