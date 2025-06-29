WITH wallet_values AS (
  -- Calculate SOL wallet values only
  SELECT 
    owner,
    balance as wallet_value_sol
  FROM solana.core.fact_sol_balances
  WHERE block_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
  QUALIFY ROW_NUMBER() OVER (PARTITION BY owner ORDER BY block_timestamp DESC) = 1
),

dust_transfers AS (
  -- Identify dust transfers (small SOL transfers)
  SELECT 
    tx_id,
    tx_to as receiver,
    amount as transfer_amount_sol
  FROM solana.core.fact_transfers
  WHERE block_timestamp >= DATEADD('day', -7, CURRENT_TIMESTAMP())
  AND mint = 'So11111111111111111111111111111111111111111' -- Only Sol
  AND amount < 0.0001 --
)

SELECT 
  CASE 
    WHEN wallet_value_sol >= 1000 THEN 'Large (>=1000 SOL)'
    WHEN wallet_value_sol >= 100 THEN 'Medium (100-1000 SOL)'
    WHEN wallet_value_sol >= 10 THEN 'Small (10-100 SOL)'
    ELSE 'Micro (<10 SOL)'
  END as wallet_category,
  COUNT(DISTINCT w.owner) as total_wallets,
  COUNT(DISTINCT d.tx_id) as dust_transactions_received,
  ROUND(COUNT(DISTINCT d.tx_id)::FLOAT / NULLIF(COUNT(DISTINCT w.owner), 0), 2) as avg_dust_txns_per_wallet,
  ROUND(AVG(d.transfer_amount_sol), 6) as avg_dust_amount_sol,
  ROUND(SUM(d.transfer_amount_sol), 6) as total_dust_amount_sol
FROM wallet_values w
LEFT JOIN dust_transfers d
  ON w.owner = d.receiver
GROUP BY 1
ORDER BY 
  CASE wallet_category
    WHEN 'Large (>=1000 SOL)' THEN 1
    WHEN 'Medium (100-1000 SOL)' THEN 2
    WHEN 'Small (10-100 SOL)' THEN 3
    WHEN 'Micro (<10 SOL)' THEN 4
  END;