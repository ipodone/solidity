// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 理解存储="写出高质量合约"
// 理解数组特性 = 避免致命错误
// 掌握组合模式 = 掌握数据设计精髓
// 掌握函数=掌握智能合约核心
// 在区块链上，每一行代码都关系到真金白银。安全永远是第一位的。

// mapping只能用于storage、另含有mapping的struct也仅能用于storage

contract Struct {
    // 一、Mapping + Array 组合模式：可遍历的Mapping
    // 问题： Mapping不能遍历，无法获取长度 → 解决方案： 配合Array使用
    // 这个组合模式是Solidity数据结构设计中的！核心模式，既保留了Mapping的快速查找优势，又通过Array弥补了其不可遍历的不足
    mapping(address => uint) balances; // 用户地址mapping => 余额：用于查找
    address[] userList; // 用户地址array：用于遍历
    mapping(address => bool) isUser;

    // 二、Mapping + Struct 组合模式：快速查找复杂数据
    // 优势：Mapping提供O(1)的查找速度、Struct能够组织多个相关字段、exists字段解决默认值混淆问题
    // 应用场景：用户管理系统、资产信息管理、复杂实体关系建模
    // 
    // 在Solidity的Mapping中，查询任何一个键都会返回其值类型的默认值
    // exists字段的重要性：解决问题：默认值混淆；无法区分：余额返回0，可能是因为：1. 用户余额确实是0 2. 用户从未在合约中注册
    struct UserInfo {
        string name;
        uint balance;
        bool exists; // 重要
    }
    mapping(address => UserInfo) users;

    // 三、完整的Mapping+Struct+Array组合
    // 0、定义结构体
    struct UserInfo2 { // struct组织多个相关字段
        string name;
        uint balance;
        uint registeredAt;
        bool exists;
    }
    // 1、核心：mapping存储用户信息
    mapping(address => UserInfo) public users2; // mapping用于查找
    // 2、辅助：数组存储所有用户地址
    address[] public userAddresses; // array用于遍历
    // 3、用户总数
    uint public userCount; // 计数

    // Struct中包含Mapping：Struct中包含Mapping是一种强大的模式，用于管理实体内部的复杂关系
    // 限制条件：只能在storage中声明和使用、不能作为函数参数或返回值、不能在memory或calldata中创建（即mapping的特性）
    // 应用场景：投票系统（一个提案需要记录哪些地址已投票）、权限管理（记录哪些地址有特定权限）
    struct Proposal {
        string description;
        uint voteCount;
        mapping(address => bool) voters;  // 嵌套mapping
        bool exists;
    }
    // 1、核心：mapping存储提案信息
    mapping(uint => Proposal) public proposals;
    // 2、提案总数
    uint public proposalCount;

    // 常见的数据结构模式：用户管理、ID索引、双向映射、关系映射、计数器
    // 设计要点：根据业务需求选择合适的模式、组合模式解决更复杂的问题、考虑Gas成本和数据访问频率、合理使用索引优化查询效率

    // Mapping和Struct最佳实践
    // 1、设计原则：使用Struct组织复杂数据，提高代码可读性；使用Mapping实现O(1)快速查找；配合Array实现遍历所有数据项；添加exists字段明确标记记录是否存在；使用计数器追踪集合中元素数量
    // 2、Gas优化：限制Array大小，避免Gas消耗过多；分批查询，降低单次交易Gas消耗；考虑数据访问频率，选择合适存储位置；外部函数优先使用calldata，内部函数使用memory
    // 3、命名规范：Mapping使用复数或"to"；Struct使用单数名词
    // 4、exists字段使用：解决方案：在Struct中添加bool exists字段（问题：Mapping中无法区分"值是默认值"和"从未设置"）

    // process 过程/处理
}