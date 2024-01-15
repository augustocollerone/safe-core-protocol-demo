import { ethers, getAddress, toBigInt, parseEther, keccak256, toUtf8Bytes, ZeroHash, AddressLike } from "ethers"
import { getProvider } from "./web3";
import { submitTxs } from "./safeapp";
import { getManager } from "./protocol";
import { CAPTURE_THE_FLAG_ABI, CAPTURE_THE_FLAG_ADDRESS } from "./sample";
import { buildExecuteTx } from "./safe";
import { SafeMultisigConfirmation, SafeMultisigTransaction } from "./services";
import { fetchTransactionLogs } from "./fetchTxLogs";
import { loadPluginDetails } from "./plugins";

const SAMPLE_PLUGIN_CHAIN_ID = 5
export const TOKET_PLUGIN_ADDRESS = getAddress("0x3a3eD63874AC1832B8d845B6F5858CfB363e37e4") // Whitelist Plugin
const SAMPLE_PLUGIN_ABI = [
    "function addToWhitelist(address account) external",
    "function removeFromWhitelist(address account) external",
    "function executeFromPlugin(address manager, address safe, bytes calldata data) external",
    "function whitelistedAddresses(address, address) view returns (bool)"
]

export const isKnownSamplePlugin = (chainId: number, address: string): boolean => 
    ethers.toBigInt(chainId) == ethers.toBigInt(SAMPLE_PLUGIN_CHAIN_ID) &&
    getAddress(address) === TOKET_PLUGIN_ADDRESS  

const getWhitelistPlugin = async(forceRpc: boolean = false) => {
    const provider = await getProvider(forceRpc)
    return new ethers.Contract(
        TOKET_PLUGIN_ADDRESS,
        SAMPLE_PLUGIN_ABI,
        provider
    )
    
  }
export const checkWhitelist = async(safeAddress: string, account: string): Promise<boolean> => {
    try {

        const result = await fetchTransactionLogs(account)
        console.log("*AC fetchTransactionLogs: ", result);

        if (1 === 1) {
            return true;
        }

        const plugin = await getWhitelistPlugin()
        return await plugin.whitelistedAddresses(safeAddress, account);
    } catch (e) {
        console.error(e)
        return false
    }
}

export const addToWhitelist = async (
  account: string,
) => {
  try {
      const plugin = await getWhitelistPlugin()
      await submitTxs([
          {
              to: await plugin.getAddress(),
              value: "0",
              data: (
                  await plugin.addToWhitelist.populateTransaction(account)
              ).data
          }
      ])
  } catch (e) {
      console.error(e)
  }
};

export const removeFromWhitelist = async (
  account: string,
) => {
  try {
      const plugin = await getWhitelistPlugin()
      await submitTxs([
          {
              to: await plugin.getAddress(),
              value: "0",
              data: (
                  await plugin.removeFromWhitelist.populateTransaction(account)
              ).data
          }
      ])
  } catch (e) {
      console.error(e)
  }
};

export const whitelistTx = async(safeAddress: string) => {
    console.log("*AC whitelistTx: ", safeAddress);
    
    try {
        const provider = await getProvider(true);
        
        const walletAddress = "0xbe5d8E56FFead41Ac765f601fDa35679C4712414"
        const privateKey = '0x34def0655870ec3ea7010d9bfa82c911a56e1256ff4ecb2e7f2af009da98c633';

        const wallet = new ethers.Wallet(privateKey, provider);
        const plugin = new ethers.Contract(TOKET_PLUGIN_ADDRESS, SAMPLE_PLUGIN_ABI, wallet);
        const captureTheFlag = new ethers.Contract(CAPTURE_THE_FLAG_ADDRESS, CAPTURE_THE_FLAG_ABI, wallet);
        // console.log("*AC GOT captureTheFlag: ", captureTheFlag)

        const manager = await getManager();
        const managerAddress = await manager.getAddress();

        // Manually setting the gas limit (use with caution)
        const gasLimit = toBigInt("1000000"); // Example value

        // console.log("*AC got manager: ", managerAddress);

        const { metadataHash } = await loadPluginDetails(TOKET_PLUGIN_ADDRESS)
        console.log("*AC metadataHash: ", metadataHash);

        const safeTx = buildSingleTx(
            CAPTURE_THE_FLAG_ADDRESS, 
            BigInt(0), 
            (await captureTheFlag.captureTheFlag.populateTransaction()).data, 
            BigInt(19), 
            metadataHash
        );
        console.log("*AC safeTx: ", safeTx);

        // Dummy SafeTransaction
        // const dummySafeTx = {
        //     actions: [
        //         {
        //             to: CAPTURE_THE_FLAG_ADDRESS,
        //             value: parseEther("0.0"),
        //             data: (
        //                 await captureTheFlag.captureTheFlag.populateTransaction()
        //             ).data
        //         },
        //         {

        //         }
        //     ],
        //     nonce: 18,
        //     metadataHash: ZeroHash
        // };
        
        // I THINK THE ERROR IS HERE
        // Use a replacer function to handle BigInt
        let hexSafeTx = toUtf8Bytes(JSON.stringify(safeTx, (key, value) =>
            typeof value === 'bigint' ? value.toString() : value // Convert BigInt to string
        ));
        console.log("*AC hexSafeTx: ", hexSafeTx);


        // if (1 === 1) {
        //     return {}
        // }
        
        const response = await plugin.executeFromPlugin.populateTransaction(
            managerAddress, 
            safeAddress, 
            safeTx,
            { gasLimit }
        );

        console.log("*AC response: ", response);
        return response;
    } catch (e) {
        console.error(e);
        return "";
    }
};

export interface SafeProtocolAction {
    to: AddressLike;
    value: bigint;
    data: string;
}

export interface SafeTransaction {
    actions: SafeProtocolAction[];
    nonce: bigint;
    metadataHash: Uint8Array | string;
}

export interface SafeRootAccess {
    action: SafeProtocolAction;
    nonce: bigint;
    metadataHash: Uint8Array | string;
}


export const buildSingleTx = (address: AddressLike, value: bigint, data: string, nonce: bigint, metadataHash: Uint8Array | string): SafeTransaction => {
    return {
        actions: [
            {
                to: address,
                value: value,
                data: data,
            },
        ],
        nonce: nonce,
        metadataHash: metadataHash,
    };
};

export const buildRootTx = (address: AddressLike, value: bigint, data: string, nonce: bigint, metadataHash: Uint8Array | string): SafeRootAccess => {
    return {
        action: {
            to: address,
            value: value,
            data: data,
        },
        nonce: nonce,
        metadataHash: metadataHash,
    };
};