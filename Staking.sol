// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Staking is Ownable {
    IERC20 public stakingToken;
    uint256 public rewardRate;
    mapping(address => uint256) public stakedAmounts;
    mapping(address => uint256) public rewardDebts;

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 reward);

    constructor(IERC20 _stakingToken, uint256 _rewardRate) {
        stakingToken = _stakingToken;
        rewardRate = _rewardRate;
    }

    function stake(uint256 amount) external {
        require(stakingToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        stakedAmounts[msg.sender] += amount;
        rewardDebts[msg.sender] = rewardDebts[msg.sender] + (amount * rewardRate);

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(stakedAmounts[msg.sender] >= amount, "Insufficient staked amount");

        stakedAmounts[msg.sender] -= amount;
        require(stakingToken.transfer(msg.sender, amount), "Transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    function claimRewards() external {
        uint256 reward = stakedAmounts[msg.sender] * rewardRate - rewardDebts[msg.sender];
        require(reward > 0, "No rewards available");

        rewardDebts[msg.sender] += reward;
        require(stakingToken.transfer(msg.sender, reward), "Transfer failed");

        emit RewardsClaimed(msg.sender, reward);
    }
}
