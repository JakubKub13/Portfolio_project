//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./BancorFormula.sol";

abstract contract BondingCurve is ERC20, BancorFormula, Ownable {
    uint32 reserveRatio;
    uint256 gasPrice = 0 wei;

    modifier validGasPrice() {
        assert(tx.gasprice <= gasPrice);
        _;
    }

    function buy() public payable validGasPrice returns (bool) {
        require(msg.value > 0, "BondingCurve: Can not buy for 0");
        uint256 reserveCurrency = address(this).balance;
        uint256 tokenSupply = totalSupply();
        uint256 tokensToMint = purchaseCalculation(tokenSupply, reserveCurrency, reserveRatio, msg.value);
        _mint(msg.sender, tokensToMint);
        return true;
    }

    function sell(uint256 sellAmount) public validGasPrice returns (bool) {
        require(sellAmount > 0 && balanceOf(msg.sender) >= sellAmount, "BondingCurve: Selling conditions not met");
        uint256 tokenSupply = totalSupply();
        uint256 reserveCurrency = address(this).balance;
        uint256 ethAmount = sellCalculation(tokenSupply, reserveCurrency, reserveRatio, sellAmount);
        //(bool success, ) = payable(msg.sender).call{value: ethAmount}("");
        //require(success, "BondingCurve: Sending eth transaction has failed");
        payable(msg.sender).transfer(ethAmount);
        _burn(msg.sender, sellAmount);
        return true;
    }
}