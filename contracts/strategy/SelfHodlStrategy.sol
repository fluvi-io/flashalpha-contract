// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Strategy.sol";

contract SelfHodlStrategy is Strategy {
  using SafeERC20 for IERC20;

  modifier onlySelf() {
    require (msg.sender == address(this));
    _;
  }
  function prepare(IERC20 token) external onlySelf {}

  function deposited(IERC20 token, uint256 amount) external onlySelf {
  }
  function withdraw(IERC20 token, uint256 amount, address recipient) external onlySelf {
    token.safeTransfer(recipient, amount);
  }
  function balance(IERC20 token) external view returns (uint256) {
    return token.balanceOf(address(this));
  }
}