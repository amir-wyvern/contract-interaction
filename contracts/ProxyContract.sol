// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IBackContract } from "./IBackContract.sol"
contract ProxyContract {    

    address public backContract;

    constructor(address _backContract) {
        backContract = _backContract;
    }

    function setNumberOnBackContract(uint256 number) public returns(uint256) {
        IBackContract(backContract).setNumber(number);
    }

    function getNumberOnBackContract() public returns(uint256) {
        uint256 _number;
        _number = IBackContract(backContract).getNumber();
        return _number;
    }

}