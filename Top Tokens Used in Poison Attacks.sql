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
  COUNT(DISTINCT ft.tx_to) as total_unique_victims,
  CASE
      WHEN mint = 'So11111111111111111111111111111111111111111' THEN 'SOL'
      WHEN mint = 'So11111111111111111111111111111111111111112' THEN 'WSOL'
      WHEN mint = 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB' THEN 'USDT'
      WHEN mint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v' THEN 'USDC'
  end as "TOKEN",
  SUM(ft.amount) as total_transferred_amount
FROM solana.core.fact_transfers ft
INNER JOIN poisoning_suspects p ON ft.tx_from = p.tx_from
WHERE ft.block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
AND mint in ('So11111111111111111111111111111111111111111', 'So11111111111111111111111111111111111111112', 
'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v', 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB')
GROUP BY mint;