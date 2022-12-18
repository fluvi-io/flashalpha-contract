// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Create2.sol";


contract Deployer is AccessControl {
  address blueprint;
  bytes32 public constant ADMIN = keccak256("ADMIN");
  bytes32 public constant DEPLOYER = keccak256("DEPLOYER");
  constructor() {
    blueprint = address(this);
    _grantRole(ADMIN, msg.sender);
    _grantRole(DEPLOYER, msg.sender);
    _setRoleAdmin(ADMIN, ADMIN);
    _setRoleAdmin(DEPLOYER, ADMIN);
  }
  function computeAddress(bytes32 _salt) external view returns (address) {
    bytes memory copycat = hex"60008080808080335af1503d81803e3d90f3";
    return Create2.computeAddress(_salt, keccak256(copycat));
  }
  function deploy(address _blueprint, bytes32 _salt) onlyRole(DEPLOYER) external returns (address) {
    bytes memory copycat = hex"60008080808080335af1503d81803e3d90f3";
    blueprint = _blueprint;
    address ret;
    assembly {
      ret := create2(0, add(copycat, 32), mload(copycat), _salt)
    }
    blueprint = address(this);
    return ret;
  }

  fallback() external {
    address _blueprint = blueprint;
    assembly {
      let v := call(gas(), _blueprint, 0, 0, 0, 0, 0)
      returndatacopy(0, 0, returndatasize())
      return(0,returndatasize())
    }
  }
}