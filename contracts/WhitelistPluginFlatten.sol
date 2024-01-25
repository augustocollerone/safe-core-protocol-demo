// Sources flattened with hardhat v2.17.2 https://hardhat.org

// SPDX-License-Identifier: LGPL-3.0-only AND MIT

// File @openzeppelin/contracts/utils/introspection/IERC165.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @safe-global/safe-core-protocol/contracts/DataTypes.sol@v0.2.0-alpha.1

// Original license: SPDX_License_Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;

struct SafeProtocolAction {
    address payable to;
    uint256 value;
    bytes data;
}

struct SafeTransaction {
    SafeProtocolAction[] actions;
    uint256 nonce;
    bytes32 metadataHash;
}

struct SafeRootAccess {
    SafeProtocolAction action;
    uint256 nonce;
    bytes32 metadataHash;
}


// File @safe-global/safe-core-protocol/contracts/interfaces/Accounts.sol@v0.2.0-alpha.1

// Original license: SPDX_License_Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;

/**
 * @title ISafe Declares the functions that are called on a Safe by Safe{Core} Protocol.
 */
interface ISafe {
    function execTransactionFromModule(
        address payable to,
        uint256 value,
        bytes calldata data,
        uint8 operation
    ) external returns (bool success);

    function execTransactionFromModuleReturnData(
        address to,
        uint256 value,
        bytes memory data,
        uint8 operation
    ) external returns (bool success, bytes memory returnData);
}


// File @safe-global/safe-core-protocol/contracts/interfaces/Integrations.sol@v0.2.0-alpha.1

// Original license: SPDX_License_Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;



/**
 * @title ISafeProtocolFunctionHandler - An interface that a Safe function handler should implement to handle static calls.
 * @notice In Safe{Core} Protocol, a function handler can be used to add additional functionality to a Safe.
 *         User(s) should add SafeProtocolManager as a function handler (aka fallback handler in Safe v1.x) to the Safe
 *         and enable the contract implementing ISafeProtocolFunctionHandler interface as a function handler in the
 *         SafeProtocolManager for the specific function identifier.
 */
interface ISafeProtocolFunctionHandler is IERC165 {
    /**
     * @notice Handles calls to the Safe contract forwarded by the fallback function.
     * @param safe A Safe instance
     * @param sender Address of the sender
     * @param value Amount of ETH
     * @param data Arbitrary length bytes
     * @return result Arbitrary length bytes containing result of the operation
     */
    function handle(ISafe safe, address sender, uint256 value, bytes calldata data) external returns (bytes memory result);

    /**
     * @notice A function that returns information about the type of metadata provider and its location.
     *         For more information on metadata provider, refer to https://github.com/safe-global/safe-core-protocol-specs/.
     * @return providerType uint256 Type of metadata provider
     * @return location bytes
     */
    function metadataProvider() external view returns (uint256 providerType, bytes memory location);
}

/**
 * @title ISafeProtocolStaticFunctionHandler - An interface that a Safe functionhandler should implement in case when handling static calls
 * @notice In Safe{Core} Protocol, a function handler can be used to add additional functionality to a Safe.
 *         User(s) should add SafeProtocolManager as a function handler (aka fallback handler in Safe v1.x) to the Safe
 *         and enable the contract implementing ISafeProtocolStaticFunctionHandler interface as a function handler in the
 *         SafeProtocolManager for the specific function identifier.
 */
interface ISafeProtocolStaticFunctionHandler is IERC165 {
    /**
     * @notice Handles static calls to the Safe contract forwarded by the fallback function.
     * @param safe A Safe instance
     * @param sender Address of the sender
     * @param value Amount of ETH
     * @param data Arbitrary length bytes
     * @return result Arbitrary length bytes containing result of the operation
     */
    function handle(ISafe safe, address sender, uint256 value, bytes calldata data) external view returns (bytes memory result);

