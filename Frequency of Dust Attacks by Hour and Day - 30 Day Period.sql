SELECT 
  EXTRACT(HOUR FROM block_timestamp) as hour_of_day,
  DAYNAME(block_timestamp) as day_of_week,
  COUNT(DISTINCT tx_id) as dust_tx_count,
  COUNT(DISTINCT tx_from) as unique_senders,
  COUNT(DISTINCT tx_to) as unique_recipients
FROM solana.core.fact_transfers
WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
  AND amount < 0.0001 -- Define dust amount threshold
  AND mint = 'So11111111111111111111111111111111111111111'
GROUP BY hour_of_day, day_of_week
ORDER BY hour_of_day, day_of_week;