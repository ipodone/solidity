// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 理解存储="写出高质量合约"
// 理解数组特性 = 避免致命错误
// 掌握组合模式 = 掌握数据设计精髓
// 掌握函数=掌握智能合约核心
// 在区块链上，每一行代码都关系到真金白银。安全永远是第一位的。

// require 需要/验证
// assert 断言
// revert 恢复/回滚

// Solidity中的特殊考量：
// 1、Gas成本：循环次数越多，消耗的Gas成本越高，可能导致交易失败。
// 2、无限循环风险：无限循环会导致Gas耗尽，交易回滚，并可能造成资金损失。
contract ControlFlow {
    // if if-else else if（用分数分级说明） 三元运算符：else if可以用>=90返回A、>=80返回B、>=70返回C、>=60返回D，否则返回F说明
    // if（2） if-else（3） 三元运算符（1）：在简单功能中，效果一样；但使用优先顺序看前面标号数字（也可以说省gas优先顺序）
    // 三元运算符嵌套（不推荐过度使用）
    // 在智能合约开发中，代码越简洁通常gas效率越高，因为：更少的操作码、更少的JUMP指令、编译器更容易优化
    function checkAge(uint age) public pure returns (bool){
        // if (age >= 18) { // 更多的指令 = 更多的gas
        //     return true;
        // }
        // return false;
        return age >= 18; // 更少的指令 = 更少的gas
    }

    // for/while（倒计数 - 类似倒数10个数 - 先判断再执行）/do-while（先执行再判断）循环 - break和continue
    // 循环的Gas成本与安全实践：危险示例：无限制循环：当数组元素过多时，Gas消耗会线性增长，可能触及区块Gas限制，导致交易失败。
    // 1、限制循环次数：使用require限制数组长度，避免过多迭代。
    // 2、使用Mapping：利用mapping实现O(1)查询，避免循环遍历。
    // 3、分批处理：每次处理少量数据，分多次交易完成，降低单次Gas消耗。
    // ！4、链下计算：前端计算后只提交结果到链上，节省Gas消耗。

    // 错误处理：require、assert与revert
    // 1、require：用于 外部输入验证 和 前置条件检查（使用频率很高）
    // 2、assert：用于 内部检查 和 不变量验证（debugger）
    // 3、revert：用于 灵活错误处理和自定义错误（自定义错误节省Gas，支持参数，类型安全）
    // require 与 assert 的关键区别：前者： 外部验证、失败原因是用户错误；后者：内部检查、失败原因是代码bug
    //
    // 自定义错误 vs 字符串错误：Gas消耗: 自定义错误 ~节省50%；参数支持: 自定义错误 支持；类型安全: 自定义错误 提供
    // 错误处理最佳实践：尽早检查、清晰消息、优化检查顺序、防御性编程、减少嵌套、一致性（智能合约：一般人/一个人写不了）

    // 投票系统合约、状态机模式（实际应用：众筹系统）
    // contributions贡献、Eligible符合条件、expectedState预期状态
    // durationInDays持续时间（天数）、positive积极的、totalFunded总资助额、refund退款
    // remaining剩余的
    // 
    // 众筹系统定义过程：这个众筹还挺麻烦的
    // 1、定义：枚举、状态变量、mapping
    // 2、event：使用事件记录，链下查询；不需要在链上存储所有历史记录；可以通过事件日志查询（event、indexed、emit链下日志记录）
    // 3、modifier
    // 4、构造器
    // 5、定义函数：开始众筹、贡献资金、结束众筹、退款（众筹失败时）—— 这不就是非法集资吗
    // msg.sender说明：谁发布合约，这个地址就是谁；谁调用/执行/操作函数/代码，这个地址就是谁 - 这个地址是账户地址
    // 众筹失败后，各自手动申请退款
    // 
    // 前面有：投票系统设计、用户管理设计、角色管理设计
    // 
    // 投票/提案系统定义过程：
    // 1、定义：struct、状态变量、mapping
    // 2、event
    // 3、modifier
    // 4、构造器
    // 5、定义函数：创建提案、投票、获取提案详情、获取获胜提案 - 投票系统就是填系统，因为投票系统里就是一个一个的提案
    // 
    // 延续李舟说的代码书写格式：枚举;单独写、函数参数/或返回值太多时换行写，同时{换行



    // totalSupply总供应量、mint发币、Insufficient不足、urgent紧急

    // event：区块链的日志系统，便宜且永久 ———— event定义事件、emit调用事件
    // indexed：让事件参数可过滤，提高查询效率
    // 使用场景：前端监听、数据分析、通知用户、！链下追踪

    // 嵌套循环 - 乘法表
    function multiplicationTable(uint n) public pure returns (uint[][] memory) {
        uint[][] memory table = new uint[][](n);
        for (uint i = 0; i < n; i++) {
            table[i] = new uint[](n);
            for (uint j = 0; j < n; j++) {
                table[i][j] = (i + 1) * (j + 1);
            }
        }
        return table;
    }
}