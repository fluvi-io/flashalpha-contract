// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (proxy/transparent/ProxyAdmin.sol)

pragma solidity ^0.8.9;

contract Probe {
    function observe(bytes memory _creationCode, bytes memory _calldata) external returns (bytes memory) {
        address addr;
        uint256 len = _creationCode.length;
        assembly {
            addr := create(0, add(_creationCode, 32), len)
        }
        (bool success, bytes memory data) = addr.call(_calldata);
        require(success);
        return data;
    }
}