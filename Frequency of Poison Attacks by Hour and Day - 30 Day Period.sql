SELECT 
  EXTRACT(HOUR FROM block_timestamp) as hour_of_day,
  DAYNAME(block_timestamp) as day_of_week,
  COUNT(DISTINCT tx_id) as poison_txn,
  COUNT(DISTINCT tx_from) as poisoner,
  COUNT(DISTINCT tx_to) victim
FROM solana.core.fact_transfers
WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
  AND LEFT(tx_from, 4) = LEFT(tx_to, 4)
  AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
  AND tx_from != tx_to
GROUP BY hour_of_day, day_of_week
ORDER BY hour_of_day, day_of_week;