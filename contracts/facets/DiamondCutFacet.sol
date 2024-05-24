// SPDX-License-Identifier: BSD-3-Clause license
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "../interfaces/IDiamondCut.sol";
import "../libraries/LibDiamond.sol";
import "../libraries/LibOwnership.sol";

contract DiamondCutFacet is IDiamondCut {
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {
        LibOwnership.enforceIsContractOwner();

        uint256 selectorCount = LibDiamondStorage.diamondStorage().selectors.length;
        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            FacetCut memory cut;
            cut.action = _diamondCut[facetIndex].action;
            cut.facetAddress = _diamondCut[facetIndex].facetAddress;
            cut.functionSelectors = _diamondCut[facetIndex].functionSelectors;

            selectorCount = LibDiamond.executeDiamondCut(selectorCount, cut);
        }

        emit DiamondCut(_diamondCut, _init, _calldata);

        LibDiamond.initializeDiamondCut(_init, _calldata);
    }
}
