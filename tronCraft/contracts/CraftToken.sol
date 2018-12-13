pragma solidity ^0.4.23;

import "./openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol";
import "./openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol";
import "./helper/ContractRole.sol";


contract CraftToken is ERC20, ERC20Detailed, ERC20Pausable, ERC20Burnable, ERC20Capped, ContractRole {

    constructor(
        string name,
        string symbol,
        uint8 decimals,
        uint256 cap
    )
    ERC20()
    ERC20Burnable()
    ERC20Detailed(name, symbol, decimals)
    ERC20Pausable()
    ERC20Capped(cap)
    public{}


    function transferFromByCraft(address userAddr, address craftAddr, uint256 value, uint256 bonus) public onlyContracter returns (bool) {
        require(bonus < balanceOf(craftAddr), "Greater than contract cft");
        _transfer(userAddr, craftAddr, value);
        return true;
    }
}