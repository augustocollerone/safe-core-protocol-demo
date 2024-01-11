import { ethers, getAddress } from "ethers"
import { getProvider } from "./web3";
import { submitTxs } from "./safeapp";

const SAMPLE_PLUGIN_CHAIN_ID = 5
export const SAMPLE_PLUGIN_ADDRESS = getAddress("0x72F73a7Ed4b470c383008685485f79d3Aed5ABca") // Whitelist Plugin
const SAMPLE_PLUGIN_ABI = [
    "function addToWhitelist(address account) external",
    "function removeFromWhitelist(address account) external",
    "function executeFromPlugin(address manager, address safe, bytes calldata data) external",
    "function whitelistedAddresses(address, address) view returns (bool)"
]


export const isKnownSamplePlugin = (chainId: number, address: string): boolean => 
    ethers.toBigInt(chainId) == ethers.toBigInt(SAMPLE_PLUGIN_CHAIN_ID) &&
    getAddress(address) === SAMPLE_PLUGIN_ADDRESS  

const getWhitelistPlugin = async() => {
    const provider = await getProvider()
    return new ethers.Contract(
        SAMPLE_PLUGIN_ADDRESS,
        SAMPLE_PLUGIN_ABI,
        provider
    )
    
  }
export const checkWhitelist = async(safeAddress: string, account: string): Promise<boolean> => {
    try {
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