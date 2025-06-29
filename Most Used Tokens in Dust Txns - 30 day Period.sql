WITH dust_tokens AS (
  SELECT 
    mint,
    COUNT(DISTINCT tx_id) as dust_tx_count,
    COUNT(DISTINCT tx_from) as unique_senders,
    COUNT(DISTINCT tx_to) as unique_recipients,
    AVG(amount) as avg_dust_amount
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -30, CURRENT_DATE)
    AND amount < 0.001 -- Define dust amount threshold
  GROUP BY mint
)
SELECT 
  l.label as token_name,
  dt.*,
FROM dust_tokens dt
LEFT JOIN solana.core.dim_labels l ON dt.mint = l.address
ORDER BY dust_tx_count DESC
LIMIT 20;