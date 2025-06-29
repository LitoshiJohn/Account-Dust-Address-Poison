SELECT 
    block_timestamp,
    tx_id,
    tx_from AS sender,
    mint,
    amount
FROM 
    solana.core.fact_transfers
WHERE tx_to = '{{wallet}}'
    AND amount < 0.0001
