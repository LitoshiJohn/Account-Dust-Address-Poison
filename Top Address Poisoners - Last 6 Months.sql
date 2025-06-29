WITH transfers AS (
  SELECT 
    tx_from,
    COUNT(DISTINCT tx_to) as unique_addresses_poisoned,
    COUNT(*) as total_transfers,
  FROM solana.core.fact_transfers
  WHERE LEFT(tx_from, 4) = LEFT(tx_to, 4)
    AND RIGHT(tx_from, 4) = RIGHT(tx_to, 4)
    AND tx_from != tx_to
    AND block_timestamp >= DATEADD('month', -6, CURRENT_DATE)
  GROUP BY tx_from
)

SELECT 
  tx_from as poisoner_address,
  unique_addresses_poisoned,
  total_transfers,
FROM transfers
ORDER BY unique_addresses_poisoned DESC
LIMIT 20;