// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;
import {ISafe} from "@safe-global/safe-core-protocol/contracts/interfaces/Accounts.sol";
import {ISafeProtocolManager} from "@safe-global/safe-core-protocol/contracts/interfaces/Manager.sol";
import {SafeTransaction, SafeProtocolAction} from "@safe-global/safe-core-protocol/contracts/DataTypes.sol";
import {BasePluginWithEventMetadata, PluginMetadata} from "./Base.sol";

/**
 * @title OwnerManager
 * @dev This interface is defined for use in WhitelistPlugin contract.
 */
interface OwnerManager {
    function isOwner(address owner) external view returns (bool);
}

/**
 * @title WhitelistPlugin maintains a mapping that stores information about accounts that are
 *        permitted to execute non-root transactions through a Safe account.
 * @notice This plugin does not need Safe owner(s) confirmation(s) to execute Safe txs once enabled
 *         through a Safe{Core} Protocol Manager.
 */
contract TuviPlugin is BasePluginWithEventMetadata {
    // safe account => account => whitelist status
    mapping(address => mapping(address => mapping(address => bool))) public whitelistedAddresses;

    event ApiKeyAdded(address indexed account, address indexed recipient);
    event ApiKeyRemoved(address indexed account, address indexed recipient);

    error AddressNotWhiteListed(address recipient);
    error ApiKeyIsNotRegistered(address safe, address caller);

    constructor()
        BasePluginWithEventMetadata(
            PluginMetadata({name: "TuVi Plugin", version: "1.0.0", requiresRootAccess: false, iconUrl: "https://www.packaging2buy.co.uk/images/detailed/2/sustainable-loop-boxes1.jpg", appUrl: "https://augustocollerone.github.io/safe-core-protocol-demo/"})
        )
    {}

    /**
     * @notice Executes a Safe transaction if the caller is whitelisted for the given Safe account.
     * @param manager Address of the Safe{Core} Protocol Manager.
     * @param safe Safe account
     * @param safetx SafeTransaction to be executed
     */
    function executeFromPlugin(
        ISafeProtocolManager manager,
        ISafe safe,
        SafeTransaction calldata safetx
    ) external returns (bytes[] memory data) {
        address safeAddress = address(safe);

        // // Only whitelisted API keys can execute transactions
        // if (!whitelistedAddresses[safeAddress][msg.sender]) revert ApiKeyIsNotRegistered(safeAddress, msg.sender);

        SafeProtocolAction[] memory actions = safetx.actions;
        uint256 length = actions.length;
        for (uint256 i = 0; i < length; i++) {
            if (!whitelistedAddresses[safeAddress][msg.sender][actions[i].to]) revert AddressNotWhiteListed(actions[i].to);
        }
        // Test: Any tx that updates whitelist of this contract should be blocked
        (data) = manager.executeTransaction(safe, safetx);
    }

    /**
     * @notice Adds an account to whitelist mapping.
     *         The caller should be a Safe account.
     * @param account address of the account to be whitelisted
     */
    function addApiKeyAccount(address account, address recipient) external {
        whitelistedAddresses[msg.sender][account][recipient] = true;
        emit ApiKeyAdded(account, recipient);
    }

    /**
     * @notice Removes an account from whitelist mapping.
     *         The caller should be a Safe account.
     * @param account address of the account to be removed from the whitelist
     */
    function removeApiKeyAccount(address account, address recipient) external {
        whitelistedAddresses[msg.sender][account][recipient] = false;
        emit ApiKeyRemoved(account, recipient);
    }
}