    /**
     * @notice A function that returns information about the type of metadata provider and its location.
     *         For more information on metadata provider, refer to https://github.com/safe-global/safe-core-protocol-specs/.
     * @return providerType uint256 Type of metadata provider
     * @return location bytes
     */
    function metadataProvider() external view returns (uint256 providerType, bytes memory location);
}

/**
 * @title ISafeProtocolHooks - An interface that a contract should implement to be enabled as hooks.
 * @notice In Safe{Core} Protocol, hooks can approve or deny transactions based on the logic it implements.
 */
interface ISafeProtocolHooks is IERC165 {
    /**
     * @notice A function that will be called by a Safe before the execution of a transaction if the hooks are enabled
     * @dev Add custom logic in this function to validate the pre-state and contents of transaction for non-root access.
     * @param safe A Safe instance
     * @param tx A struct of type SafeTransaction that contains the details of the transaction.
     * @param executionType uint256
     * @param executionMeta Arbitrary length of bytes
     * @return preCheckData bytes
     */
    function preCheck(
        ISafe safe,
        SafeTransaction calldata tx,
        uint256 executionType,
        bytes calldata executionMeta
    ) external returns (bytes memory preCheckData);

    /**
     * @notice A function that will be called by a safe before the execution of a transaction if the hooks are enabled and
     *         transaction requies tool access.
     * @dev Add custom logic in this function to validate the pre-state and contents of transaction for root access.
     * @param safe A Safe instance
     * @param rootAccess DataTypes.SafeRootAccess
     * @param executionType uint256
     * @param executionMeta bytes
     * @return preCheckData bytes
     */
    function preCheckRootAccess(
        ISafe safe,
        SafeRootAccess calldata rootAccess,
        uint256 executionType,
        bytes calldata executionMeta
    ) external returns (bytes memory preCheckData);

    /**
     * @notice A function that will be called by a safe after the execution of a transaction if the hooks are enabled. Hooks should revert if the post state of after the transaction is not as expected.
     * @dev Add custom logic in this function to validate the post-state after the transaction is executed.
     * @param safe ISafe
     * @param success bool
     * @param preCheckData Arbitrary length bytes that was returned by during pre-check of the transaction.
     */
    function postCheck(ISafe safe, bool success, bytes calldata preCheckData) external;
}

/**
 * @title ISafeProtocolPlugin - An interface that a Safe plugin should implement
 */
interface ISafeProtocolPlugin is IERC165 {
    /**
     * @notice A funtion that returns name of the plugin
     * @return name string name of the plugin
     */
    function name() external view returns (string memory name);

    /**
     * @notice A function that returns version of the plugin
     * @return version string version of the plugin
     */
    function version() external view returns (string memory version);

    /**
     * @notice A function that returns information about the type of metadata provider and its location.
     *         For more information on metadata provider, refer to https://github.com/safe-global/safe-core-protocol-specs/.
     * @return providerType uint256 Type of metadata provider
     * @return location bytes
     */
    function metadataProvider() external view returns (uint256 providerType, bytes memory location);

    /**
     * @notice A function that indicates if the plugin requires root access to a Safe.
     * @return requiresRootAccess True if root access is required, false otherwise.
     */
    function requiresRootAccess() external view returns (bool requiresRootAccess);
}


// File @safe-global/safe-core-protocol/contracts/interfaces/Manager.sol@v0.2.0-alpha.1

// Original license: SPDX_License_Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;


/**
 * @title ISafeProtocolManager interface a Manager should implement
 * @notice A mediator checks the status of the integration through the registry and allows only
 *         listed and non-flagged integrations to execute transactions. A Safe account should
 *         add a mediator as a plugin.
 */
interface ISafeProtocolManager {
    /**
     * @notice This function allows enabled plugins to execute non-delegate call transactions thorugh a Safe.
     *         It should validate the status of the plugin through the registry and allows only listed and non-flagged integrations to execute transactions.
     * @param safe Address of a Safe account
     * @param transaction SafeTransaction instance containing payload information about the transaction
     * @return data Array of bytes types returned upon the successful execution of all the actions. The size of the array will be the same as the size of the actions
     *         in case of succcessful execution. Empty if the call failed.
     */
    function executeTransaction(ISafe safe, SafeTransaction calldata transaction) external returns (bytes[] memory data);

