// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;
import {ISafe} from "@safe-global/safe-core-protocol/contracts/interfaces/Accounts.sol";
import {ISafeProtocolPlugin} from "@safe-global/safe-core-protocol/contracts/interfaces/Integrations.sol";
import {ISafeProtocolManager} from "@safe-global/safe-core-protocol/contracts/interfaces/Manager.sol";
import {SafeTransaction, SafeRootAccess, SafeProtocolAction} from "@safe-global/safe-core-protocol/contracts/DataTypes.sol";
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
contract WhitelistPlugin is BasePluginWithEventMetadata {
    // Mapping of safe account => (API key account => permitted destination address)
    mapping(address => mapping(address => address)) public permittedDestinations;

    event ApiKeyAccountAdded(address indexed safe, address indexed apiKeyAccount, address destination);
    event ApiKeyAccountRemoved(address indexed safe, address indexed apiKeyAccount);

    error ApiKeyAlreadyUsed(address apiKeyAccount, address existingDestination);
    error UnauthorizedApiKeyAccount(address apiKeyAccount, address destination);
    error CallerIsNotOwner(address safe, address caller);

    constructor()
        BasePluginWithEventMetadata(
            PluginMetadata({name: "Api Key Accounts Plugin", version: "1.0.1", requiresRootAccess: false, iconUrl: "", appUrl: ""})
        )
    {}

    /**
     * @notice Sets the permitted destination for a specific API key account.
     *         Requires that any existing destination is first removed.
     * @param safe Safe account
     * @param apiKeyAccount The API key account
     * @param destination The address that the API key account is permitted to execute transactions to
     */
    function setPermittedDestination(address safe, address apiKeyAccount, address destination) external {
        if (!(OwnerManager(safe).isOwner(msg.sender))) {
            revert CallerIsNotOwner(safe, msg.sender);
        }

        address existingDestination = permittedDestinations[safe][apiKeyAccount];
        if (existingDestination != address(0)) {
            revert ApiKeyAlreadyUsed(apiKeyAccount, existingDestination);
        }

        permittedDestinations[safe][apiKeyAccount] = destination;
        emit ApiKeyAccountAdded(safe, apiKeyAccount, destination);
    }

    /**
     * @notice Removes the permitted destination for a specific API key account.
     * @param safe Safe account
     * @param apiKeyAccount The API key account
     */
    function removePermittedDestination(address safe, address apiKeyAccount) external {
        if (!(OwnerManager(safe).isOwner(msg.sender))) {
            revert CallerIsNotOwner(safe, msg.sender);
        }
        delete permittedDestinations[safe][apiKeyAccount];
        emit ApiKeyAccountRemoved(safe, apiKeyAccount);
    }

    /**
     * @notice Executes a Safe transaction if the API key account is permitted for the destination.
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
        SafeProtocolAction[] memory actions = safetx.actions;
        uint256 length = actions.length;

        for (uint256 i = 0; i < length; i++) {
            address destination = permittedDestinations[safeAddress][msg.sender];
            if (destination == address(0) || actions[i].to != destination) {
                revert UnauthorizedApiKeyAccount(msg.sender, actions[i].to);
            }
        }

        (data) = manager.executeTransaction(safe, safetx);
    }
}
