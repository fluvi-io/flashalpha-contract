// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";

import "@openzeppelin/contracts/proxy/Proxy.sol";

contract ReceiverProxy is Proxy, ERC1967Upgrade {
    function ___initializeProxy(address _logic, bytes memory _data) external {
        require (_implementation() == address(0));
        _upgradeToAndCall(_logic, _data, false);
    }
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }
    receive() external payable override{}
}
