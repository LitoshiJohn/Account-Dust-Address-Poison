WITH dust_transfers AS (
  SELECT 
    DATE_TRUNC('day', block_timestamp) as date,
    tx_id,
    tx_from,
    tx_to,
    amount,
    mint
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
    AND amount < 0.0001   
    AND mint = 'So11111111111111111111111111111111111111111'
)
SELECT 
  date,
  COUNT(DISTINCT tx_id) as dust_tx_count,
  COUNT(DISTINCT tx_from) as unique_dusters,
  COUNT(DISTINCT tx_to) as unique_victims,
  AVG(amount) as avg_dust_amount
FROM dust_transfers
GROUP BY date
ORDER BY date;