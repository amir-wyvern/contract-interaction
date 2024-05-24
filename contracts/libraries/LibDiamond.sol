// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
pragma experimental ABIEncoderV2;

import "../interfaces/IDiamondCut.sol";
import "./LibDiamondStorage.sol";

library LibDiamond {
    event DiamondCut(IDiamondCut.FacetCut[] _diamondCut, address _init, bytes _calldata);

    function diamondCut(
        IDiamondCut.FacetCut[] memory _diamondCut,
        address _init,
        bytes memory _calldata
    ) internal {
        uint256 selectorCount = LibDiamondStorage.diamondStorage().selectors.length;

        for (uint256 facetIndex; facetIndex < _diamondCut.length; facetIndex++) {
            selectorCount = executeDiamondCut(selectorCount, _diamondCut[facetIndex]);
        }

        emit DiamondCut(_diamondCut, _init, _calldata);

        initializeDiamondCut(_init, _calldata);
    }

    function executeDiamondCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        require(cut.functionSelectors.length > 0, "LibDiamond: No selectors in facet to cut");

        if (cut.action == IDiamondCut.FacetCutAction.Add) {
            require(cut.facetAddress != address(0), "LibDiamond: add facet address can't be address(0)");
            enforceHasContractCode(cut.facetAddress, "LibDiamond: add facet must have code");

            return _handleAddCut(selectorCount, cut);
        }

        if (cut.action == IDiamondCut.FacetCutAction.Replace) {
            require(cut.facetAddress != address(0), "LibDiamond: remove facet address can't be address(0)");
            enforceHasContractCode(cut.facetAddress, "LibDiamond: remove facet must have code");

            return _handleReplaceCut(selectorCount, cut);
        }

        if (cut.action == IDiamondCut.FacetCutAction.Remove) {
            require(cut.facetAddress == address(0), "LibDiamond: remove facet address must be address(0)");

            return _handleRemoveCut(selectorCount, cut);
        }

        revert("LibDiamondCut: Incorrect FacetCutAction");
    }

    function _handleAddCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < cut.functionSelectors.length; selectorIndex++) {
            bytes4 selector = cut.functionSelectors[selectorIndex];

            address oldFacetAddress = ds.facets[selector].facetAddress;
            require(oldFacetAddress == address(0), "LibDiamondCut: Can't add function that already exists");

            ds.facets[selector] = LibDiamondStorage.Facet(
                cut.facetAddress,
                uint16(selectorCount)
            );
            ds.selectors.push(selector);

            selectorCount++;
        }

        return selectorCount;
    }

    function _handleReplaceCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < cut.functionSelectors.length; selectorIndex++) {
            bytes4 selector = cut.functionSelectors[selectorIndex];

            address oldFacetAddress = ds.facets[selector].facetAddress;

            // only useful if immutable functions exist
            require(oldFacetAddress != address(this), "LibDiamondCut: Can't replace immutable function");
            require(oldFacetAddress != cut.facetAddress, "LibDiamondCut: Can't replace function with same function");
            require(oldFacetAddress != address(0), "LibDiamondCut: Can't replace function that doesn't exist");

            // replace old facet address
            ds.facets[selector].facetAddress = cut.facetAddress;
        }

        return selectorCount;
    }

    function _handleRemoveCut(uint256 selectorCount, IDiamondCut.FacetCut memory cut) internal returns (uint256) {
        LibDiamondStorage.DiamondStorage storage ds = LibDiamondStorage.diamondStorage();

        for (uint256 selectorIndex; selectorIndex < cut.functionSelectors.length; selectorIndex++) {
            bytes4 selector = cut.functionSelectors[selectorIndex];

            LibDiamondStorage.Facet memory oldFacet = ds.facets[selector];

            require(oldFacet.facetAddress != address(0), "LibDiamondCut: Can't remove function that doesn't exist");
            require(oldFacet.facetAddress != address(this), "LibDiamondCut: Can't remove immutable function.");

            // replace selector with last selector
            if (oldFacet.selectorPosition != selectorCount - 1) {
                bytes4 lastSelector = ds.selectors[selectorCount - 1];
                ds.selectors[oldFacet.selectorPosition] = lastSelector;
                ds.facets[lastSelector].selectorPosition = oldFacet.selectorPosition;
            }

            // delete last selector
            ds.selectors.pop();
            delete ds.facets[selector];

            selectorCount--;
        }

        return selectorCount;
    }

    function initializeDiamondCut(address _init, bytes memory _calldata) internal {
        if (_init == address(0)) {
            require(_calldata.length == 0, "LibDiamondCut: _init is address(0) but _calldata is not empty");
            return;
        }

        require(_calldata.length > 0, "LibDiamondCut: _calldata is empty but _init is not address(0)");
        if (_init != address(this)) {
            enforceHasContractCode(_init, "LibDiamondCut: _init address has no code");
        }

        (bool success, bytes memory error) = _init.delegatecall(_calldata);
        if (!success) {
            if (error.length > 0) {
                revert(string(error));
            } else {
                revert("LibDiamondCut: _init function reverted");
            }
        }
    }

    function enforceHasContractCode(address _contract, string memory _errorMessage) internal view {
        uint256 contractSize;
        assembly {
            contractSize := extcodesize(_contract)
        }
        require(contractSize > 0, _errorMessage);
    }
}
