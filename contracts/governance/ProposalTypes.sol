// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ProposalTypes
 * @author CryptoVentures DAO
 * @notice Defines governance configuration for different proposal risk categories
 * @dev This contract is read-only and provides quorum, approval, and timelock rules
 */
contract ProposalTypes {
    /*//////////////////////////////////////////////////////////////
                            PROPOSAL TYPES
    //////////////////////////////////////////////////////////////*/

    enum ProposalType {
        HIGH_CONVICTION,
        EXPERIMENTAL,
        OPERATIONAL
    }

    /*//////////////////////////////////////////////////////////////
                          CONFIG STRUCT
    //////////////////////////////////////////////////////////////*/

    struct ProposalConfig {
        uint256 quorumPercentage;     // Minimum participation required (in %)
        uint256 approvalPercentage;   // Minimum FOR votes required (in %)
        uint256 timelockDelay;         // Timelock duration in seconds
    }

    /*//////////////////////////////////////////////////////////////
                        READ-ONLY CONFIG
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Returns governance configuration for a proposal type
     */
    function getConfig(
        ProposalType proposalType
    ) external pure returns (ProposalConfig memory) {
        if (proposalType == ProposalType.HIGH_CONVICTION) {
            return ProposalConfig({
                quorumPercentage: 30,          // 30% quorum
                approvalPercentage: 60,        // 60% FOR votes
                timelockDelay: 3 days           // High-risk → longer delay
            });
        }

        if (proposalType == ProposalType.EXPERIMENTAL) {
            return ProposalConfig({
                quorumPercentage: 20,          // 20% quorum
                approvalPercentage: 55,        // 55% FOR votes
                timelockDelay: 2 days
            });
        }

        // OPERATIONAL (default / lowest risk)
        return ProposalConfig({
            quorumPercentage: 10,              // 10% quorum
            approvalPercentage: 50,            // Simple majority
            timelockDelay: 12 hours             // Faster execution
        });
    }
}
