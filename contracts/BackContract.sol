// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract BackContract {    

    event setEventNumber(uint256 _number);
    uint256 public mainNumber ;

    function setNumber(uint256 number) external {
        emit setEventNumber(number);
        mainNumber = number;
    }

    function getNumber() external view returns(uint256) {
        return mainNumber;
    }
}
