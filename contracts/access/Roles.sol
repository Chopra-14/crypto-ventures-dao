// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";


/**
 * @title Roles
 * @author CryptoVentures DAO
 * @notice Centralized role definitions for DAO governance system
 * @dev Uses OpenZeppelin AccessControl for role-based permissions
 */
contract Roles is AccessControl {
    /*//////////////////////////////////////////////////////////////
                                ROLES
    //////////////////////////////////////////////////////////////*/

    /// @notice Role allowed to create proposals
    bytes32 public constant PROPOSER_ROLE = keccak256("PROPOSER_ROLE");

    /// @notice Role allowed to execute queued proposals
    bytes32 public constant EXECUTOR_ROLE = keccak256("EXECUTOR_ROLE");

    /// @notice Role allowed to cancel malicious or risky proposals
    bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");

    /// @notice Role allowed to pause the system in emergencies
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Grants DEFAULT_ADMIN_ROLE to the deployer
     * @param admin Address that will control role assignments
     */
    constructor(address admin) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }
}
