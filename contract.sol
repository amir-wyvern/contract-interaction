// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract Test {

    uint256 public var2;

    function setVar(uint256 _var) public {
        var2 = _var;
    }

    function getVar() public returns(uint256) {
        return var2;
    }
}