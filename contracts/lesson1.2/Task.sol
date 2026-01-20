// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// slot位置/槽 pure纯函数 Transaction交易 Optimization优化
contract Task { 
    uint[] public data;

    // 这个函数有很多优化空间 - 内存数组（如函数参数）
    function processData(uint[] calldata input) public { // 优化1：memory改成calldata
        delete data;  // 清空数组
        uint256 len = input.length; // 优化2：
        for(uint i = 0; i < len; i++) {
            data.push(input[i] * 2);
        }
    }

    // 这个函数也可以优化 - 存储数组
    // 
    // for循环长度缓存说明
    // 1、正常情况下，优化是有效果的
    // 2、非正常情况下，优化无效果，即数组为空时，优化无效果，即未进入for循环内进行计算
    // 3、solidity有优化器，但此处通过测试，优化器未进行优化
    // 
    // Optimization优化：函数调用频率
    // --optimize-runs 20：这个 200 表示优化器假设每个函数将被调用大约 200 次（在整个合约生命周期内）
    // runs 值	优化重点	    循环可能被优化为
    // 1	    部署成本最小化	保持简单循环，代码紧凑
    // 200	    平衡	        可能缓存 length，适度展开循环
    // 10000	执行速度最大化	循环展开，内联优化，激进缓存
    function getSum() public view returns (uint) { // for循环长度缓存
        uint sum = 0;
        // uint len = data.length; // 数组空-优化200/0-2322gas（大）、数组空-优化未选-2478gas（大）
                                // 数组有1-优化200/0-4728gas、数组有1-优化未选-5004gas
        for(uint i = 0; i < data.length; i++) { //  数组空-优化200/0-2310gas、数组空-优化未选-2466gas
                                        // 数组有1-优化200/0-4851gas（大）、数组有1-优化未选-5099gas（大）
            sum += data[i];
        }
        return sum;
    }
}