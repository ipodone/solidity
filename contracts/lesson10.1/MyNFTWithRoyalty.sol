// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title MyNFTWithRoyalty
 * @dev 支持ERC2981版税标准的NFT合约
 * @notice 继承ERC2981接口，实现版税功能
 */
// 继承冲突：ERC721继承了ERC165，则不需要再单独继承ERC165，否则会冲突编译报错
// ERC721URIStorage 继承了 ERC721：需要重写以解决多重继承的冲突
contract MyNFTWithRoyalty is ERC721, ERC721URIStorage, Ownable, IERC2981 {
    uint256 private _tokenIdCounter;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public mintPrice = 0.01 ether;
    
    // 版税接收地址
    address private _royaltyReceiver;
    
    // 版税比例（基点，10000 = 100%）
    uint96 private _royaltyBps = 1000; // 10%
    
    event NFTMinted(
        address indexed minter, 
        uint256 indexed tokenId, 
        string uri
    );
    
    /**
     * @dev 构造函数
     * @param royaltyReceiver 版税接收地址
     * @param royaltyBps 版税比例（基点）
     */
    constructor(
        address royaltyReceiver,
        uint96 royaltyBps
    ) ERC721("MyNFTWithRoyalty", "MNFR") Ownable(msg.sender) {
        require(royaltyReceiver != address(0), "Invalid royalty receiver");
        require(royaltyBps <= 1000, "Royalty too high"); // 最大10%
        
        _royaltyReceiver = royaltyReceiver;
        _royaltyBps = royaltyBps;
    }
    
    /**
     * @dev 铸造NFT
     */
    function mint(string memory uri) public payable returns (uint256) {
        require(_tokenIdCounter < MAX_SUPPLY, "Max supply reached");
        require(msg.value >= mintPrice, "Insufficient payment");
        
        _tokenIdCounter++;
        uint256 newTokenId = _tokenIdCounter;
        
        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, uri);
        
        emit NFTMinted(msg.sender, newTokenId, uri);
        
        return newTokenId;
    }
    
    /**
     * @dev 实现ERC2981标准：获取版税信息
     * @param tokenId Token ID
     * @param salePrice 售价
     * @return receiver 版税接收地址
     * @return royaltyAmount 版税金额
     */
    function royaltyInfo( // ？这种版税和定义再市场合约里有啥区别
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (
        address receiver,
        uint256 royaltyAmount
    ) {
        receiver = _royaltyReceiver;
        royaltyAmount = (salePrice * _royaltyBps) / 10000;
    }
    
    /**
     * @dev 设置版税信息
     * @param receiver 新的版税接收地址
     * @param bps 新的版税比例（基点）
     * @notice 只有合约所有者可以调用
     */
    function setRoyaltyInfo(address receiver, uint96 bps) external onlyOwner {
        require(receiver != address(0), "Invalid receiver");
        require(bps <= 1000, "Royalty too high");
        
        _royaltyReceiver = receiver;
        _royaltyBps = bps;
    }
    
    /**
     * @dev 查询版税接收地址
     */
    function royaltyReceiver() external view returns (address) {
        return _royaltyReceiver;
    }
    
    /**
     * @dev 查询版税比例
     */
    function royaltyBps() external view returns (uint96) {
        return _royaltyBps;
    }
    
    /**
     * @dev 重写tokenURI函数
     * @notice 需要重写以解决多重继承的冲突
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    /**
     * @dev 检查接口支持
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage, IERC165)
        returns (bool)
    {
        return 
            interfaceId == type(IERC2981).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    
    /**
     * @dev 查询总供应量
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
    
    /**
     * @dev 提取铸造费用
     */
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");
        // payable(owner()).transfer(balance); // 修改成下面代码
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "withdraw failed");
    }
    // receive() external payable {} = 合约的支付宝/微信收款码，贴上就能收钱！========== 收款
    // payable(owner()).transfer(balance); 这是一个典型的合约向所有者转账的代码片段。========== 提现
    // 分解解释：
    // 逐步分解：
    // payable(owner())   // 1. 将所有者地址转换为payable地址
    // .transfer(balance); // 2. 转账指定金额
    // 等价于：
    // address payable ownerAddress = payable(owner());
    // ownerAddress.transfer(balance);
    // 普通地址（不可接收ETH），payable地址（可接收ETH）- Solidity 0.8.0+ 要求明确转换，因为普通地址不能接收转账
    // 一、安全注意事项：
    // 1. 重入攻击防护 - // 先重置余额，防止重入 // 但.transfer()的2300 Gas限制本身提供一定防护
    // 2. Gas费用考虑 - // 如果所有者是合约，且定义了receive()或fallback() // .transfer()可能因为Gas不足而失败 // 更好的做法：使用call，并处理返回值
    // 3. 访问控制 - // 确保只有所有者能调用 // 或者使用OpenZeppelin的Ownable
    // 二、实际应用场景
    // 场景1：NFT版税提现
    // 场景2：多签钱包提现
    // 场景3：分账合约
    // 三、推荐做法： // 1. 检查余额 // 2. 使用call以获得更好的兼容性 // 3. 验证结果 // 4. 触发事件
    // 四、总结：
    // payable(owner()).transfer(balance); 的核心作用是：安全转账 - 将合约的所有ETH余额转给所有者、权限控制 - 通常配合onlyOwner修饰符、简单直接 - 一行代码完成提现功能
    // 关键点：必须使用payable()转换地址类型、.transfer()会自动revert，相对安全、！！！对于现代合约，更推荐使用.call{value: ...}("")、始终记录事件以便追踪

    // NFT合约版税 vs 市场合约版税：核心区别
    // 1. NFT合约内实现版税特点：链上强制执行 - 版税逻辑写在NFT合约里、永久有效 - 除非NFT合约升级，否则无法绕过、标准接口 - 所有市场都能读取
    // 2. 市场合约实现版税特点：市场控制 - 市场决定是否执行、如何执行、可覆盖 - 市场可以忽略NFT合约的版税设置、灵活性高 - 不同市场可以有不同的版税策略
    // 3. 核心区别对比
    // 方面	NFT合约版税	市场合约版税
    // 控制权	NFT创作者/合约所有者	市场平台
    // 强制性	链上强制执行	市场自愿遵守
    // 标准化	EIP-2981标准	各市场自定义
    // 可绕过性	难绕过（需特殊合约）	容易绕过（用其他市场）
    // 更新灵活性	难更新（需合约升级）	容易更新（市场可随时改）
    // Gas成本	交易时计算版税	市场处理，用户无感
    // 最终建议：作为开发者，应该同时支持两种方式，优先读取EIP-2981，并提供市场级别的回退方案。
}