// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IERC3156FlashBorrower.sol";
import "../interface/IERC3156FlashLender.sol";
import "../interface/ICToken.sol";
import "../interface/IComptroller.sol";


IComptroller constant comptroller = IComptroller(0xfD36E2c2a6789Db23113685031d7F16329158384);
ICToken constant cUSDC = ICToken(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8);
IERC20 constant USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
ICToken constant cUSDT = ICToken(0xfD5840Cd36d94D7229439859C0112a4185BC0255);
IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
ICToken constant cWETH = ICToken(0x95c78222B3D6e262426483D42CfA53685A67Ab9D);
IERC20 constant WETH = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
contract Query {
    function doIt() external {
        USDT.approve(address(cUSDT), type(uint256).max);
        cUSDT.mint(1000000000000000);
        cUSDT.redeem(cUSDT.balanceOf(address(this)));
        cUSDT.mint(1000000000000000);
    }
}