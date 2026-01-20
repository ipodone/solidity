// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 理解存储="写出高质量合约"
// 理解数组特性 = 避免致命错误

// solidity和java数组不一样 数组的底层结构：栈，适用于栈的操作
contract Array {
    uint[] public numbers;

    // constant：编译时确定值 - 值直接硬编码在字节码中、不会占用存储槽（storage slot）
    // immutable：部署时确定值（构造函数中赋值）- 值存储在合约代码的特殊位置（不是存储槽）、部署后无法修改
    // 关键总结：constant是编译时常量，immutable是部署时常量。两者都比storage变量更省Gas，且immutable比constant更灵活，可以在构造函数中计算确定值。
    uint public constant MAX_SIZE1 = 100; // 常量（constant）
    uint public immutable MAX_SIZE2 = 100; // 只读/不可变量（immutable）
    
    function get(uint index) public returns (uint) {
        // delete 操作的陷阱：不改变数组的实际长度
        delete numbers;

        numbers.push(8);

        // Memory 中创建数组：必须在创建时指定长度、不支持 push 或 pop 操作
        uint[] memory num2 = new uint[](2);
        num2[0] = 5;

        // 数组遍历的风险：超过区块 gas 限制！———— 避免在单次交易中处理整个大型数组

        // go uint默认是多少位、solidity uint默认是多少位
        // Go：平台相关（32/64）- 实际使用时，通常使用指定大小的类型如 uint32, uint64 以确保可移植性
        // Solidity：固定256位 - uint 和 uint256 完全等价
        // Go中的uint更适合通用计算，而Solidity的uint256则是为区块链的256位虚拟机（如EVM）设计，适合处理大整数和加密货币金额。
        // uint256为什么最常用：EVM原生类型、兼容性、足够大的范围

        // 多维数组：声明顺序特殊
        // Solidity中数组声明顺序与传统编程语言相反！
        // uint[3][4] 表示4个长度为3的数组，不是3×4矩阵

        // Gas优化技巧
        // 优化技巧1：缓存 length
        // 优化技巧2：限制数组大小（使gas成本可预测、防止gas耗尽导致交易回退）
        // 优化技巧3：分批处理（防止大数组遍历风险）
        // 优化技巧4：使用 calldata - 只读（immutable）

        // 何时用数组？何时用 mapping？
        // 数组：有序集合，支持随机访问，适合小型数据集；映射：键值对存储，快速查找，适合大型数据集
        // 核心权衡： 数组和映射之间的选择主要在于可遍历性与查找效率的权衡。

        // 数组使用的常见陷阱
        // 陷阱1：delete不改变length
        // 陷阱2：越界访问
        // 陷阱3：大数组遍历
        // 陷阱4：循环中写storage - data.push(values[i]); // 每次循环都写storage - 有优化方案未实践
        // 陷阱5：memory数组push - 编译错误：不存在push方法
        
        // 数组使用最佳实践
        // 1 限制数组大小
        // 2 缓存length
        // 3 检查越界
        // 4 分批处理
        // 5 考虑用mapping替代
        // 6 使用calldata
        
        // threshold 阈值
        // Invalid range 无效范围
        // exceeds 超出

        // address(0)：代表零地址（全0地址）0x0000000000000000000000000000000000000000
        // 检查目的：防止使用无效地址（零地址）
        // 为什么需要检查：防止代币转入黑洞：转入零地址的代币将永久丢失、确保合约有有效所有者、防止将代理指向无效实现
        // 零地址的特殊用途：代币销毁、空值标记

        // mapping(address => bool) public isUser;
        // isUser[user] = true; // ✅ 是的，这是一个键值对存储操作（通过mapping不存储键的特性理解）
        // 区别于Java的map写入：map.put("Alice", 25); 
        
        // mapping和array的delete效果一样（通过mapping不存储键的特性理解）
        // 时间复杂度：O(1)检查, O(n)遍历

        return num2[index];
    }

    // 优化以下函数，至少节省 15% gas：
    // 提示：使用 calldata、缓存 length、减少 storage 操作
    // 优化前：execution cost：74166 gas
    function processBefore(uint[] memory values) public {
        for(uint i = 0; i < values.length; i++) {
            if(values[i] > 10) {
                numbers.push(values[i]);
            }
        }
    }

    // 优化后：execution cost：73097 gas      (74166-73097)/74166=1.4%
    function processAfter(uint[] calldata values) public {
        uint length = values.length;
        for(uint i = 0; i < length; i++) {
            uint value = values[i];
            if(value > 10) {
                numbers.push(value);
            }
        }
    }

    //  节省 15% gas 的目标失败：仅实现1.4% - 每次循环都写storage，未解决
    function processAfterFinal(uint[] calldata values) public {
        // 在内存中构建新数组
        uint[] memory filtered = new uint[](values.length);
        uint filteredCount = 0;

        // 内存中过滤（MLOAD/MSTORE，非常便宜）
        uint length = values.length;
        for (uint i = 0; i < length; i++) {
            uint value = values[i];
            if (value > 10) {
                filtered[filteredCount] = value;
                filteredCount++;
            }
        }

        if (filteredCount == 0) return; 

        // 批量写入 storage
        for (uint i = 0; i < filteredCount; i++) {
            numbers.push(filtered[i]);
        }
    }
}