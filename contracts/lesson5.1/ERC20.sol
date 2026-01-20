// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ERC20 {
    // 基础项目：简单代币合约
    // 掌握ERC20代币标准、第一个完整区块链项目

    // ERC20 = Ethereum Request for Comment 20 - 以太坊代币标准 - 同质化代币
    // 99%的代币项目使用ERC20

    // ERC20：
    // 6个核心函数：查询函数 (View)（totalSupply、balanceOf、allowance）、转账函数 (State-Changing)（transfer、approve、transferFrom-授权转账）
    // 2个必要事件：事件（Transfer、Approval）- Dapp可以监听这些事件
    // indexed：参数被索引，区块链浏览器可按参数过滤出事件、链下应用可按参数查询出事件

    // 授权机制 - ERC20的核心设计：允许合约代表用户操作对应代币
    // 场景：Alice想在Uniswap上用USDT买ETH
    // 为什么需要授权机制？
    // 1. 智能合约无法主动获取用户代币
    // 2. transfer只能自己转给别人
    // 3. 合约不能直接从你账户取代币
    // 4. 解决方案：授权机制
    // 5. 用户主动授权合约，合约代表用户操作
    // 6. 用户保持控制权
    //
    // 我们自己的代币授权给  uniswap合约，uniswap合约如何进行授权转账。uniswap是啥，简单说明
    // Uniswap：一个去中心化交易所（DEX），允许用户直接交换代币，无需传统交易所 - 区别于中心化交易所（CEX）
    // 举例：我要让银行帮我把100美元，换成人民币 - 银行是中间商（貌似不对，得去交易所）
    // 具体：我要CEX帮我把100美元，换成人民币 - CEX是中间商
    // 所以你要uniswap合约 dex帮你：把100USDT 换成 ETH，uniswap是不能直接做的，得你！！！授权了，他才能做（即先授权，它再做）
    // 哦：明白了，过程如下：
    // 步骤1：授权给 Uniswap 合约（前端操作）、！！！步骤2：用户在 Uniswap 前端点击"交易"、步骤3：Uniswap 合约调用 transferFrom
    // 所以，你需要uniswap帮你换代币，你需要先！！！授权给uniswap，再去uniswap页面上做实际交易，而不是你什么都不用做了 - ？Uniswap 执行转账 - 如果是自动发生，还需要再理解
    // 
    // Uniswap 核心合约架构：主要合约：用户 → Uniswap前端 → Router合约 → Pool合约
    // Router 合约（入口）：地址：0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D（以太坊主网）
    // Pool 合约（核心）：每个交易对有一个独立池子（如 ETH/USDC）
    // 
    // 实际交易示例 - 场景：用 USDT 购买你的代币
    // 前端调用流程
    // 1. 用户连接钱包
    // 2. 选择交易对：USDT → YourToken
    // 3. 输入购买数量
    // 4. 点击"Approve USDT"（第一次需要）
    // 5. 点击"Swap"（执行交易）
    // 
    // 智能合约交互流程：
    // 步骤 A：用户授权 USDT
    // USDT.approve(uniswapRouter, 100 USDT);
    // 步骤 B：Uniswap Router 执行
    // 1. transferFrom(user, router, 100 USDT)
    // 2. 找到 USDT/YourToken 流动性池
    // 3. 根据公式计算能获得多少 YourToken
    // 4. 从池子转 YourToken 给用户

    // MyToken：我的代币合约 - ERC20标准的代币合约
    // 实现transfer函数 - 直接转账 - 更新余额：先减后加（CEI模式）、不会整数溢出（0.8.0+自动检查）、原子操作，确保数据一致性
    // approve - 授权函数
    // transferFrom - 授权转账
    // approve设置授权额度、transferFrom使用授权额度，共同构成ERC20核心授权机制
    // 
    // MyToken定义过程：
    // 1、定义：状态变量、mapping
    // 2、event：使用事件记录，链下查询；不需要在链上存储所有历史记录；可以通过事件日志查询（event、indexed、emit链下日志记录）
    // 3、modifier
    // 4、构造器
    // 5、定义函数：转账函数、授权函数、授权转账函数、铸造函数（可选，需要onlyOwner）、销毁函数（可选）

    // 手动实现 与 OpenZeppelin智能合约（实际项目比较推荐实用）库实现的 区别
    // 测试网：区块链浏览器上可以验证 - 需要准备一些测试网的ETH-提供一定的gas费
}