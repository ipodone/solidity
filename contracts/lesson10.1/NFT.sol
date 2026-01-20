// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFT {
    // NFT市场：NFT市场是一个去中心化的数字资产交易平台，用户可以在这里铸造、展示、买卖和拍卖NFT。- OpenSea
    // 基础项目：简单代币合约 - ERC20 同质化代币
    // 进阶项目：NFT市场 - ERC721 非同质化代币

    // 1、ERC721核心接口与元数据扩展 - 返回tokenId的元数据URI：指向知识库文件 "https://api.example.com/token/1"
    // ERC721核心接口：balanceOf查询某个地址的NFT数量、ownerOf查询某个NFT的所有者、saferTransferFrom安全转移NFT、approve批准其他地址操作你的NFT、setApprovalForAll批准操作者操作你的所有NFT
    // ERC721元数据扩展：name NFT集合名称、symbol NFT集合符号、tokenURI 返回tokenId的元数据URI
    
    // 2、NFT合约设计与铸造功能 - 铸造流程：增加计数器、创建NFT、设置元数据并返回
    // 实际开发中：不需要从零实现ERC721标准的所有函数，直接使用OpenZeppelin（ERC721、ERC721URIStorage、Ownable、Counters）
    // using Counters for Counters.Counter; Counters.Counter private _tokenIds; // 修正变量名并改为 private
    // 继承后，子合约可以直接访问父合约的公共和内部成员，就像访问自己的成员一样。super 只在需要明确调用父合约的函数实现时才使用：
    // 1. _safeMint方法来自父合约ERC721（此方法在此合约中有重载）、_setTokenURI方法来自父合约ERC721URIStorage
    // 2.1 tokenURI 同时实现override(ERC721、RC721URIStorage)：因为ERC721、RC721URIStorage)：因为都有tokenURI的方法
    // 2.2 super.tokenURI(tokenId); // 调用父合约的tokenURI方法 - 执行顺序为：当前函数方法 ->  ERC721URIStorage函数方法 -> ERC721函数方法，最终返回，执行顺序与继承顺序相反
    // 2.3 function tokenURI(uint256 tokenId) public view virtual override returns (string memory) - ERC721URIStorage中tokenURI重写了父合约的函数，并设置自己virtual可被重写
    // MAX_SUPPLY最大供应量 - 就像一个小区最多有多少户；MINT_PRICE铸造价格0.01ETH - 防止恶意用户大量铸造、同时给项目方提供一定的收入来源；NFTMinted事件 - 记录每次铸造的详细信息 - 事件在链上是永久记录的 - 通过事件可以跟踪对应历史，建立对应索引（事件被区块链浏览器捕获） - 前端也可以建立索引，实时更新页面（也可以被链下服务监听）
    
    // 3、交易市场合约结构与上架功能 - NFT非同质化代币（如艺术品 - 如画画）、NFT合约（即合约 - 定价格）、NFT交易市场（即市场平台 - 定在那里卖）
    // 交易市场合约：可类似代币交换合约，都是中间平台合约
    // NFT都是在交易市场进行交易的：市场合约是一个独立的合约，他会与各种NFT合约进行交互
    // 上架：listNFT
    // 授权检查：市场合约需要有权限来转移用户的NFT，否则在购买时无法完成转移。
    // 两种授权方式：approve对单个NFT授权-对应检查函数getApproved、setApprovalForAll对所有NFT进行授权-对应检查函数isApprovedForAll
    // 返回listingID挂单ID - 卖家要知道自己的挂单ID，方便后续管理

    // 4、购买功能设计与实现 - 手续费，即平台抽成 - ReentrancyGuard（nonReentrant修饰符）防止重入攻击、CEI（先更新再调用）、调用用call（调用后进行返回值检查）- 低级的call使用，比transfer更安全，可以检查返回值（call可以自定义gas - transfer、send不行仅2300gas）
    // 购买：buyNFT

    // 5、版税系统设计与实现 - seller卖家、royalty版税
    // 1. ERC2981是NFT版税标准，允许创作者在NFT转售时获得持续收益。
    // 2. 需要检查NFT合约是否支持ERC2981的标准，使用像IERC165的supportsInterface方法来检查：(bool success) = IERC165(nftContract).supportsInterface(type(IERC2981).interfaceId);
    // 如果支持的话，我就可以调用royalyInfo获取版税信息
    // 在购买函数中，需要增加资金分配的一个逻辑；卖家收益=售价-平台手续费-版税
    // 执行分配顺序：先支付版税给创作者、然后支付平台手续费、最后支付卖家收益 - 这个顺序很重要，可以创作者优先获得创作收益
    // 如果NFT合约支持版税，版税金额会自动从售价中扣除，即版税扣除的逻辑在NFT合约中，不在市场合约中 - 也可能不是，看实际案例及代码

    // 6、拍卖系统设计与实现 - withdrawBid提取出价
    // 拍卖方式：英式拍卖（最常用-起拍价有卖家设定，买家可以进行出价）、荷兰式拍卖

    // 市场合约结构：
    // 1. Listing 数据结构
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
    }
    // 2. 数据映射
    mapping(uint256 => Listing) public listings;
    uint256 public listingCounter;
    // 
    // 拍卖合约结构：
    // 1. 拍卖数据结构
    struct Auction {
        address seller; // 卖家地址
        address nftContract; // NFT合约地址
        uint256 tokenId; // NFT的tokenId
        uint256 startPrice; // 起拍价
        uint256 highestBid; // 当前最高出价
        address highestBidder; // 当前最高出价者

        uint256 endTime; // 结束时间
        bool active; // 是否激活
    }
    // 2. 数据映射
    mapping(uint256 => Listing) public auctions;
    uint256 public auctionCounter;
    // 
    // 3. 总结：两者结构类似，都是：一个结构体、一个mapping、一个计数器
}