    /**
     * @notice This function allows enabled plugins to execute delegate call transactions thorugh a Safe.
     *         It should validate the status of the plugin through the registry and allows only listed and non-flagged integrations to execute transactions.
     * @param safe Address of a Safe account
     * @param rootAccess SafeTransaction instance containing payload information about the transaction
     * @return data Arbitrary length bytes data returned upon the successful execution. The size of the array will be the same as the size of the actions
     *         in case of succcessful execution. Empty if the call failed.
     */
    function executeRootAccess(ISafe safe, SafeRootAccess calldata rootAccess) external returns (bytes memory data);
}


// File contracts/Base.sol

// Original license: SPDX_License_Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;


enum MetadataProviderType {
    IPFS,
    URL,
    Contract,
    Event
}

interface IMetadataProvider {
    function retrieveMetadata(bytes32 metadataHash) external view returns (bytes memory metadata);
}

struct PluginMetadata {
    string name;
    string version;
    bool requiresRootAccess;
    string iconUrl;
    string appUrl;
}

library PluginMetadataOps {
    function encode(PluginMetadata memory data) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                uint8(0x00), // Format
                uint8(0x00), // Format version
                abi.encode(data.name, data.version, data.requiresRootAccess, data.iconUrl, data.appUrl) // Plugin Metadata
            );
    }

    function decode(bytes calldata data) internal pure returns (PluginMetadata memory) {
        require(bytes16(data[0:2]) == bytes16(0x0000), "Unsupported format or format version");
        (string memory name, string memory version, bool requiresRootAccess, string memory iconUrl, string memory appUrl) = abi.decode(
            data[2:],
            (string, string, bool, string, string)
        );
        return PluginMetadata(name, version, requiresRootAccess, iconUrl, appUrl);
    }
}

abstract contract BasePlugin is ISafeProtocolPlugin {
    using PluginMetadataOps for PluginMetadata;

    string public name;
    string public version;
    bool public immutable requiresRootAccess;
    bytes32 public immutable metadataHash;

    constructor(PluginMetadata memory metadata) {
        name = metadata.name;
        version = metadata.version;
        requiresRootAccess = metadata.requiresRootAccess;
        metadataHash = keccak256(metadata.encode());
    }

    function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
        return interfaceId == type(ISafeProtocolPlugin).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
}

abstract contract BasePluginWithStoredMetadata is BasePlugin, IMetadataProvider {
    using PluginMetadataOps for PluginMetadata;

    bytes private encodedMetadata;

    constructor(PluginMetadata memory metadata) BasePlugin(metadata) {
        encodedMetadata = metadata.encode();
    }

    function retrieveMetadata(bytes32 _metadataHash) external view override returns (bytes memory metadata) {
        require(metadataHash == _metadataHash, "Cannot retrieve metadata");
        return encodedMetadata;
    }

    function metadataProvider() public view override returns (uint256 providerType, bytes memory location) {
        providerType = uint256(MetadataProviderType.Contract);
        location = abi.encode(address(this));
    }
}

abstract contract BasePluginWithEventMetadata is BasePlugin {
    using PluginMetadataOps for PluginMetadata;

    event Metadata(bytes32 indexed metadataHash, bytes data);

    constructor(PluginMetadata memory metadata) BasePlugin(metadata) {
        emit Metadata(metadataHash, metadata.encode());
    }

    function metadataProvider() public view override returns (uint256 providerType, bytes memory location) {
        providerType = uint256(MetadataProviderType.Event);
        location = abi.encode(address(this));
    }
}


// File contracts/WhitelistPlugin.sol

// Original license: SPDX_License_Identifier: LGPL-3.0-only
pragma solidity ^0.8.18;





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
