// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../governance/ProposalTypes.sol";

/**
 * @title Treasury
 * @author CryptoVentures DAO
 * @notice Multi-tier treasury for DAO fund management
 * @dev Funds are separated by proposal risk category
 */
contract Treasury {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error NotAuthorized();
    error InsufficientFunds();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event FundsDeposited(
        ProposalTypes.ProposalType indexed proposalType,
        uint256 amount
    );

    event FundsTransferred(
        ProposalTypes.ProposalType indexed proposalType,
        address indexed to,
        uint256 amount
    );

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/

    address public immutable governanceDAO;

    mapping(ProposalTypes.ProposalType => uint256) private _balances;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _governanceDAO) {
        governanceDAO = _governanceDAO;
    }

    /*//////////////////////////////////////////////////////////////
                         FUND MANAGEMENT
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Deposit ETH into a specific treasury bucket
     * @param proposalType Fund category
     */
    function deposit(
        ProposalTypes.ProposalType proposalType
    ) external payable {
        _balances[proposalType] += msg.value;

        emit FundsDeposited(proposalType, msg.value);
    }

    /**
     * @notice Transfer funds (callable only by GovernanceDAO)
     * @param proposalType Fund category
     * @param to Recipient address
     * @param amount Amount of ETH to transfer
     */
    function transferFunds(
        ProposalTypes.ProposalType proposalType,
        address to,
        uint256 amount
    ) external {
        if (msg.sender != governanceDAO) revert NotAuthorized();
        if (_balances[proposalType] < amount) revert InsufficientFunds();

        _balances[proposalType] -= amount;

        (bool success, ) = to.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit FundsTransferred(proposalType, to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                          VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns balance of a treasury bucket
     */
    function balanceOf(
        ProposalTypes.ProposalType proposalType
    ) external view returns (uint256) {
        return _balances[proposalType];
    }
}
