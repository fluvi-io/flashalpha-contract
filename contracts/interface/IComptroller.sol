// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

import "./ICToken.sol";

interface IComptroller {
    function getAllMarkets() external returns (ICToken[] memory);
    function enterMarkets(ICToken[] memory) external;
}