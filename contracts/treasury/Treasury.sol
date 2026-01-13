// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Treasury {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    receive() external payable {}

    function transferFunds(address payable to, uint256 amount) external {
        require(msg.sender == owner, "Not authorized");
        require(address(this).balance >= amount, "Insufficient treasury balance");
        to.transfer(amount);
    }
}