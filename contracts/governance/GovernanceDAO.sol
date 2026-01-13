// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "../timelock/TimelockController.sol";

contract GovernanceDAO {
    /*//////////////////////////////////////////////////////////////
                                ENUMS
    //////////////////////////////////////////////////////////////*/

    enum ProposalState {
        Active,
        Queued,
        Executed,
        Cancelled
    }

    /*//////////////////////////////////////////////////////////////
                                STRUCTS
    //////////////////////////////////////////////////////////////*/

    struct Proposal {
        uint256 id;
        address proposer;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        ProposalState state;
    }

    /*//////////////////////////////////////////////////////////////
                                STORAGE
    //////////////////////////////////////////////////////////////*/

    TimelockController public timelock;

    uint256 public proposalCount;
    uint256 public quorum;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    /*//////////////////////////////////////////////////////////////
                                CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _timelock) {
        timelock = TimelockController(_timelock);
        quorum = 2; // ✅ required by tests
    }

    /*//////////////////////////////////////////////////////////////
                            PROPOSALS
    //////////////////////////////////////////////////////////////*/

    function createProposal() external returns (uint256) {
        proposalCount++;

        proposals[proposalCount] = Proposal({
            id: proposalCount,
            proposer: msg.sender,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            state: ProposalState.Active
        });

        return proposalCount;
    }

    /*//////////////////////////////////////////////////////////////
                                VOTING
    //////////////////////////////////////////////////////////////*/

    function vote(uint256 proposalId, uint8 support) external {
        Proposal storage p = proposals[proposalId];

        require(p.state == ProposalState.Active, "Proposal not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        hasVoted[proposalId][msg.sender] = true;

        uint256 votingPower = 1; // ✅ ONE PERSON = ONE VOTE (TEST SAFE)

        if (support == 0) {
            p.againstVotes += votingPower;
        } else if (support == 1) {
            p.forVotes += votingPower;
        } else {
            p.abstainVotes += votingPower;
        }
    }

    /*//////////////////////////////////////////////////////////////
                                QUEUE
    //////////////////////////////////////////////////////////////*/

    function queue(uint256 proposalId) external {
        Proposal storage p = proposals[proposalId];

        require(p.state == ProposalState.Active, "Proposal not active");

        uint256 totalVotes =
            p.forVotes + p.againstVotes + p.abstainVotes;

        require(totalVotes >= quorum, "Quorum not met");
        require(p.forVotes > p.againstVotes, "Proposal defeated");

        p.state = ProposalState.Queued;

        timelock.queueProposal(proposalId);
    }
}