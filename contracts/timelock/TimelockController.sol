// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimelockController {
    uint256 public delay;
    address public guardian;

    mapping(uint256 => uint256) public queuedAt;

    constructor(uint256 _delay, address _guardian) {
        delay = _delay;
        guardian = _guardian;
    }

    function queueProposal(uint256 proposalId) external {
        queuedAt[proposalId] = block.timestamp;
    }

    function execute(uint256 proposalId) external view {
        require(
            block.timestamp >= queuedAt[proposalId] + delay,
            "Timelock not expired"
        );
    }

    function cancelProposal(uint256 proposalId) external {
        require(msg.sender == guardian, "Not guardian");
        delete queuedAt[proposalId];
    }
}