// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title EgoToken
 * @dev $EGO代币 - Ego平台的生态代币
 *
 * 代币用途:
 * 1. 数据访问奖励
 * 2. 内容创作激励
 * 3. 治理投票
 * 4. 高级功能解锁
 */
contract EgoToken is ERC20, ERC20Burnable, Ownable {
    // 最大供应量: 1亿
    uint256 public constant MAX_SUPPLY = 100_000_000 * 10**18;

    // 挖矿速率控制
    uint256 public rewardPerAccess = 1 * 10**18;  // 每次数据访问奖励1个EGO
    uint256 public rewardPerLike = 0.1 * 10**18;  // 每个点赞奖励0.1个EGO

    // 授权的奖励分配者（如后端服务）
    mapping(address => bool) public rewardDistributors;

    // 事件
    event RewardDistributed(address indexed recipient, uint256 amount, string reason);
    event RewardDistributorAdded(address indexed distributor);
    event RewardDistributorRemoved(address indexed distributor);
    event RewardRateUpdated(uint256 newAccessReward, uint256 newLikeReward);

    modifier onlyRewardDistributor() {
        require(rewardDistributors[msg.sender] || msg.sender == owner(), "Not authorized to distribute rewards");
        _;
    }

    constructor() ERC20("Ego Token", "EGO") Ownable(msg.sender) {
        // 初始供应: 10%给团队和生态基金
        _mint(msg.sender, MAX_SUPPLY / 10);
    }

    /**
     * @dev 分配数据访问奖励
     * @param recipient 接收者
     */
    function distributeAccessReward(address recipient) public onlyRewardDistributor {
        require(totalSupply() + rewardPerAccess <= MAX_SUPPLY, "Exceeds max supply");

        _mint(recipient, rewardPerAccess);

        emit RewardDistributed(recipient, rewardPerAccess, "data_access");
    }

    /**
     * @dev 分配点赞奖励
     * @param recipient 接收者
     */
    function distributeLikeReward(address recipient) public onlyRewardDistributor {
        require(totalSupply() + rewardPerLike <= MAX_SUPPLY, "Exceeds max supply");

        _mint(recipient, rewardPerLike);

        emit RewardDistributed(recipient, rewardPerLike, "content_like");
    }

    /**
     * @dev 批量分配奖励
     * @param recipients 接收者数组
     * @param amounts 金额数组
     * @param reason 原因
     */
    function batchDistributeRewards(
        address[] memory recipients,
        uint256[] memory amounts,
        string memory reason
    ) public onlyRewardDistributor {
        require(recipients.length == amounts.length, "Arrays length mismatch");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(totalSupply() + totalAmount <= MAX_SUPPLY, "Exceeds max supply");

        for (uint256 i = 0; i < recipients.length; i++) {
            _mint(recipients[i], amounts[i]);
            emit RewardDistributed(recipients[i], amounts[i], reason);
        }
    }

    /**
     * @dev 添加奖励分配者
     * @param distributor 分配者地址
     */
    function addRewardDistributor(address distributor) public onlyOwner {
        require(distributor != address(0), "Invalid address");
        rewardDistributors[distributor] = true;

        emit RewardDistributorAdded(distributor);
    }

    /**
     * @dev 移除奖励分配者
     * @param distributor 分配者地址
     */
    function removeRewardDistributor(address distributor) public onlyOwner {
        rewardDistributors[distributor] = false;

        emit RewardDistributorRemoved(distributor);
    }

    /**
     * @dev 更新奖励速率
     * @param newAccessReward 新的访问奖励
     * @param newLikeReward 新的点赞奖励
     */
    function updateRewardRates(uint256 newAccessReward, uint256 newLikeReward) public onlyOwner {
        rewardPerAccess = newAccessReward;
        rewardPerLike = newLikeReward;

        emit RewardRateUpdated(newAccessReward, newLikeReward);
    }

    /**
     * @dev 查询剩余可mint数量
     */
    function remainingSupply() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }
}
