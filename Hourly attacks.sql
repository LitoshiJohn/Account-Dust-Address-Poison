WITH poisoning_suspects AS (
  SELECT tx_from
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
    AND tx_from != tx_to
    AND LEFT(tx_from, 4) = LEFT(tx_to, 4)
    AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
  GROUP BY tx_from
)

SELECT 
  MAX(total_attacks) as peak_hourly_attacks,
  AVG(total_attacks) as avg_hourly_attacks,
  MAX(unique_attackers) as max_concurrent_attackers
FROM (
  SELECT 
    DATE_TRUNC('hour', block_timestamp) as hour,
    COUNT(DISTINCT ft.tx_from) as unique_attackers,
    COUNT(*) as total_attacks
  FROM solana.core.fact_transfers ft
  INNER JOIN poisoning_suspects p ON ft.tx_from = p.tx_from
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
  GROUP BY hour
) hourly_attacks;