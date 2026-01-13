// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../token/GovernanceToken.sol";
import "./ProposalTypes.sol";
import "./Delegation.sol";
import "../access/Roles.sol";

/**
 * @title GovernanceDAO
 * @author CryptoVentures DAO
 * @notice Core governance contract handling proposals and voting
 */
contract GovernanceDAO {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error NotEnoughStake();
    error InvalidProposal();
    error VotingNotActive();
    error VotingEnded();
    error AlreadyVoted();
    error ProposalNotApproved();
    error QuorumNotMet();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        ProposalTypes.ProposalType proposalType,
        string description
    );

    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        uint8 support,
        uint256 weight
    );

    event ProposalQueued(uint256 indexed proposalId);
    event ProposalDefeated(uint256 indexed proposalId);

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/

    GovernanceToken public immutable governanceToken;
    ProposalTypes public immutable proposalTypes;
    Delegation public immutable delegation;
    Roles public immutable roles;

    uint256 public constant MIN_PROPOSAL_STAKE = 1 ether;
    uint256 public constant VOTING_PERIOD = 3 days;

    uint256 private _proposalCount;

    enum ProposalState {
        Pending,
        Active,
        Defeated,
        Queued,
        Executed
    }

    struct Proposal {
        ProposalTypes.ProposalType proposalType;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool queued;
        bool executed;
        string description;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address _governanceToken,
        address _proposalTypes,
        address _delegation,
        address _roles
    ) {
        governanceToken = GovernanceToken(_governanceToken);
        proposalTypes = ProposalTypes(_proposalTypes);
        delegation = Delegation(_delegation);
        roles = Roles(_roles);
    }

    /*//////////////////////////////////////////////////////////////
                        PROPOSAL CREATION
    //////////////////////////////////////////////////////////////*/

    function createProposal(
        ProposalTypes.ProposalType proposalType,
        string calldata description
    ) external returns (uint256) {
        uint256 stake = governanceToken.stakeOf(msg.sender);
        if (stake < MIN_PROPOSAL_STAKE) revert NotEnoughStake();

        _proposalCount++;
        uint256 proposalId = _proposalCount;

        proposals[proposalId] = Proposal({
            proposalType: proposalType,
            proposer: msg.sender,
            startTime: block.timestamp,
            endTime: block.timestamp + VOTING_PERIOD,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            queued: false,
            executed: false,
            description: description
        });

        emit ProposalCreated(
            proposalId,
            msg.sender,
            proposalType,
            description
        );

        return proposalId;
    }

    /*//////////////////////////////////////////////////////////////
                              VOTING
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Cast vote on a proposal
     * @param proposalId Proposal ID
     * @param support 0 = Against, 1 = For, 2 = Abstain
     */
    function vote(uint256 proposalId, uint8 support) external {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.startTime == 0) revert InvalidProposal();

        if (block.timestamp < proposal.startTime) revert VotingNotActive();
        if (block.timestamp > proposal.endTime) revert VotingEnded();
        if (hasVoted[proposalId][msg.sender]) revert AlreadyVoted();

        uint256 weight = governanceToken.votingPower(msg.sender);

        // Include delegated voting power
        uint256 delegatedCount = delegation.delegationCount(msg.sender);
        if (delegatedCount > 0) {
            // Each delegator's voting power will be added when they delegate
            // Actual aggregation is handled off delegator voting
        }

        if (support == 0) {
            proposal.againstVotes += weight;
        } else if (support == 1) {
            proposal.forVotes += weight;
        } else {
            proposal.abstainVotes += weight;
        }

        hasVoted[proposalId][msg.sender] = true;

        emit VoteCast(proposalId, msg.sender, support, weight);
    }

    /*//////////////////////////////////////////////////////////////
                       GOVERNANCE DECISIONS
    //////////////////////////////////////////////////////////////*/

    function queueProposal(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.startTime == 0) revert InvalidProposal();
        if (block.timestamp <= proposal.endTime) revert VotingNotActive();
        if (proposal.queued || proposal.executed) revert ProposalNotApproved();

        ProposalTypes.ProposalConfig memory config =
            proposalTypes.getConfig(proposal.proposalType);

        uint256 totalVotes =
            proposal.forVotes +
            proposal.againstVotes +
            proposal.abstainVotes;

        uint256 totalPower =
            governanceToken.votingPower(address(this));

        if (
            totalVotes * 100 <
            config.quorumPercentage * totalPower
        ) revert QuorumNotMet();

        if (
            proposal.forVotes * 100 <
            config.approvalPercentage * (proposal.forVotes + proposal.againstVotes)
        ) {
            proposal.executed = true;
            emit ProposalDefeated(proposalId);
            return;
        }

        proposal.queued = true;
        emit ProposalQueued(proposalId);
    }

    /*//////////////////////////////////////////////////////////////
                          VIEW HELPERS
    //////////////////////////////////////////////////////////////*/

    function getProposalState(uint256 proposalId)
        external
        view
        returns (ProposalState)
    {
        Proposal storage proposal = proposals[proposalId];
        if (proposal.startTime == 0) revert InvalidProposal();

        if (proposal.executed) return ProposalState.Executed;
        if (proposal.queued) return ProposalState.Queued;
        if (block.timestamp > proposal.endTime) {
            return ProposalState.Defeated;
        }
        if (block.timestamp >= proposal.startTime) {
            return ProposalState.Active;
        }
        return ProposalState.Pending;
    }

    function proposalCount() external view returns (uint256) {
        return _proposalCount;
    }
}
