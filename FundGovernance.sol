// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./GovernanceToken.sol";

contract FundGovernance is Ownable {
    using SafeMath for uint256;

    GovernanceToken public governanceToken;
    uint256 public proposalCount = 0;

    struct Proposal {
        uint256 id;
        string description;
        address[] altcoins;
        uint256[] allocations;
        uint256 votesYes;
        uint256 votesNo;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public votes;

    event ProposalCreated(uint256 id, string description);
    event VoteCasted(uint256 proposalId, address voter, bool support);
    event ProposalExecuted(uint256 id);

    constructor(address _governanceToken) {
        governanceToken = GovernanceToken(_governanceToken);
    }

    function createProposal(string memory description, address[] memory altcoins, uint256[] memory allocations) external onlyOwner {
        require(altcoins.length == allocations.length, "Altcoins and allocations length mismatch");
        require(altcoins.length == 30, "Exactly 30 altcoins required");

        proposalCount = proposalCount.add(1);
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            description: description,
            altcoins: altcoins,
            allocations: allocations,
            votesYes: 0,
            votesNo: 0,
            executed: false
        });

        emit ProposalCreated(proposalCount, description);
    }

    function vote(uint256 proposalId, bool support) external {
        require(governanceToken.balanceOf(msg.sender) > 0, "Only token holders can vote");
        require(!votes[msg.sender][proposalId], "Already voted on this proposal");

        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");

        votes[msg.sender][proposalId] = true;
        
        if (support) {
            proposal.votesYes = proposal.votesYes.add(governanceToken.balanceOf(msg.sender));
        } else {
            proposal.votesNo = proposal.votesNo.add(governanceToken.balanceOf(msg.sender));
        }

        emit VoteCasted(proposalId, msg.sender, support);
    }

    function executeProposal(uint256 proposalId) external onlyOwner {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(proposal.votesYes > proposal.votesNo, "Proposal did not pass");

        proposal.executed = true;

        // Allocation logic can be implemented here

        emit ProposalExecuted(proposalId);
    }
}