pragma solidity ^0.4.23;

import "../openzeppelin-solidity/contracts/access/Roles.sol";

contract ContractRole {
  using Roles for Roles.Role;

  Roles.Role private contracters;

  constructor() internal {
    _addContracter(msg.sender);
  }

  modifier onlyContracter() {
    require(isContracter(msg.sender));
    _;
  }

  function isContracter(address account) public view returns (bool) {
    return contracters.has(account);
  }

  function addContracter(address account) public onlyContracter {
    _addContracter(account);
  }

  function renounceContracter() public {
    _removeContracter(msg.sender);
  }

  function _addContracter(address account) internal {
    contracters.add(account);
  }

  function _removeContracter(address account) internal {
    contracters.remove(account);
  }
}
