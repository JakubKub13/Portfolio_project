//SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./SafePower.sol";

contract BancorFormula is SafePower {
    using SafeMath for uint256;

    uint32 private constant MAX_RATIO = 100000; // The hardcap of reserve ratio

    /**
    *@notice Calculates how many tokens we purchase for the amount of reserve currency we spend 
    */
    function purchaseCalculation(
        uint256 tokenSupply, 
        uint256 reserveCurrency, 
        uint32 reserveRatio, 
        uint256 depositAmount
    ) public view returns (uint256) {
        require(tokenSupply > 0 && reserveCurrency > 0 && reserveRatio <= MAX_RATIO, "BancorFormula: Conditions for calculation not met");
        // Special case when amount deposited is 0
        if (depositAmount == 0) {
            return 0;
        }
        // Special case when reserveRatio = MAX_RATIO
        if (reserveRatio == MAX_RATIO) {
            return tokenSupply.mul(depositAmount).div(reserveCurrency);
        }

        uint256 baseN = depositAmount.add(reserveCurrency);
        (uint256 result, uint8 precision) = power(baseN, reserveCurrency, reserveRatio, MAX_RATIO);
        uint256 tempVar = tokenSupply.mul(result) >> precision;
        return tempVar - tokenSupply;
    }

    /**
    *@notice Calculates how many tokens we sell to curve for reserve currency
    */
   function sellCalculation(
        uint256 tokenSupply,
        uint256 reserveCurrency,
        uint32 reserveRatio,
        uint256 sellAmount
   ) public view returns (uint256) {
        require(tokenSupply > 0 && reserveCurrency > 0 && reserveRatio <= MAX_RATIO && sellAmount <= tokenSupply, "BancorFormula: Conditions for calculation not met");
        // If we are selling complete supply ratio does not matter
        if (sellAmount == tokenSupply) {
            return reserveCurrency;
        }
        if (reserveRatio == MAX_RATIO) {
            return reserveCurrency.mul(sellAmount).div(tokenSupply);
        }

        uint256 baseD = tokenSupply - sellAmount;
        (uint256 result, uint8 precision) = power(tokenSupply, baseD, MAX_RATIO, reserveRatio);

        uint256 oldBalance = reserveCurrency.mul(result);
        uint256 newBalance = reserveCurrency << precision;
        return oldBalance.sub(newBalance).div(result);
   }
}