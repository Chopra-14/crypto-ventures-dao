// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract GovernanceToken {
    mapping(address => uint256) private _stakes;
    uint256 private _totalStaked;

    function stake() external payable {
        _stakes[msg.sender] += msg.value;
        _totalStaked += msg.value;
    }

    function stakeOf(address user) external view returns (uint256) {
        return _stakes[user];
    }

    function totalStaked() external view returns (uint256) {
        return _totalStaked;
    }
}