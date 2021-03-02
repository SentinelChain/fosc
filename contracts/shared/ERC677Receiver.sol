// SPDX-License-Identifier: Unlicense

pragma solidity 0.6.12;


abstract contract ERC677Receiver {
    function onTokenTransfer(address _from, uint _value, bytes memory _data) virtual external returns(bool);
}
