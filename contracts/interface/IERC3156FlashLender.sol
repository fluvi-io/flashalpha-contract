// SPDX-License-Identifier: UNLICENCED

pragma solidity ^0.7.0 || ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IERC3156FlashBorrower.sol";

interface IERC3156FlashLender {

    /**
     * @dev The amount of currency available to be lent.
     * @param token The loan currency.
     * @return The amount of `token` that can be borrowed.
     */
    function maxFlashLoan(
        IERC20 token
    ) external view returns (uint256);

    /**
     * @dev The fee to be charged for a given loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @return The amount of `token` to be charged for the loan, on top of the returned principal.
     */
    function flashFee(
        IERC20 token,
        uint256 amount
    ) external returns (uint256);

    /**
     * @dev Initiate a flash loan.
     * @param receiver The receiver of the tokens in the loan, and the receiver of the callback.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     */
    function flashLoan(
        IERC3156FlashBorrower receiver,
        IERC20 token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}