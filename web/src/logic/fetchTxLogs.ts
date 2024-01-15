import { getProvider } from './web3';

// This function fetches transaction logs for a given transaction hash
export async function fetchTransactionLogs(txHash: string) {
    try {
        // Using ethers.js to connect to the Ethereum network
        const provider = await getProvider(true)

        // Fetching the transaction receipt, which contains the logs
        const receipt = await provider.getTransactionReceipt(txHash);

        if (!receipt) {
            console.log('Transaction receipt not found');
            return "PUTO"
        }

        console.log('Transaction Logs:', receipt.logs);
        return receipt;
    } catch (e) {
        console.error(e)
    }
}