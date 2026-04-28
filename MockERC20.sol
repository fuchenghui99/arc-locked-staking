// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

contract MockRewardToken is ERC20 {
    
    constructor() ERC20("Reward Token", "RWD") {
        _mint(msg.sender, 1000000 * 10 ** decimals()); // 给部署者 100万枚
    }

    // 方便测试，可以随时铸造更多
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}