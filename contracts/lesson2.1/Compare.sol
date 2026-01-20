// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Compare {
    uint256 a = 256;
    uint256 b = 123;
    string s1 = "123";
    string s2 = "123";
    address owner = msg.sender;

    // 整型比较
    function unitCompare() public view returns (bool) {
        return a == b;
    }

    // 字符串比较
    function stringCompare() public view returns (bool) {
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    // 返回调用者余额
    function balance() public view returns (uint256) {
        return owner.balance;
    }

    // 发送1ETH
    // function send() public {
    //     address payable receiver = payable(owner);
    //     receiver.transfer(1 ether); // 有问题：后面再说
    // }
}