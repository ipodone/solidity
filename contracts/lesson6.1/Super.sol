// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Super {
    // Solidity：面向对象编程 - 继承是面向对象编程的一个核心概念 - 合约继承（父合约、子合约）：实现代码复用、面向对象编程、模块化设计
    // Go：面向对象编程
    // Java：面向对象编程
    // 继承使用场景：权限管理功能，如onlyOwner - 需要权限管理合约：只需要继承像openzeppelin的ownable合约即可
    // 继承也有一个坏处：如果父合约改错了，所有继承了它的子合约也就全错了
    // 模块化合约：不同的功能拆分成独立的合约，如权限管理ownable、暂停功能pausable、代币功能ERC20，通过多重继承组合，提高代码组织性和可读性
    // 多重继承：使用C3线性化算法确定顺序，即继承顺序从左到右
    
    // 函数重写：多态
    // virtual：表示可以被重写、override：表示重写父合约函数、两者必须配对使用才能成功重写函数
    // 多重继承中的规则：function foo() public override(A, B) - 如果多个父合约有同名函数，必须明确指定重写哪些父合约 - 否则编译器报错

    // 构造函数继承
    // 1、参数传递方式1：继承声明中 - 适合固定值，代码简单；参数传递方式2：子构造函数中 - 部署初始化时，传参数，实际更多使用这个 - 适合动态值、更灵活、推荐实用
    // 2、执行顺序：父合约构造函数先执行、按照继承顺序从左到右、最后执行子合约构造函数

    // abstract - 声明抽象合约 - 定义基础规范、interface - 声明接口（所有函数必须是 external）- 定义标准接口
    // 接口：只能继承接口、允许定义事件

    // 通常实际开发，不会从0开始：OpenZepplin - 最受欢迎的一个标准化合约库
    // OpenZepplin合约库contracts中常用contract合约：ERC20代币功能 - 它获取了标准代币的一个功能、Ownable权限管理、Pausable暂停、ReentrancyGuard安全（防止重入攻击）
    // 继承复用：提高开发效率、降低出错的可能性；不要重复造轮子
}





contract A {
    function foo() public pure virtual returns (string memory) {
        return "A.foo";
    }
}

contract B is A {
    function foo() public pure virtual override returns (string memory) {
        return string.concat("B.foo -> ", super.foo()); // super.foo() calls A.foo
    }
}

contract C is A {
    function foo() public pure virtual override returns (string memory) {
        return string.concat("C.foo -> ", super.foo()); // super.foo() calls A.foo
    }
}

// D 继承 B 和 C。Solidity 使用 C3 线性化，并且对基类列表按“从右到左”处理。
// 对于 `contract D is B, C`，线性化顺序是：D, C, B, A。
// 因此，在 D 中调用 super.foo() 时，会先跳到线性化中的下一个合约 C。
contract D is B, C {
    // D 必须 override foo，因为它继承了 B 和 C，而 B 和 C 都提供了 foo 的实现。
    // 这里需要明确指定 override 哪些父合约的 foo。
    function foo() public pure override(B, C) returns (string memory) {
        // super.foo() 会调用线性化顺序中紧跟在 D 之后的实现。
        // 在 `D is B, C` 的情况下，顺序是 D, C, B, A，所以这里会先调用 C.foo。
        // 最终返回的字符串为："D.foo -> C.foo -> B.foo -> A.foo"。
        return string.concat("D.foo -> ", super.foo());
    }
}
// 多重继承的顺序：Solidity 使用 C3 线性化 来确定合约的继承顺序，规则是：子类在前，父类在后；从左到右的顺序（但在 super 调用时是反向的）
// 合并结果，保证顺序一致且不重复 - 关键点：super.foo() 调用的是 线性化顺序中的下一个合约
// 问题：D.foo -> C.foo（结果为：C.foo -> A.foo） -> B.foo （结果为：B.foo -> A.foo） -> A.foo 结果为啥是这？
// 我明白了：这是一个串行的链式调用结果，不存在并行：即D调C、C调B、B调A





