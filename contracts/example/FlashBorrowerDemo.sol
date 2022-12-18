// SPDX-License-Identifier: CC0
pragma solidity ^0.8.0;
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interface/IERC3156FlashBorrower.sol";
import "../interface/IERC3156FlashLender.sol";
import "../interface/ICToken.sol";
import "../interface/IComptroller.sol";
import "./interface/IUniswapV2Router.sol";


IComptroller constant comptroller = IComptroller(0xfD36E2c2a6789Db23113685031d7F16329158384);
ICToken constant cUSDC = ICToken(0xecA88125a5ADbe82614ffC12D0DB554E2e2867C8);
IERC20 constant USDC = IERC20(0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d);
ICToken constant cUSDT = ICToken(0xfD5840Cd36d94D7229439859C0112a4185BC0255);
IERC20 constant USDT = IERC20(0x55d398326f99059fF775485246999027B3197955);
ICToken constant cWETH = ICToken(0xf508fCD89b8bd15579dc79A6827cB4686A3592c8);
IUniswapV2Router constant router = IUniswapV2Router(0x10ED43C718714eb63d5aA57B78B54704E256024E);

contract FlashBorrowerDemo is IERC3156FlashBorrower, Ownable {

    IERC3156FlashLender immutable lender;

    constructor (
        IERC3156FlashLender lender_
    ) {
        lender = lender_;
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external override returns(bytes32) {
        require(
            msg.sender == address(lender),
            "FlashBorrower: Untrusted lender"
        );
        require(
            initiator == address(this),
            "FlashBorrower: Untrusted loan initiator"
        );
        
        _step2();
        
        IERC20(token).approve(address(lender), amount + fee);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
    function borrowFromVenus() external onlyOwner {
        USDT.approve(address(cUSDT), type(uint256).max);
        cUSDT.mint(10**18);

        ICToken[] memory a = new ICToken[](1);
        a[0] = cUSDT;
        
        comptroller.enterMarkets(a);
        cWETH.borrow(630000000000000);
    }

    function _step2() internal {
        USDC.approve(address(cUSDC), type(uint256).max);
        cUSDC.mint(10**18);
        
        ICToken[] memory a = new ICToken[](1);
        a[0] = cUSDC;

        comptroller.enterMarkets(a);
        cUSDT.redeem(cUSDT.balanceOf(address(this)));

        address[] memory b = new address[](2);
        b[0] = address(USDT);
        b[1] = address(USDC);

        comptroller.enterMarkets(a);

        USDT.approve(address(router), type(uint256).max);
        router.swapExactTokensForTokens(USDT.balanceOf(address(this)), 1, b, address(this), block.timestamp);
    }
    
    
    /// @dev Initiate a flash loan
    function collateralSwap(
    ) external onlyOwner {
        lender.flashLoan(this, USDC, 10*10**18, "");
    }
}