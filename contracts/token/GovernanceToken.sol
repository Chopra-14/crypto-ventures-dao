// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title GovernanceToken
 * @author CryptoVentures DAO
 * @notice ETH staking contract with quadratic voting power
 * @dev Voting power = sqrt(staked ETH) to reduce whale dominance
 */
contract GovernanceToken {
    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/
    error ZeroStake();
    error InsufficientStake();

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/
    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                              STORAGE
    //////////////////////////////////////////////////////////////*/
    mapping(address => uint256) private stakes;
    uint256 private totalStakedEth;

    /*//////////////////////////////////////////////////////////////
                              STAKING
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Stake ETH to gain governance voting power
     */
    function stake() external payable {
        if (msg.value == 0) revert ZeroStake();

        stakes[msg.sender] += msg.value;
        totalStakedEth += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    /**
     * @notice Unstake previously staked ETH
     * @param amount Amount of ETH to unstake
     */
    function unstake(uint256 amount) external {
        if (stakes[msg.sender] < amount) revert InsufficientStake();

        stakes[msg.sender] -= amount;
        totalStakedEth -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Unstaked(msg.sender, amount);
    }

    /*//////////////////////////////////////////////////////////////
                          VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns raw ETH staked by a user
     */
    function stakeOf(address user) external view returns (uint256) {
        return stakes[user];
    }

    /**
     * @notice Returns total ETH staked in the system
     */
    function totalStaked() external view returns (uint256) {
        return totalStakedEth;
    }

    /**
     * @notice Returns quadratic voting power of a user
     * @dev votingPower = sqrt(staked ETH)
     */
    function votingPower(address user) external view returns (uint256) {
        return _sqrt(stakes[user]);
    }

    /*//////////////////////////////////////////////////////////////
                         INTERNAL UTILS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Integer square root using Babylonian method
     */
    function _sqrt(uint256 x) internal pure returns (uint256 y) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
