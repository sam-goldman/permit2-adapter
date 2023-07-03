// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.8.0;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { Permit2Transfers, IPermit2 } from "../libraries/Permit2Transfers.sol";
import { Token } from "../libraries/Token.sol";
import { ISwapPermit2Adapter } from "../interfaces/ISwapPermit2Adapter.sol";
import { BasePermit2Adapter } from "./BasePermit2Adapter.sol";

/**
 * @title Swap Permit2 Adapter
 * @author Sam Bugs
 * @notice This contracts adds Permit2 capabilities to existing token swap contracts by acting as a proxy. It performs
 *         some extra checks to guarantee that the minimum amounts are respected
 * @dev It's important to note that this contract should never hold any funds outside of the scope of a transaction,
 *      nor should it be granted "regular" ERC20 token approvals. This contract is meant to be used as a proxy, so
 *      the only tokens approved/transferred through Permit2 should be entirely spent in the same transaction.
 *      Any unspent allowance or remaining tokens on the contract can be transferred by anyone, so please be careful!
 */
abstract contract SwapPermit2Adapter is BasePermit2Adapter, ISwapPermit2Adapter {
  using Permit2Transfers for IPermit2;
  using Token for address;
  using Address for address;

  /// @inheritdoc ISwapPermit2Adapter
  function sellOrderSwap(SellOrderSwapParams calldata _params)
    public
    payable
    checkDeadline(_params.deadline)
    returns (uint256 _amountIn, uint256 _amountOut)
  {
    // Take from caller
    PERMIT2.takeFromCaller(_params.tokenIn, _params.amountIn, _params.nonce, _params.deadline, _params.signature);

    // Max approve token in
    _params.tokenIn.maxApproveIfNecessary(_params.allowanceTarget);

    // Execute swap
    _params.swapper.functionCallWithValue(_params.swapData, msg.value);

    // Check min amount
    _amountOut = _params.tokenOut.balanceOnContract();
    if (_amountOut < _params.minAmountOut) revert ReceivedTooLittleTokenOut(_amountOut, _params.minAmountOut);

    // Distribute token out
    _params.tokenOut.distributeTo(_params.transferOut);

    // Set amount in
    _amountIn = _params.amountIn;
  }

  /// @inheritdoc ISwapPermit2Adapter
  function sellOrderSwapWithGasMeasurement(SellOrderSwapParams calldata _params)
    external
    payable
    returns (uint256 _amountIn, uint256 _amountOut, uint256 _gasSpent)
  {
    uint256 _gasAtStart = gasleft();
    (_amountIn, _amountOut) = sellOrderSwap(_params);
    _gasSpent = _gasAtStart - gasleft();
  }

  /// @inheritdoc ISwapPermit2Adapter
  function buyOrderSwap(BuyOrderSwapParams calldata _params)
    public
    payable
    checkDeadline(_params.deadline)
    returns (uint256 _amountIn, uint256 _amountOut)
  {
    // Take from caller
    PERMIT2.takeFromCaller(_params.tokenIn, _params.maxAmountIn, _params.nonce, _params.deadline, _params.signature);

    // Max approve token in
    _params.tokenIn.maxApproveIfNecessary(_params.allowanceTarget);

    // Execute swap
    _params.swapper.functionCallWithValue(_params.swapData, msg.value);

    // Check min amount
    _amountOut = _params.tokenOut.balanceOnContract();
    if (_amountOut < _params.amountOut) revert ReceivedTooLittleTokenOut(_amountOut, _params.amountOut);

    // Distribute token out
    _params.tokenOut.distributeTo(_params.transferOut);

    // Send unspent to the set recipient
    uint256 _unspentTokenIn = _params.tokenIn.sendBalanceOnContractTo(_params.unspentTokenInRecipient);

    // Set amount in
    _amountIn = _params.maxAmountIn - _unspentTokenIn;
  }

  /// @inheritdoc ISwapPermit2Adapter
  function buyOrderSwapWithGasMeasurement(BuyOrderSwapParams calldata _params)
    external
    payable
    returns (uint256 _amountIn, uint256 _amountOut, uint256 _gasSpent)
  {
    uint256 _gasAtStart = gasleft();
    (_amountIn, _amountOut) = buyOrderSwap(_params);
    _gasSpent = _gasAtStart - gasleft();
  }
}