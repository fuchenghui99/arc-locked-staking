# Arc Network - Multi Lock Staking Contract

A flexible staking contract with **multiple lock periods**, **different APYs**, and **compounding** support, deployed on the Arc Network (Testnet).

## Features

- Support for multiple lock durations with different APY rates
- Fixed APY calculation (accrued per second)
- Claim rewards at any time
- Compound rewards (reinvest rewards into principal)
- Withdraw principal + remaining rewards after lock period ends
- Secure with ReentrancyGuard and Ownable
- Fully compatible with Arc Network (USDC as gas token)

## Contract Addresses (Arc Testnet)

- **MultiLockStaking Contract**: `0x0D30BBF701e66A793371Ad4968b28173DFaa03C9`
- **Reward Token (Mock)**: `0xab9FC686aF379f5e3Aa49E1AA4901a7b18F4b195`
- **Staking Token**: Arc Testnet USDC (`0x3600000000000000000000000000000000000000`)

## Lock Options

| Option | Lock Duration | APY    |
|--------|---------------|--------|
| 0      | 30 days       | 8%     |
| 1      | 90 days       | 15%    |
| 2      | 180 days      | 20%    |
| 3      | 365 days      | 28%    |

## How to Use

### For Admin / Owner:
- Call `depositRewards(uint256 amount)` to fund the contract with reward tokens.

### For Users:
1. Approve the staking token to the contract address
2. Call `stake(uint256 amount, uint256 optionIndex)` to stake
3. Use `claimReward()` to claim accrued rewards
4. Use `compound()` to reinvest rewards into your principal
5. After the lock period ends, call `withdraw()` to unstake and receive principal + remaining rewards

## View Functions

- `pendingReward(address user)` - Check pending rewards
- `getUserInfo(address user)` - Get user's stake details
- `getLockOptions()` - View all available lock options

## Technical Information

- **Solidity Version**: ^0.8.20
- **Network**: Arc Testnet (Chain ID: 5042002)
- **Gas Token**: USDC
- **Security**: ReentrancyGuard + Ownable
- **Reward Calculation**: Fixed APY, time-based (per second)

## Deployment Details

- **Deployment Date**: April 2026
- **Deployer Address**: `0x25fDfceE8d119a7bAb73FD4AB38AC2826Ca694A6`
- **Transaction Hash**: `0x56e9afaeb5d6a94d7243218b1463bfab35230002c2f98badfa3de76b30791bd1`
- **Block Number**: 39458245

## Future Improvements

- Add more lock options dynamically
- Emergency withdraw function
- Pausable mechanism
- Frontend integration (optional)

---

**Built for Arc Network**
