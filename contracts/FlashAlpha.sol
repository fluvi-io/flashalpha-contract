// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "./interface/IWETH.sol";
import "./interface/IERC3156FlashLender.sol";
import "./interface/IWETH.sol";
import "./lib/Math.sol";
import "./strategy/Strategy.sol";
import "./strategy/SelfHodlStrategy.sol";

function min(uint256 a, uint256 b) pure returns (uint256) {return a < b ? a : b;}

contract FlashAlpha is IERC3156FlashLender, OwnableUpgradeable, ReentrancyGuardUpgradeable, ERC1967Upgrade {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;
    
    uint8 public constant maxFeeBP = 10;
    IWETH immutable weth;
    Strategy public immutable defaultStrategy;
    mapping(IERC20 => Strategy) public strategies;

    mapping(IERC20 => uint256) totalShares;
    mapping(IERC20 => mapping(uint8 => uint256)) feeShares;

    mapping(IERC20 => mapping(uint8 => uint256)) positionTotalShares;
    mapping(IERC20 => mapping(uint8 => mapping(address => uint256))) positionShares;

    constructor(IWETH _weth, Strategy _defaultStrategy) {weth = _weth; defaultStrategy = _defaultStrategy;}

    function initialize() external initializer {
        
        _transferOwnership(tx.origin);
        __ReentrancyGuard_init();
    }
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    function supportedTokens(IERC20) external pure returns (bool) {return true;}
    
    function flashLoan(
        IERC3156FlashBorrower receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        uint256 fee = _flashFee(token, amount, true);

        Strategy strategy = _getStrategy(token);
        
        strategy.withdraw(token, amount, address(receiver));

        require(
            receiver.onFlashLoan(msg.sender, address(token), amount, fee, data) == CALLBACK_SUCCESS,
            "FlashLender: Callback failed"
        );

        IERC20(token).safeTransferFrom(address(receiver), address(strategy), amount + fee);
        strategy.deposited(token, amount+fee);
        return true;
    }
    
    function deposit(IERC20 token, uint256 amount, uint8 fee) external nonReentrant {
        Strategy strategy = _getStrategy(token);
        _deposit(msg.sender, token, amount, fee);
        token.safeTransferFrom(msg.sender, address(strategy), amount);
        strategy.deposited(token, amount);
    }
    
    function depositNative(uint8 fee) external payable nonReentrant {
        _deposit(msg.sender, weth, msg.value, fee);
        weth.deposit{value: msg.value}();
        weth.safeTransfer(address(_getStrategy(weth)), msg.value);
        _getStrategy(weth).deposited(weth, msg.value);
    }
    
    function _deposit(address from, IERC20 token, uint256 amount, uint8 fee) internal {
        uint256 balance = maxFlashLoan(token);
        uint256 balance2 = feeShares[token][fee];
        uint256 newShares = balance == 0 ? amount : Math.muldiv(totalShares[token], amount, balance);
        uint256 newShares2 = balance2 == 0 ? newShares : Math.muldiv(positionTotalShares[token][fee], newShares, balance2);

        totalShares[token] += newShares;
        feeShares[token][fee] += newShares;

        positionTotalShares[token][fee] += newShares2;
        positionShares[token][fee][from] += newShares2;
    }


    function withdraw(IERC20 token, uint256 amount, uint8 fee) external nonReentrant {
        Strategy strategy = _getStrategy(token);
        uint256 actualAmount = _withdraw(msg.sender, token, amount, fee);
        strategy.withdraw(token, actualAmount, msg.sender);
    }
    
    function withdrawNative(uint256 amount, uint8 fee) external nonReentrant {
        Strategy strategy = _getStrategy(weth);
        uint256 actualAmount = _withdraw(msg.sender, weth, amount, fee);
        strategy.withdraw(weth, actualAmount, address(this));
        weth.withdraw(actualAmount);
        (bool success,) = msg.sender.call{value: actualAmount}("");
        require (success);
    }
    
    function _withdraw(address from, IERC20 token, uint256 amount, uint8 fee) internal returns (uint256) {
        uint256 balance = maxFlashLoan(token);
        uint256 balance2 = feeShares[token][fee];

        uint256 shares = Math.muldiv(totalShares[token], amount, balance);
        uint256 shares2 = min(positionShares[token][fee][from], Math.muldiv(positionTotalShares[token][fee], shares, balance2));
        shares = Math.muldiv(balance2, shares2, positionTotalShares[token][fee]);

        uint256 actualAmount = Math.muldiv(balance, shares, totalShares[token]);


        totalShares[token] -= shares;
        feeShares[token][fee] -= shares;

        positionTotalShares[token][fee] -= shares2;
        positionShares[token][fee][from] -= shares2;

        return actualAmount;
    }

    function accoutBalance(IERC20 token, address addr) external view returns (uint256[] memory) {
        uint256[] memory amount = new uint256[](maxFeeBP);
        for (uint8 i = 0; i <= maxFeeBP; i++) {
            if (positionShares[token][i][addr] > 0) {
                amount[i] = Math.muldiv(Math.muldiv(maxFlashLoan(token), feeShares[token][i], totalShares[token]), positionShares[token][i][addr], positionTotalShares[token][i]);
            }
        }
        return amount;
    }
    
    function flashFee(
        IERC20 token,
        uint256 amount
    ) external returns (uint256) {
        return _flashFee(token, amount, false);
    }

    function maxFlashLoan(IERC20 token) public view returns (uint256) {
        return _getStrategy(token).balance(token);
    }

    function _flashFee(
        IERC20 token,
        uint256 amount,
        bool modify
    ) internal returns (uint256) {
        uint256 total = 0;
        uint256 amountLeft = amount;
        uint256 totalBorrowable = maxFlashLoan(token);
        uint256 tokenTotalShares = totalShares[token];

        for (uint8 i = 0; i <= maxFeeBP && amountLeft > 0; i++) {
            uint256 partialAmount = min(amountLeft, Math.muldiv(totalBorrowable, feeShares[token][i], tokenTotalShares));
            uint256 fee = Math.muldiv(partialAmount, i, 10000);
            uint256 partialShares = Math.muldiv(tokenTotalShares, fee, totalBorrowable);
            total += fee;
            amountLeft -= partialAmount;
            if (modify) {
                totalShares[token] += partialShares;
                feeShares[token][i] += partialShares;
            }
        }
        require(amountLeft == 0, "OVER_MAX_FLASHLOAN");
        return total;
    }

    function _getStrategy(IERC20 token) internal view returns (Strategy) {
        return address(strategies[token]) != address(0) ? strategies[token] : defaultStrategy;
    }

    function setStrategy(IERC20 token, Strategy strat) external onlyOwner {
        Strategy prev = _getStrategy(token);
        uint256 balance = prev.balance(token);
        prev.withdraw(token, balance, address(strat));
        strat.deposited(token, balance);
        strategies[token] = strat;
    }

    function upgrade(address newImplementation) external onlyOwner {
        _upgradeTo(newImplementation);
    }

    receive() external payable {}
}
