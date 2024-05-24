// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Test {

    uint256 public var2;
    event NewSetValue(uint256 oldValue, uint256 newValue);

    function setVar(uint256 _var) public {
        emit NewSetValue(var2, _var); // A new event is created when this function is called
        var2 = _var;
    }

    function getVar() public returns(uint256) {
        return var2;
    }
}