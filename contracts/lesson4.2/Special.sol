// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 看来此处：keccak256哈希函数用的最多
// solidity函数中说到的内部、外部：其实是相对于当前合约的内部和外部
contract Special {
    // address 以太坊地址：address、address payable - 需显式使用payable(addr)转换为address payable - 此处的payable是payable的，不是address的
    // 分为：外部账户（EOA）地址、合约账户地址（合约部署后确定）
    // 20字节（160位）；十六进制编码，以"0x"开头：0x742d35Cc6634C0532925a3b844Bc454e4438f44e（0x+20个数字或字母、每个数字或字母占1个字节8位，即20字节160位）
    // 
    // 账户地址：账户就是一个地址
    // 以太币余额：单位wei（1 ether = 10^18 wei）- 页面显示单位：ETH、代码标记单位：ether
    // 转账方法：
    // .transfer() - Gas限制为2300
    // .send() - 与transfer类似，但失败时不会自动回退，而是返回一个布尔值表示成功或失败
    // .call() - 通用底层调用方法。可以用于调用其他合约的函数，或向地址转账。返回布尔值表示调用是否成功
    // 
    // 转账安全 - 重入攻击风险：由于 balances 尚未更新，攻击者可重复提取资金
    // ！！！CEI模式 (Checks先检查-Effects后更新-Interactions最后调用) - 智能合约安全的黄金法则，防止重入攻击 - 总是先更新状态，再进行外部调用

    // 全局变量：Solidity提供的一组内置特殊变量，允许智能合约访问关于区块链、交易和当前调用上下文的丰富信息
    // 全局变量是Solidity的关键特性，正确使用它们可以简化开发并提高合约安全性
    // 1、msg对象:包含当前函数调用的相关信息 - 调用信息 - msg.value：uint (单位：wei)
    // 2、block对象:提供当前区块的链上环境信息 - 区块信息
    // blockhash(uint blockNumber) - 只能获取最近256个区块的哈希
    // block.gaslimit：当前区块的Gas限制
    // block.coinbase：挖出当前区块的矿工地址 - ？其实对于挖矿的概念、矿工的概念、挖矿的过程我还是不理解
    // block.difficulty：当前区块的难度值（现为block.prevrandao的别名）
    // 3、tx对象:包含交易相关的信息 - 慎用，可能存在安全风险 - tx.origin：交易的原始发送者（EOA）- 在权限检查中使用tx.origin可能导致严重的安全隐患
    // 4、重要全局函数:Solidity提供的实用函数
    // 
    // 重要的全局函数 - ？应用场景待实践
    // gasleft()：返回当前交易剩余的Gas数量
    // keccak256()：执行Keccak-256哈希函数
    // abi.encode()：执行ABI编码

    // 枚举：有默认值 示例：Pending(0) - 即不需要构造函数
    // 状态机设计模式：状态机设计模式通过枚举类型来管理合约的生命周期或流程状态，确保操作在正确的状态下执行
    // 众筹合约 - 非法集资

    // solidity变量类型：局部变量、状态变量（Java中叫属性）、全局变量
    // 写太多没有意义：多读读记到脑子里
    // 1 ether：1个以太币ETH，可以在转账时用；deadline = block.timestamp + 7 days：days天的单位，可以在计算时用；Java中没有这个东西
    // 没有指名单位时，单位为：wei（1 ether = 10^18 wei）

    // ！！！优先使用call方法进行转账，并检查返回值；避免使用transfer和send而不检查返回值（防止重入攻击） - ？需要理解
    // 最佳实践: 安全性与Gas优化同等重要，优先确保合约安全，再考虑优化Gas成本。在众筹合约中，同时应用了这些安全和优化技巧。

    // uint256 amount = address(this).balance; this简单说明：1. 'this' -> 当前合约实例 2. address(this) -> 转换为地址类型 3. .balance -> 获取该地址的ETH余额
    // this 指的是 当前合约实例本身：假设这是合约 MyContract，'this' 就是 MyContract 的实例地址
    // 要接收ETH，必须有：1. receive() 函数 或 2. fallback() 回调函数标记为 payable

    // contributions[msg.sender] = 0;require(success, "Failed to refund");require会回滚前面那个赋值吗 - 会回滚
    // Solidity 的事务特性：1. 原子性（Atomicity） 2. 回滚（Revert）机制 - 为什么这样设计？（防重入攻击）
    // 错误处理函数：
    // require - 用于输入验证，会回滚，退回剩余gas
    // assert - 用于内部错误检查，会消耗所有gas - // 更严格，用于不应该发生的错误
    // require、assert、revert：都会回滚
    // 转账函数：
    // ！transfer(小gas)：失败处理：自动回退(revert) - 安全性：相对安全，失败即回退 - 推荐度：传统安全方案
    // send()：失败处理：返回false，不自动回退 - 安全性：易出错，可能导致资金丢失 - 推荐度：不推荐（易出错）
    // ！！！call(大gas)：失败处理：返回false，不自动回退 - 安全性：最灵活，但存在重入风险 - 安全性：最灵活，但存在重入风险（！！！即CEI）- 推荐度：推荐（2024年后）

    // 实际：我自己个人也可以发布合约、发币 - 别人买币，你就能获得人民币 - 但中国法律不承认这种东西，即你的这种行为不受到保护
    // 即，有的人买币，平台倒闭了，你的钱就玩玩了 - 不像你放到银行、基金、股票，是中国法律成人的
    // 而且中国法律会认为这是犯法的，有人举报你，你就会被抓 - 所以你要弄，只能去国外：当前1BTC=63万人民币、1ETH=2万人民币

    // ？？？1规划投票合约+系统、众筹合约+系统、链上链下：两个系统需要自己完整完成：2需求、3设计、4开发、5测试、6部署上线运维
    // 接收以太币
    // receive() external payable {}
    // uint public constant MAX_SUPPLY = 1_000_000;
    // 接收函数，记录msg.data无法在receive中使用，因此只记录sender和value
    // receive() external payable {
    //     emit PaymentReceived(msg.sender, msg.value, "");
    // }
}