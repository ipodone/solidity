// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ^（尖角号）表示允许向后兼容的更新（^尖角号 ~波浪号 `反引号 -短横杠）
// infinite gas：极大的gas
contract HelloWorld {
    string public message;
    address public owner;

    constructor() {
        message = "Hello Solidity";
        owner = msg.sender; // 调用者地址
    }

    function updateMessage(string memory _newMessage) public {
        message = _newMessage; // 怎么和Java一样，还要加分号    
    }

    function getMessage() public view returns (string memory) {
        return message;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}