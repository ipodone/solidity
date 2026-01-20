// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 理解存储="写出高质量合约"
// 理解数组特性 = 避免致命错误
// 掌握组合模式 = 掌握数据设计精髓
// 掌握函数=掌握智能合约核心
// 在区块链上，每一行代码都关系到真金白银。安全永远是第一位的。
// 事件是连接智能合约与外部世界的桥梁

contract Event {
    // 事件查询和监听：使用Web3.js监听事件、使用ethers.js监听事件

    // 区块链基础：状态数、交易数、数据数（交易日志）

    // 匿名事件：不能被外部监听，只能通过日志去过滤，适用于：如状态变更的场景

    // Remix中：普通事件：logs和raw logs原始日志都有日志；匿名事件：无logs，只有raw logs原始日志

    // 代币转账（ERC20 - 同质化代币）和NFT交易（ERC721 - 非同质化代币 - 这幅数字艺术品以非同质化代币形式出售）简单说明
    // 一、代币转账（Token Transfer）
    // 1、同质化代币（ERC20）
    // 2、流程示例
    // 用户A转账100 USDT给用户B：
    // 1. 检查A余额 >= 100
    // 2. A余额 -= 100
    // 3. B余额 += 100
    // 4. 触发 Transfer(A, B, 100) 事件
    // 3、特点：可分割：1个代币可分为0.000001等、统一价值：每个代币完全相同、批量转账：一次可转任意数量
    // 二、NFT交易（NFT Transfer）
    // 1、ERC721 - 最常用标准、ERC1155 - 半同质化标准
    // 2、交易流程
    // 交易NFT #123：
    // 1. 验证调用者是所有者或被授权
    // 2. 检查接收方能否接收NFT（防丢失）
    // 3. 所有权转移：NFT #123 从A转移到B
    // 4. 更新所有者映射：ownerOf[123] = B
    // 5. 触发 Transfer(A, B, 123) 事件
    // 
    // 关键区别
    // 方面	   代币转账	         NFT交易
    // 单位	   数量（amount）	特定ID（tokenId）
    // 唯一性	同质化	        唯一、非同质化
    // 价值	    统一	        各不相同的稀缺性价值
    // 传输	    部分转账	    整体转移（1个NFT）
    // 常见用途	 货币、股票、积分	艺术品、游戏道具、房产
    // 
    // 安全考虑：代币：防止整数溢出、重入攻击；NFT：防伪造、验证所有权链、接收合约安全检查
    // 本质上：代币是"钱"的转移，NFT是"产权证书"的转移。
}

contract EventDemo {
    // 定义一个简单的Transfer事件
    event Transfer(address indexed from, address indexed to, uint256 value);

    // 定义一个包含更多信息的事件
    event DataUpdate(
        address indexed user,
        uint256 indexed id,
        string data,
        uint256 timestamp
    );

    mapping(address => uint256) public balances;

    constructor() {
        balances[msg.sender] = 1000;
    }

    // 转账函数，触发Transfer事件
    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        // 触发事件
        emit Transfer(msg.sender, to, amount);
    }

    // 更新数据函数，触发DataUpdate事件
    function updateData(uint256 id, string memory data) public {
        emit DataUpdate(msg.sender, id, data, block.timestamp);
    }
}

contract AnonymousEventDemo {
    // 普通事件：最多3个indexed参数
    event RegularEvent(
        address indexed a,
        address indexed b,
        address indexed c,
        uint256 value
    );

    // 匿名事件：最多4个indexed参数
    event MyEvent(
        address indexed a,
        address indexed b,
        address indexed c,
        address indexed d,
        uint256 value
    ) anonymous;

    function triggerRegularEvent() public {
        emit RegularEvent(
            address(0x1),
            address(0x2),
            address(0x3),
            100
        );
    }

    function triggerAnonymousEvent() public {
        emit MyEvent(
            address(0x1),
            address(0x2),
            address(0x3),
            address(0x4),
            200
        );
    }
}