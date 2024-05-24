// SPDX-License-Identifier: BSD-3-Clause license
pragma solidity 0.8.19;

import "../libraries/LibOwnership.sol";
import "../interfaces/IERC173.sol";

contract OwnershipFacet is IERC173 {
    function transferOwnership(address _newOwner) external override {
        LibOwnership.enforceIsContractOwner();
        LibOwnership.setContractOwner(_newOwner);
    }

    function owner() external override view returns (address owner_) {
        owner_ = LibOwnership.contractOwner();
    }
}
