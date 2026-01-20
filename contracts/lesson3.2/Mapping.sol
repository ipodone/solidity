// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 特殊：Mapping不直接存储键值对，而是通过哈希函数计算存储位置。这个Mapping好有个性
// Mapping的重要特性，就能说明其特殊的写入方式：所有键都"存在"、不存储键、不能遍历、只能用于storage、不能作为参数/返回值
// mapping(address => bool) public isUser;
// isUser[user] = true; // ✅ 是的，这是一个键值对存储操作
// 
// 不能删除整个Mapping：肯定不能查询列表和删除列表，因为它没有抓手；它只能通过key计算出哈希值位置，才能找到值
// 解决方案：为了克服不能遍历和获取长度的限制，通常会配合数组（Array）来存储键的列表，实现可遍历的Mapping。
contract Mapping {

}