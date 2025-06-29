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
  COUNT(DISTINCT CASE WHEN l.label_type = 'cex' THEN ft.tx_to END) as cex_wallets_targeted,
  COUNT(DISTINCT CASE WHEN l.label_type = 'defi' THEN ft.tx_to END) as defi_wallets_targeted,
  COUNT(DISTINCT CASE WHEN l.label_type = 'nft' THEN ft.tx_to END) as nft_wallets_targeted
FROM solana.core.fact_transfers ft
INNER JOIN poisoning_suspects p ON ft.tx_from = p.tx_from
LEFT JOIN solana.core.dim_labels l ON ft.tx_to = l.address
WHERE ft.block_timestamp >= DATEADD('day', -30, CURRENT_DATE);