// 简化的ERC20实现（用于演示，实际应使用OpenZeppelin）
contract ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }
    
    function _transfer(address from, address to, uint256 amount) internal {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        
        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        balanceOf[from] = fromBalance - amount;
        balanceOf[to] += amount;
        
        emit Transfer(from, to, amount);
    }
    
    function _mint(address to, uint256 amount) internal {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }
}

// 简化的Ownable实现
contract Ownable {
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        owner = newOwner;
    }
}

// 简化的Pausable实现
contract Pausable {
    bool public paused;
    
    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
    
    function _pause() internal {
        paused = true;
    }
    
    function _unpause() internal {
        paused = false;
    }
}

// 使用OpenZeppelin风格的代币合约
// 继承后，子合约可以直接访问父合约的公共和内部成员，就像访问自己的成员一样。super 只在需要明确调用父合约的函数实现时才使用。
// 包含：变量、事件、modifier、函数
contract MyToken is ERC20, Ownable, Pausable {
    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, 1000 * 10**decimals);
    }

    // 重写transfer函数，添加暂停功能
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }

    // onlyOwner修饰符确保只有所有者可以调用
    function pause() public onlyOwner {
        _pause();
    }
    
    function unpause() public onlyOwner {
        _unpause();
    }
}




// transferOwnership：转让所有权
// 
// Solidity 虽然没有 Java 的 implements 关键字，但通过以下方式实现类似功能：
// 1. 直接继承接口：contract MyContract is IInterface
// 2. 使用抽象合约作为中间层
// 3. 编译器会检查是否实现了所有接口函数
// 4. 多重继承可以同时继承多个接口
// 5. 这种设计更接近 C++ 的继承模型，允许多重继承，同时通过接口提供类型安全和约定检查。
// 
// Java 有明确的 interface 关键字：必须实现接口的所有方法；Solidity 没有专门的 implements 关键字：没有编译时强制实现接口、需要手动确保实现了接口方法
// Solidity 的"接口实现"方式（Solidity 实际上是用 继承接口 + 抽象合约 的方式）：
// 方式1：直接继承接口（不常用）- 必须实现所有函数，否则是抽象合约
// 方式2：通过抽象合约（更常见）- abstract contract ERC20 is IERC20 { // 部分实现，可能还差一些函数 - contract MyToken is ERC20 { // 只需实现剩余的函数
// Solidity 接口主要用于类型转换和约定
// 实际开发中的模式：OpenZeppelin 风格：接口 + 抽象合约 + 具体实现
// 
// string public override name; 状态变量如何继承 - 在 Solidity 中，状态变量也可以被覆盖（override），但通常更推荐使用：
// 最佳实践：推荐：使用 immutable 代替可覆盖的状态变量 - 子合约在构造函数中传递值 - immutable 变量不能被覆盖，但更安全、更省 gas
// 
// Java 的继承机制：- Java 8 引入接口默认方法后，更接近 Solidity 了
// ！1. 类（class）的单继承 - Java 确实没有多重继承（一个类不能 extends 多个类）
// 2. 接口（interface）的多重实现 - Java 允许多重实现（一个类可以 implements 多个接口）
// 3. 接口的多重继承 - Java 接口之间也可以多重继承
// ！Solidity 的类似机制：叫合约、接口、抽象合约 - Solidity 相当于把 Java 的类和接口合并了 - Solidity 中接口和合约都可以多重继承
// Java 通过接口实现多态和多重"继承"，而 Solidity 直接支持多重继承，通过 C3 线性化解决冲突。  
// 
// ！多态 = "多种形态"，即：多态 = "父类引用指向子类对象，调用的是子类的方法"
// 就像：你叫"动物"吃饭 → 具体怎么吃要看是狗还是猫、你按"开关" → 具体开灯还是开空调要看实际设备、你踩"油门" → 加速还是发电要看是油车还是电车
// 为什么要用多态？没有多态：需要很多if判断；有多态：一个方法搞定所有
// 记住三句话：继承：子类拥有父类的功能、重写：子类修改父类的功能、！多态：用父类类型调用，执行子类的实现。（继承是拿，重写是改，多态是用）
// Java中叫抽象方法、Solidity中叫抽象函数