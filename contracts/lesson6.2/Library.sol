// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Library {
    // 库合约
    // 库合约使用：using A for B; // 函数附加 - 非常优雅的语法糖 - 不允许声明状态变量，保证纯粹性
    // OpenZeppelin：SafeMath（0.8.0之前用）、Strings、数组
    // 优先使用内部库（编译时嵌入调用合约）；当多个合约需要共享一个库的话，使用外部（需要单独部署）- 两者调用方法不一样
    // 使用库的合约 - 传统方式：需要显式指定库名 - uint256 sum = MathLib.add(x, y);uint256 product = MathLib.mul(sum, 2);
    // 使用库的合约 - using for方式：using MathLib for uint256; - 更自然的调用方式uint256 sum = x.add(y);uint256 product = sum.mul(2);、链式调用a.add(b).mul(c).div(2);

    // 库合约的使用：内部库合约、外部库合约、调用内部库合约、调用外部库合约在一个文件里
    // 从实际情况来看：调用内部库和外部库两种方式都可以，只是using for更优雅；而且外部库也不需要单独部署，可能是合约部署时，外部库也同时自动单独部署了 - ？实际用时再理解之前和这块不理解的地方

    // 快速删除分两步：1、数组：最后一位值移动到要删除的位置 2、mapping映射更新：最后一位值的索引更新为要删除的内容索引 3、数组pop mapping删除要删除位置的值索引
}