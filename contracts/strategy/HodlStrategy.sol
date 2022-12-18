// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Strategy.sol";

contract HodlStrategy is Strategy {
  using SafeERC20 for IERC20;
  address private immutable owner;
  
  constructor(address _owner) {
    owner = _owner;
  }

  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }
  function prepare(IERC20 token) external onlyOwner {}

  function deposited(IERC20 token, uint256 amount) external onlyOwner {
  }
  function withdraw(IERC20 token, uint256 amount, address recipient) external onlyOwner {
    token.safeTransfer(recipient, amount);
  }
  function balance(IERC20 token) external view returns (uint256) {
    return token.balanceOf(address(this));
  }
}