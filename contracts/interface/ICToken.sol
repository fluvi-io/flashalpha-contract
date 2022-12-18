// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ICToken {
    function mint(uint256) external;
    function redeemUnderlying(uint256) external;
    function getAccountSnapshot(address) external view returns (uint256, uint256, uint256, uint256);
    function underlying() external returns (IERC20);
}