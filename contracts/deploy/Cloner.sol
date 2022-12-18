// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Deployer.sol";



contract Cloner is AccessControl {
  address blueprint;
  Deployer immutable deployer;
  bytes32 public constant ADMIN = keccak256("ADMIN");
  bytes32 public constant DEPLOYER = keccak256("DEPLOYER");
  constructor(Deployer _deployer) {
    deployer = _deployer;
    blueprint = address(this);
    _grantRole(ADMIN, msg.sender);
    _grantRole(DEPLOYER, msg.sender);
    _setRoleAdmin(ADMIN, ADMIN);
    _setRoleAdmin(DEPLOYER, ADMIN);
  }
  
  function clone(address _blueprint, bytes32 _salt, bytes calldata _data) onlyRole(DEPLOYER) external returns (address) {
    blueprint = _blueprint;
    address ret = deployer.deploy(address(this), _salt);
    blueprint = address(this);
    (bool success,) = ret.call(_data);
    require(success);
    return ret;
  }

  fallback() external {
    address _blueprint = blueprint;
    assembly {
      let l := extcodesize(_blueprint)
      extcodecopy(_blueprint, 0, 0, l)
      return(0,l)
    }
  }
}