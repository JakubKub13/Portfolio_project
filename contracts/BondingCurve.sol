//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BancorFormula.sol";

contract BondingCurve is ERC20, BancorFormula, Ownable {
    uint32 reserveRatio;
    uint256 gasPrice = 0 wei;

    function buy() public payable returns (bool) {
        require(msg.value > 0, "BondingCurve: Can not buy for 0");
        uint256 reserveCurrency = address(this).balance;
        uint256 tokenSupply = totalSupply();
        uint256 tokensToMint = purchaseCalculation(tokenSupply, reserveCurrency, reserveRatio, msg.value);
        _mint(msg.sender, tokensToMint);
        return true;
    }
}