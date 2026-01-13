// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../access/Roles.sol";

/**
 * @title TimelockController
 * @author CryptoVentures DAO
 * @notice Enforces time-delayed execution of approved governance proposals
 */
contract TimelockController {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error NotAuthorized();
    error ProposalNotQueued();
    error TimelockNotExpired();
    error ProposalAlreadyExecuted();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event ProposalQueued(uint256 indexed proposalId, uint256 executeAfter);
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/

    Roles public immutable roles;

    struct TimelockInfo {
        uint256 executeAfter;
        bool executed;
        bool cancelled;
    }

    mapping(uint256 => TimelockInfo) private _timelock;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address rolesAddress) {
        roles = Roles(rolesAddress);
    }

    /*//////////////////////////////////////////////////////////////
                          TIMELOCK LOGIC
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Queue a proposal for delayed execution
     * @param proposalId Proposal ID
     * @param delay Timelock delay in seconds
     */
    function queueProposal(
        uint256 proposalId,
        uint256 delay
    ) external {
        if (!roles.hasRole(roles.EXECUTOR_ROLE(), msg.sender)) {
            revert NotAuthorized();
        }

        _timelock[proposalId] = TimelockInfo({
            executeAfter: block.timestamp + delay,
            executed: false,
            cancelled: false
        });

        emit ProposalQueued(proposalId, block.timestamp + delay);
    }

    /**
     * @notice Execute a queued proposal after timelock expires
     * @param proposalId Proposal ID
     */
    function executeProposal(uint256 proposalId) external {
        if (!roles.hasRole(roles.EXECUTOR_ROLE(), msg.sender)) {
            revert NotAuthorized();
        }

        TimelockInfo storage info = _timelock[proposalId];

        if (info.executeAfter == 0 || info.cancelled) {
            revert ProposalNotQueued();
        }

        if (info.executed) revert ProposalAlreadyExecuted();
        if (block.timestamp < info.executeAfter) {
            revert TimelockNotExpired();
        }

        info.executed = true;

        emit ProposalExecuted(proposalId);
    }

    /**
     * @notice Cancel a queued proposal during timelock
     * @param proposalId Proposal ID
     */
    function cancelProposal(uint256 proposalId) external {
        if (!roles.hasRole(roles.GUARDIAN_ROLE(), msg.sender)) {
            revert NotAuthorized();
        }

        TimelockInfo storage info = _timelock[proposalId];

        if (info.executeAfter == 0 || info.executed) {
            revert ProposalNotQueued();
        }

        info.cancelled = true;

        emit ProposalCancelled(proposalId);
    }

    /*//////////////////////////////////////////////////////////////
                          VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function getTimelock(
        uint256 proposalId
    ) external view returns (uint256 executeAfter, bool executed, bool cancelled) {
        TimelockInfo memory info = _timelock[proposalId];
        return (info.executeAfter, info.executed, info.cancelled);
    }
}
