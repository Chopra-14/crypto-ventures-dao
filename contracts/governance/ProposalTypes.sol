// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library ProposalTypes {
    struct Proposal {
        address proposer;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }
}
