// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./MetaToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaTokenFactory is Ownable {
    event MetaTokenCreated(address metaTokenAddress);

    function createMetaToken(
        address _originalTokenAddress,
        uint256 _amountToWrap,
        uint256 _lockTime,
        string memory _name,
        string memory _symbol
    ) external onlyOwner returns (address) {
        require(_amountToWrap > 0, "Amount to wrap must be greater than zero");
        MetaToken newMetaToken = new MetaToken(
            _name,
            _symbol,
            _originalTokenAddress,
            _amountToWrap,
            _lockTime
        );

        emit MetaTokenCreated(address(newMetaToken));
        return address(newMetaToken);
    }
}
