// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/utils/ReentrancyGuard.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";

contract MultiLockStaking is ReentrancyGuard, Ownable {
    
    IERC20 public stakingToken;
    IERC20 public rewardToken;

    struct LockOption {
        uint256 duration;
        uint256 apy;
    }

    LockOption[] public lockOptions;

    struct UserStake {
        uint256 amount;
        uint256 lockEndTime;
        uint256 apy;
        uint256 lastUpdateTime;
        uint256 rewardDebt;
    }

    mapping(address => UserStake) public userStakes;

    event Staked(address indexed user, uint256 amount, uint256 optionIndex, uint256 lockEndTime);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);
    event Compounded(address indexed user, uint256 addedAmount);

    uint256 public constant YEAR = 365 days;

    constructor(address _stakingToken, address _rewardToken) Ownable(msg.sender) {
        stakingToken = IERC20(_stakingToken);
        rewardToken = IERC20(_rewardToken);

        // 默认锁仓方案
        lockOptions.push(LockOption(30 days, 800));    // 30天  8%
        lockOptions.push(LockOption(90 days, 1500));   // 90天 15%
        lockOptions.push(LockOption(180 days, 2000));  // 180天 20%
        lockOptions.push(LockOption(365 days, 2800));  // 365天 28%
    }

    function addLockOption(uint256 _duration, uint256 _apy) external onlyOwner {
        lockOptions.push(LockOption(_duration, _apy));
    }

    function pendingReward(address _user) public view returns (uint256) {
        UserStake storage user = userStakes[_user];
        if (user.amount == 0) return 0;
        
        uint256 timeElapsed = block.timestamp - user.lastUpdateTime;
        uint256 reward = (user.amount * user.apy * timeElapsed) / (10000 * YEAR);
        return reward + user.rewardDebt;
    }

    function stake(uint256 _amount, uint256 _optionIndex) external nonReentrant {
        require(_amount > 0, "Amount > 0");
        require(_optionIndex < lockOptions.length, "Invalid option");

        LockOption memory option = lockOptions[_optionIndex];
        UserStake storage user = userStakes[msg.sender];

        if (user.amount > 0) {
            uint256 pending = pendingReward(msg.sender);
            if (pending > 0) {
                rewardToken.transfer(msg.sender, pending);
                emit RewardClaimed(msg.sender, pending);
            }
        }

        stakingToken.transferFrom(msg.sender, address(this), _amount);

        user.amount += _amount;
        user.apy = option.apy;
        user.lockEndTime = block.timestamp + option.duration;
        user.lastUpdateTime = block.timestamp;
        user.rewardDebt = 0;

        emit Staked(msg.sender, _amount, _optionIndex, user.lockEndTime);
    }

    function claimReward() external nonReentrant {
        uint256 pending = pendingReward(msg.sender);
        require(pending > 0, "No reward");

        UserStake storage user = userStakes[msg.sender];
        user.lastUpdateTime = block.timestamp;
        user.rewardDebt = 0;

        rewardToken.transfer(msg.sender, pending);
        emit RewardClaimed(msg.sender, pending);
    }

    function compound() external nonReentrant {
        uint256 pending = pendingReward(msg.sender);
        require(pending > 0, "No reward");

        UserStake storage user = userStakes[msg.sender];
        user.amount += pending;
        user.lastUpdateTime = block.timestamp;
        user.rewardDebt = 0;

        emit Compounded(msg.sender, pending);
    }

    function withdraw() external nonReentrant {
        UserStake storage user = userStakes[msg.sender];
        require(user.amount > 0, "No stake");
        require(block.timestamp >= user.lockEndTime, "Still locked");

        uint256 pending = pendingReward(msg.sender);
        uint256 amount = user.amount;

        if (pending > 0) {
            rewardToken.transfer(msg.sender, pending);
            emit RewardClaimed(msg.sender, pending);
        }

        user.amount = 0;
        user.rewardDebt = 0;

        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function depositRewards(uint256 _amount) external onlyOwner {
        rewardToken.transferFrom(msg.sender, address(this), _amount);
    }

    function getUserInfo(address _user) external view returns (
        uint256 stakedAmount,
        uint256 pending,
        uint256 lockEndTime,
        uint256 apy
    ) {
        UserStake storage user = userStakes[_user];
        return (user.amount, pendingReward(_user), user.lockEndTime, user.apy);
    }
}