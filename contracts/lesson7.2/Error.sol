// require(balance >= amount, "余额不足");        balance和amount都为0也能进行交易操作      非零的这种判断在前端还是后端
// 必须在智能合约（后端）验证：您指出的情况 balance >= amount 当两者都为0时可以通过验证，但这不是bug而是正确设计
// 结论：
// 1. 智能合约验证是必须的 - 安全性保障
// 2. 前端验证是优化的 - 用户体验
// 3. amount=0能通过是正常的 - 零额转账有合法用途（如激活合约）
// 4. 防御性编程 - 永远不要信任前端输入
// 规则：前端为用户体验验证，智能合约为安全性和正确性验证。两者都需要，但合约验证是不可或缺的最后防线。 

// try-catch异常捕获：外部调用时使用try-catch捕获异常，避免合约执行中断

// ！！！1、require gas较低/assert 全部gas/revert 中等gas - 这三者都可以用自定义错误（优先使用require+自定义错误） 2、自定义错误（省gas 可读性好 优先推荐首选） 3、try-catch（外部合约调用）
// 代码复用 - 减少重复代码 - 抽出来独立出来
// 好的代码命名 - 自解释

// （同质化代币）代币合约 - 使用require检查余额不足情况，自定义错误提高Gas效率
// （非同质化代币）拍卖合约 - 使用assert验证前置条件，revert处理竞价无效情况
// ？多签钱包 - 结合try-catch处理不同执行结果，确保交易安全性
// 根据场景选择合适的错误处理机制、优先使用自定义错误提高Gas效率、结合场景需求设计错误处理流程
// assert-出现错误，可能存在严重bug（错误触发时，require/revert会释放gas，assert不会）：交易不可恢复 - 用的少 - 最佳实践：优先使用require进行输入验证，assert用于内部一致性检查，revert用于自定义错误条件。

// Auction拍卖合约定义过程：NewBid新标新的拍卖 BidRefunded拍卖退款 AuctionWon竞拍成功 highestBid最高出价 - 先学会技术，更重要的还是应用于业务
// 1、自定义错误error
// 2、状态变量、mapping
// 3、事件event
// 4、自定义修饰符modifier
// 5、构造函数constructor
// 6、函数
// MyToken定义过程：
// 1、定义：状态变量、mapping
// 2、event：使用事件记录，链下查询；不需要在链上存储所有历史记录；可以通过事件日志查询（event、indexed、emit链下日志记录）
// 3、modifier
// 4、构造器
// 5、定义函数：转账函数、授权函数、授权转账函数、铸造函数（可选，需要onlyOwner）、销毁函数（可选）
//  
// try-catch两种示例：
// 示例1；try {
// 示例2：try token.transfer(to, amount) returns (bool success) {
// 示例2说明：返回值处理‌：在try ... catch结构中，如果你使用了returns关键字从函数调用中获取返回值，那么在catch块中将无法捕获到具体的错误原因（除非你在调用函数时使用了自定义的错误类型）

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract GasComparison {
    uint256 public value = 100;

    // 自定义错误
    error ValueTooHigh(uint256 current, uint256 max);
    error ValueTooLow();

    // require + 字符串
    function testRequireString(uint256 amount) public {
        require(amount <= value, "Value too high");
        value = amount;
    }

    // require + 自定义错误
    function testRequireCustomError(uint256 amount) public {
        if (amount > value) revert ValueTooHigh(value, amount);
        value = amount;
    }

    // assert
    function testAssert(uint256 amount) public {
        value = amount;
        assert(value <= 1000);
    }

    // revert + 字符串
    function testRevertString(uint256 amount) public {
        if (amount > value) revert("Value too high");
        value = amount;
    }

    // revert + 自定义错误
    function testRevertCustomError(uint256 amount) public {
        if (amount > value) revert ValueTooHigh(value, amount);
        value = amount;
    }

    // 触发错误的辅助函数
    function triggerRequireString() public {
        testRequireString(200);
    }

    function triggerRequireCustomError() public {
        testRequireCustomError(200);
    }

    function triggerAssert() public {
        testAssert(2000);
    }

    function triggerRevertString() public {
        testRevertString(200);
    }

    function triggerRevertCustomError() public {
        testRevertCustomError(200);
    }
}