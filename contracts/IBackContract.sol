// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IBackContract {    

    event setEventNumber(uint256 _number);

    function setNumber(uint256 number) external;

    function getNumber() external view returns(uint256);
}
