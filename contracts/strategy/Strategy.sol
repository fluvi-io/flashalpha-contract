// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface Strategy {
  function prepare(IERC20 token) external;
  function deposited(IERC20 token, uint256 amount) external;
  function withdraw(IERC20 token, uint256 amount, address recipient) external;
  function balance(IERC20 token) external view returns (uint256);
}