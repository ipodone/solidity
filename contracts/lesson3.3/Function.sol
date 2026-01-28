// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 理解存储="写出高质量合约"
// 理解数组特性 = 避免致命错误
// 掌握组合模式 = 掌握数据设计精髓
// 掌握函数=掌握智能合约核心

// 可见性修饰符4 - 或者叫做谁可以调用：public（公共的）、external（外部的）、internal（内部的）、private（私有的）
// 
// 状态修饰符3 - 或者叫做函数内部的限制：view（只读/视图 - 可以读取状态变量，但不能修改它们）> pure（纯函数 - 既不读取也不修改状态变量）、payable（可支付 - 可以接收以太币 - 且：没有payable修饰符，发送ETH会导致交易失败）
// 1、还有一种状态修饰符：就是什么都不加
// 2、当函数需要处理用户付款、接收手续费或实现其他需要ETH交互的功能时，必须使用payable修饰符。
// 
// 自定义修饰符：通过modifier关键字定义，用于在函数执行前添加检查 // 类似java的切面
// 常用Modifier示例：1. 权限控制 2. 状态检查 3. 参数验证 4. 最小值检查 - 组合多个Modifier
//
// 函数重载
contract Function {
    // 函数参数、可见性修饰符、状态修饰符的默认行为
    // 1、函数参数的默认存储位置：默认是memory - 函数参数默认是 `memory`（对于值类型和 bytes/string）、引用类型参数必须显式指定 storage、memory 或 calldata
    // 2、可见性修饰符的默认行为：public
    // 3、状态修饰符的默认行为：最佳实践： 能用pure就用pure，能用view就用view，提高合约可读性和效率
    // （1）无修饰符（默认）  普通函数：读取状态、修改状态2 
    // （2）view              视图函数：读取状态 3
    // （3）pure              纯函数：4
    // （4）payable           可支付函数：读取状态、修改状态、接收 ETH 1    
    // 建议：始终显式指定存储位置、显式指定可见性修饰符
    // 核心原则：不要依赖默认行为，始终显式声明意图，提高代码可读性和安全性。（如：go传参的一些简写、solidity的修饰符的默认值）

    // =====start
    // 1、uint即uint256
    // 2、状态变量默认存储在storage（storage 用在状态变量中，默认不写）
    // 3、solidity的变量：状态变量、全局变量、局部变量
    uint public num;

    modifier onlyOwner(uint _num) { // 传原函数的参数
        require(num == 0, "no equals zero");
        require(_num == 10, "no equals ten");
        _; // 占位符
    }
 
    // storage、memory、calldata
    // 存储位置修饰符只能用于引用类型（数组、结构体、映射等），不能用于值类型（即：值类型不加 - 禁止显式指定，引用类型必加 - 必须显式指定）
    // 正确用法：值类型不需要（也不能）指定存储位置、引用类型必须指定存储位置
    // 原因：值类型 vs 引用类型的存储差异
    // 值类型：直接存储值本身 - 传参：uint x 是值的副本，大小固定（32字节）；需要指定存储位置，编译器自动处理
    // 引用类型：存储的是数据的引用（指针）- 传参：uint[] memory arr 是一个指向内存数据的指针；必须明确告诉编译器这个数据在哪里
    // 
    // 对于值类型，编译器会自动处理：
    // - 在外部调用时：参数从 calldata 读取
    // - 在内部调用时：参数在 memory 中
    // 但不需要（也不能）显式指定
    // 
    // _value：除了和原数据名称定义成一样，参数可以这样定义
    function setName(uint _num) public onlyOwner(_num) {
        num = _num;
    }
    // =====end

    // 可见性+状态修饰符组合 - public payable：适用：存款、收款功能 - 最佳实践：尽可能使用最严格的修饰符组合
    // deposit：存款

    // =====start // 说明：这里不能把枚举和struct拿来作对比
    // solidity枚举和java枚举不一样：Solidity枚举确实比Java枚举简单得多，主要就是为了代码可读性和类型安全。
    // Solidity枚举是包装的整数：本质就是 命名的整数常量；Owner=0, Admin=1, User=2；只有名称和整数值，没有方法、属性；主要用于状态、选项的清晰表示。Java枚举是类实例
    // 底层就是uint8（默认）- 可以显式转换
    // uint8 ownerValue = uint8(Role.Owner);  // 0
    // Role fromValue = Role(1);  // Role.Admin
    enum Role { Owner, Admin, User } // 枚举常量，即定义了几个枚举的常量
    mapping(address => Role) public roles; // 枚举变量（只能赋一个值，而上面是常量，？和Java不一样，先这样理解），即此处可以通过构造器赋值，再赋值原值就会被替换

    // 事件
    event RoleGranted(address indexed account, Role role);
    constructor() {
        roles[msg.sender] = Role.Owner;
        roles[msg.sender] = Role.Admin;
        emit RoleGranted(msg.sender, Role.Owner);
    }

    modifier onlyOwner2 {
        require(roles[msg.sender] == Role.Owner, "is not Owner");
        _;
    }
    modifier onlyAdmin {
         require(roles[msg.sender] == Role.Admin, "is not Admin");
        _;
    }
    modifier onlyUser {
         require(roles[msg.sender] == Role.User, "is not User");
        _;
    }

    function onlyOwnerFunction() public view onlyOwner2 returns (string memory) {
        return "this is onlyOwner2";
    }
    function onlyAdminFunction() public view onlyAdmin returns (string memory) {
        return "this is onlyAdmin";
    }
    function onlyUserFunction() public view onlyUser returns (string memory) {
        return "this is onlyUser";
    }
    // =====end

    // uint256 public counter = 0; // solidity中明确支出256，即是uint等于uint256
}

contract VisibilityDemo {
    uint256 private secretNumber = 42;

    // public: 外部、内部、继承都可调用
    function publicFunction() public pure returns (string memory) {
        return "This is public";
    }

    // external: 只能外部调用（内部和继承合约都不能调用）
    function externalFunction() external pure returns (string memory) {
        return "This is external";
    }

    // internal: 内部和继承可调用
    function internalFunction() internal pure returns (string memory) {
        return "This is internal";
    }

    // private: 只能本合约内部调用
    function privateFunction() private pure returns (string memory) {
        return "This is private";
    }

    // 测试内部调用
    function testInternalCall() public pure returns (string memory) {
        return internalFunction();  // 可以调用
    }

    // 测试external不能内部调用
    // function testExternalCall() public pure returns (string memory) {
    //     return externalFunction();  // 编译错误
    // }
}

// 测试继承
contract ChildContract is VisibilityDemo {
    function testInheritance() public pure returns (string memory) {
        return internalFunction();  // 可以调用internal
        // return privateFunction();  // 不能调用private
    }
}