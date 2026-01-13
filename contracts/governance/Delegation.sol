// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Delegation
 * @author CryptoVentures DAO
 * @notice Handles delegation of voting power for governance
 * @dev Delegation is one-level only and must be enforced before voting by GovernanceDAO
 */
contract Delegation {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error InvalidDelegate();
    error CircularDelegation();
    error NoDelegationToRevoke();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event Delegated(address indexed delegator, address indexed delegatee);
    event DelegationRevoked(address indexed delegator);

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/

    // delegator => delegatee
    mapping(address => address) private _delegation;

    // delegatee => total number of delegators (for tracking)
    mapping(address => uint256) private _delegatedToCount;

    /*//////////////////////////////////////////////////////////////
                          DELEGATION LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Delegate voting power to another address
     * @param to Address to delegate voting power to
     */
    function delegate(address to) external {
        if (to == address(0) || to == msg.sender) revert InvalidDelegate();

        // Prevent circular delegation (A -> B where B already delegates to A)
        if (_delegation[to] == msg.sender) revert CircularDelegation();

        // Remove previous delegation if exists
        address previousDelegate = _delegation[msg.sender];
        if (previousDelegate != address(0)) {
            _delegatedToCount[previousDelegate]--;
        }

        _delegation[msg.sender] = to;
        _delegatedToCount[to]++;

        emit Delegated(msg.sender, to);
    }

    /**
     * @notice Revoke existing delegation
     */
    function revokeDelegation() external {
        address delegatee = _delegation[msg.sender];
        if (delegatee == address(0)) revert NoDelegationToRevoke();

        _delegation[msg.sender] = address(0);
        _delegatedToCount[delegatee]--;

        emit DelegationRevoked(msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                          VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns the delegatee for a given delegator
     */
    function delegatedTo(address delegator) external view returns (address) {
        return _delegation[delegator];
    }

    /**
     * @notice Returns how many users delegated to an address
     */
    function delegationCount(address delegatee) external view returns (uint256) {
        return _delegatedToCount[delegatee];
    }
}
