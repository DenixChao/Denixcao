// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title EgoDataAsset
 * @dev 用户数据资产NFT合约
 *
 * 功能:
 * 1. 每个用户铸造一个代表其数据资产的NFT
 * 2. 记录数据访问次数和收益
 * 3. 用户可以授权第三方访问数据
 * 4. 收益自动分配给数据所有者
 */
contract EgoDataAsset is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // EGO代币合约地址（用于收益分配）
    address public egoTokenAddress;

    // 数据资产结构
    struct DataAsset {
        address owner;              // 所有者
        string ipfsHash;           // IPFS上的加密数据哈希
        uint256 createdAt;         // 创建时间
        uint256 accessCount;       // 被访问次数
        uint256 totalEarnings;     // 累计收益
        bool isActive;             // 是否激活
    }

    // tokenId => DataAsset
    mapping(uint256 => DataAsset) public dataAssets;

    // user address => tokenId
    mapping(address => uint256) public userToToken;

    // 访问权限: tokenId => authorized addresses
    mapping(uint256 => mapping(address => bool)) public accessPermissions;

    // 事件
    event DataAssetMinted(address indexed owner, uint256 indexed tokenId, string ipfsHash);
    event DataAssetUpdated(uint256 indexed tokenId, string newIpfsHash);
    event AccessGranted(uint256 indexed tokenId, address indexed grantee);
    event AccessRevoked(uint256 indexed tokenId, address indexed grantee);
    event DataAccessed(uint256 indexed tokenId, address indexed accessor);
    event EarningsDistributed(uint256 indexed tokenId, uint256 amount);

    constructor(address _egoTokenAddress) ERC721("Ego Data Asset", "EDA") Ownable(msg.sender) {
        egoTokenAddress = _egoTokenAddress;
    }

    /**
     * @dev 铸造数据资产NFT
     * @param ipfsHash IPFS上的加密数据哈希
     * @return tokenId 新铸造的token ID
     */
    function mintDataAsset(string memory ipfsHash) public returns (uint256) {
        require(userToToken[msg.sender] == 0, "User already has a data asset");
        require(bytes(ipfsHash).length > 0, "IPFS hash cannot be empty");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _safeMint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, ipfsHash);

        dataAssets[newTokenId] = DataAsset({
            owner: msg.sender,
            ipfsHash: ipfsHash,
            createdAt: block.timestamp,
            accessCount: 0,
            totalEarnings: 0,
            isActive: true
        });

        userToToken[msg.sender] = newTokenId;

        emit DataAssetMinted(msg.sender, newTokenId, ipfsHash);

        return newTokenId;
    }

    /**
     * @dev 更新数据资产（更新IPFS哈希）
     * @param tokenId Token ID
     * @param newIpfsHash 新的IPFS哈希
     */
    function updateDataAsset(uint256 tokenId, string memory newIpfsHash) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(dataAssets[tokenId].isActive, "Data asset is not active");

        dataAssets[tokenId].ipfsHash = newIpfsHash;
        _setTokenURI(tokenId, newIpfsHash);

        emit DataAssetUpdated(tokenId, newIpfsHash);
    }

    /**
     * @dev 授权访问权限
     * @param tokenId Token ID
     * @param grantee 被授权地址
     */
    function grantAccess(uint256 tokenId, address grantee) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(grantee != address(0), "Invalid grantee address");

        accessPermissions[tokenId][grantee] = true;

        emit AccessGranted(tokenId, grantee);
    }

    /**
     * @dev 撤销访问权限
     * @param tokenId Token ID
     * @param grantee 被撤销地址
     */
    function revokeAccess(uint256 tokenId, address grantee) public {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");

        accessPermissions[tokenId][grantee] = false;

        emit AccessRevoked(tokenId, grantee);
    }

    /**
     * @dev 记录数据访问（由授权服务调用）
     * @param tokenId Token ID
     * @param accessor 访问者地址
     * @param rewardAmount 奖励金额
     */
    function recordAccess(
        uint256 tokenId,
        address accessor,
        uint256 rewardAmount
    ) public onlyOwner {
        require(dataAssets[tokenId].isActive, "Data asset is not active");

        dataAssets[tokenId].accessCount++;
        dataAssets[tokenId].totalEarnings += rewardAmount;

        emit DataAccessed(tokenId, accessor);

        // 分配收益
        if (rewardAmount > 0) {
            _distributeEarnings(tokenId, rewardAmount);
        }
    }

    /**
     * @dev 分配收益
     * @param tokenId Token ID
     * @param amount 金额
     */
    function _distributeEarnings(uint256 tokenId, uint256 amount) internal {
        address owner = ownerOf(tokenId);

        // TODO: 调用ERC20 transfer分配$EGO代币
        // IERC20(egoTokenAddress).transfer(owner, amount);

        emit EarningsDistributed(tokenId, amount);
    }

    /**
     * @dev 检查访问权限
     * @param tokenId Token ID
     * @param accessor 访问者地址
     * @return 是否有权限
     */
    function hasAccess(uint256 tokenId, address accessor) public view returns (bool) {
        // 所有者总是有权限
        if (ownerOf(tokenId) == accessor) {
            return true;
        }

        // 检查是否被授权
        return accessPermissions[tokenId][accessor];
    }

    /**
     * @dev 获取用户的数据资产信息
     * @param user 用户地址
     * @return DataAsset结构
     */
    function getUserDataAsset(address user) public view returns (DataAsset memory) {
        uint256 tokenId = userToToken[user];
        require(tokenId != 0, "User has no data asset");

        return dataAssets[tokenId];
    }

    /**
     * @dev 禁止NFT转移（数据资产绑定用户）
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        address from = _ownerOf(tokenId);

        // 只允许mint，不允许转移
        if (from != address(0)) {
            revert("Data assets are non-transferable");
        }

        return super._update(to, tokenId, auth);
    }

    /**
     * @dev 设置EGO代币地址
     * @param _egoTokenAddress 新的代币地址
     */
    function setEgoTokenAddress(address _egoTokenAddress) public onlyOwner {
        require(_egoTokenAddress != address(0), "Invalid token address");
        egoTokenAddress = _egoTokenAddress;
    }
}
