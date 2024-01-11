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
import { isKnownSamplePlugin } from "../../../logic/sample";
import {
  checkWhitelist,
  addToWhitelist,
  removeFromWhitelist,
} from "../../../logic/sampleWhitelist";
import { getSafeInfo, isConnectedToSafe } from "../../../logic/safeapp";
import { SafeInfo } from "@safe-global/safe-apps-sdk";

export const WhitelistPlugin: FunctionComponent<{}> = () => {
  const { pluginAddress } = useParams();
  const [newApiKeyAddress, setNewApiKeyAddress] = useState<string>("");
  const [checkStatus, setCheckStatus] = useState<boolean | undefined>(
    undefined
  );
  const [safeInfo, setSafeInfo] = useState<SafeInfo | undefined>(undefined);
  console.log({ pluginAddress });

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

  // MARK: Fetch current whitelist
  useEffect(() => {
    if (safeInfo === undefined) return;
    const fetchData = async () => {
      try {
        const whitelistedAddress = await checkWhitelist(
          safeInfo.safeAddress,
          ""
        );
        console.log("*AC WHITELISTED", whitelistedAddress);
      } catch (e) {
        console.error("*AC WHITELISTED", e);
      }
    };
    fetchData();
  }, [safeInfo, pluginAddress]);

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

  const isLoading = safeInfo === undefined;

  return (
    <div className="Sample">
      <Card className="Settings">
        {isLoading && <CircularProgress />}

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
    </div>
  );
};
