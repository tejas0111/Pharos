// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "./IERC20.sol";

/// @notice SafeERC20 wrapper that reverts on failure
library SafeERC20 {
    error SafeERC20__TransferFailed();
    error SafeERC20__TransferFromFailed();
    error SafeERC20__ApproveFailed();

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(token.transfer.selector, to, value));
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) revert SafeERC20__TransferFailed();
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) revert SafeERC20__TransferFromFailed();
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(token.approve.selector, spender, value));
        if (!success || (data.length > 0 && !abi.decode(data, (bool)))) revert SafeERC20__ApproveFailed();
    }
}
