pragma solidity 0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './Constants.sol';

contract Management is Ownable, Constants {

    // Contract Registry
    mapping(uint256 => address) public contractRegistry;

    // Permissions
    mapping(address => mapping(uint256 => bool)) public permissions;

    event PermissionsSet(address subject, uint256 permission, bool value);

    event ContractRegistered(uint256 key, address target);

    function setPermission(address _address, uint256 _permission, bool _value) public onlyOwner {
        permissions[_address][_permission] = _value;

        emit PermissionsSet(_address, _permission, _value);
    }

    function registerContract(uint256 _key, address _target) public onlyOwner {
        contractRegistry[_key] = _target;

        emit ContractRegistered(_key, _target);
    }

}