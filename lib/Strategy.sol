// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

abstract contract Strategy {
  function deposited(ERC20 token, uint256 amount) external virtual;
  function withdraw(ERC20 token, uint256 amount, address recipient) external virtual;
  function balance(ERC20 token) external virtual returns (uint256);
}