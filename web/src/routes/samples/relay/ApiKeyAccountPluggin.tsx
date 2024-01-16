import { FunctionComponent, useCallback, useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import "./Relay.css";
import {
  CircularProgress,
  TextField,
  Button,
  Typography,
  Card,
} from "@mui/material";
import { isKnownSamplePlugin } from "../../../logic/sampleWhitelist";
import {
  checkWhitelist,
  addToWhitelist,
  removeFromWhitelist,
  whitelistTx,
} from "../../../logic/sampleWhitelist";
import { getSafeInfo, isConnectedToSafe } from "../../../logic/safeapp";
import { SafeInfo } from "@safe-global/safe-apps-sdk";
import { SafeMultisigTransaction } from "../../../logic/services";
import { NextTxsList } from "./NextTxs";
import { buildExecuteTx } from "../../../logic/safe";
import { PluginDetails, loadPluginDetails } from "../../../logic/plugins";

export const WhitelistPlugin: FunctionComponent<{}> = () => {
  const { pluginAddress } = useParams();
  const [newApiKeyAddress, setNewApiKeyAddress] = useState<string>("");
  const [checkStatus, setCheckStatus] = useState<boolean | undefined>(
    undefined
  );
  const [safeInfo, setSafeInfo] = useState<SafeInfo | undefined>(undefined);
  const [pluginDetails, setPluginDetails] = useState<PluginDetails | undefined>(
    undefined
  );

  // MARK: Fetch SAFE Info
  useEffect(() => {
    const fetchData = async () => {
      try {
        if (!(await isConnectedToSafe())) throw Error("Not connected to Safe");
        const info = await getSafeInfo();
        console.log("SAFE INFO", info);
        if (!isKnownSamplePlugin(info.chainId, pluginAddress!!))
          throw Error("Unknown Plugin");
        setSafeInfo(info);
      } catch (e) {
        console.error(e);
      }
    };
    fetchData();
  }, [pluginAddress]);
  // MARK: Fetch Plugin Details
  useEffect(() => {
    const fetchData = async () => {
      try {
        if (!pluginAddress) throw Error("No plugin address");
        const details = await loadPluginDetails(pluginAddress);
        setPluginDetails(details);
      } catch (e) {
        console.error(e);
      }
    };
    fetchData();
  }, [pluginAddress]);

  const handleCheckWhitelist = useCallback(
    async (account: string) => {
      setCheckStatus(undefined);
      if (safeInfo === undefined) return;
      const result = await checkWhitelist(safeInfo.safeAddress, account);
      setCheckStatus(result);
    },
    [safeInfo]
  );

  const handleAddToWhitelist = useCallback(async (account: string) => {
    console.log("*AC handleAddToWhitelist: ", account);
    await addToWhitelist(account);
  }, []);

  const handleRemoveFromWhitelist = useCallback(async (account: string) => {
    console.log("*AC handleRemoveFromWhitelist: ", account);
    await removeFromWhitelist(account);
  }, []);

  const handleRelay = useCallback(
    async (txToRelay: SafeMultisigTransaction) => {
      if (txToRelay === undefined || !safeInfo) return;

      try {
        const { to: account, data } = await buildExecuteTx(txToRelay);
        // TODO: remove fallback to native fee token and enforce that token is selected
        // const txId = await whitelistTx(safeInfo.safeAddress, account, data);
        // console.log({ txId });
      } catch (e) {
        console.error(e);
      }
    },
    [safeInfo]
  );

  const isLoading = safeInfo === undefined;

  return (
    <div className="Sample">
      <Card className="Settings">
        {isLoading && <CircularProgress />}

        <p>{pluginAddress}</p>

        {pluginDetails && (
          <>
            <Typography variant="body1">
              Name: {pluginDetails.metadata.name}
            </Typography>
            <Typography variant="body1">
              Version: {pluginDetails.metadata.version}
            </Typography>
          </>
        )}

        <Button
          onClick={() =>
            window.open(
              `https://goerli.etherscan.io/address/${pluginAddress}`,
              "_blank"
            )
          }
        >
          See in Etherscan
        </Button>
      </Card>

      <Card className="Settings">
        {safeInfo !== undefined && (
          <>
            <Typography variant="body1">
              ADD to whitelist:
              <br />
              <TextField
                id="standard-basic"
                label={`Account address`}
                variant="standard"
                value={newApiKeyAddress}
                onChange={(event) => setNewApiKeyAddress(event.target.value)}
              />
            </Typography>
            <Button
              disabled={newApiKeyAddress === ""}
              onClick={() => handleAddToWhitelist(newApiKeyAddress)}
            >
              ADD
            </Button>
          </>
        )}
      </Card>
      <Card className="Settings">
        {isLoading && <CircularProgress />}

        {safeInfo !== undefined && (
          <>
            <Typography variant="body1">
              REMOVE from whitelist:
              <br />
              <TextField
                id="standard-basic"
                label={`Account address`}
                variant="standard"
                value={newApiKeyAddress}
                onChange={(event) => setNewApiKeyAddress(event.target.value)}
              />
            </Typography>
            <Button
              disabled={newApiKeyAddress === ""}
              onClick={() => handleRemoveFromWhitelist(newApiKeyAddress)}
            >
              REMOVE
            </Button>
          </>
        )}
      </Card>
      <Card className="Settings">
        {isLoading && <CircularProgress />}

        {safeInfo !== undefined && (
          <>
            <Typography variant="body1">
              Check whitelist status:
              <br />
              <TextField
                id="standard-basic"
                label={`Account address`}
                variant="standard"
                value={newApiKeyAddress}
                onChange={(event) => setNewApiKeyAddress(event.target.value)}
              />
            </Typography>
            <Button
              disabled={newApiKeyAddress === ""}
              onClick={() => handleCheckWhitelist(newApiKeyAddress)}
            >
              Check
            </Button>

            <p>
              {" "}
              Whitelisted:{" "}
              {checkStatus !== undefined ? checkStatus.toString() : "-"}
            </p>
          </>
        )}
      </Card>

      <Card className="Settings">
        {isLoading && <CircularProgress />}

        {safeInfo !== undefined && (
          <>
            <Typography variant="body1">Execute DEMO</Typography>
            <Button onClick={() => whitelistTx(safeInfo.safeAddress)}>
              EXECUTE
            </Button>
          </>
        )}
      </Card>

      {safeInfo && (
        <NextTxsList safeInfo={safeInfo} handleRelay={handleRelay} />
      )}
    </div>
  );
};
