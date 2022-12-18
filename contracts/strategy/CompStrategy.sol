// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Strategy.sol";
import "../lib/Math.sol";
import "../interface/IComptroller.sol";
import "../interface/ICToken.sol";

contract CompStrategy is Strategy {
  using SafeERC20 for IERC20;
  address private immutable owner;
  IComptroller private immutable comptroller;

  mapping(IERC20 => ICToken) cTokens;
  constructor(address _owner, IComptroller _comptroller) {
    comptroller = _comptroller;
    owner = _owner;
  }

  function updatecTokens() external {
    ICToken[] memory ret = comptroller.getAllMarkets();
    for (uint256 i = 0; i < ret.length; i++) {
      cTokens[ret[i].underlying()] = ret[i];
    }
  }

  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }

  function prepare(IERC20 token) external onlyOwner {
    token.approve(address(cTokens[token]), type(uint256).max);
  }

  function deposited(IERC20 token, uint256 amount) external onlyOwner {
    cTokens[token].mint(amount);
  }

  function withdraw(IERC20 token, uint256 amount, address recipient) external onlyOwner {
    cTokens[token].redeemUnderlying(amount);
    token.safeTransfer(recipient, amount);
  }

  function balance(IERC20 token) external view returns (uint256) {
    (, uint256 vTokenBalance, , uint256 exchangeRateMantissa) = cTokens[token].getAccountSnapshot(address(this));
    return Math.muldiv(vTokenBalance, exchangeRateMantissa, 10**18);
  }
}