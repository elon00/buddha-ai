// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BuddhaAIToken
 * @notice Global Dhamma Intelligence & Cessation of Suffering Launchpad ($BUDDHA)
 * @dev Direct micro-escrows for Sangha monasteries, meditation centers, and mindful humanitarian relief
 */
contract BuddhaAIToken {
    string public name = "Buddha AI";
    string public symbol = "BUDDHA";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant CURVE_SLOPE = 1e10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CurveMint(address indexed seeker, uint256 tokenAmount, uint256 ethDonation);
    event DhammaDisbursement(string indexed initiative, address indexed recipient, uint256 amountWei, bytes32 indexed dhammaProof);

    function calculateCost(uint256 amount) public view returns (uint256) {
        uint256 currentSupply = totalSupply;
        uint256 baseCost = amount * INITIAL_PRICE;
        uint256 curveFactor = (CURVE_SLOPE * ((currentSupply + amount)**2 - currentSupply**2)) / 2e18;
        return baseCost + curveFactor;
    }

    function mint(uint256 amount) external payable returns (bool) {
        require(amount > 0, "Zero donation amount");
        uint256 cost = calculateCost(amount);
        require(msg.value >= cost, "Insufficient donation for bonding curve");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        emit CurveMint(msg.sender, amount, cost);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        return true;
    }

    function disburseDhammaGrant(
        string memory initiative,
        address recipient,
        uint256 amount,
        bytes32 dhammaProof
    ) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient Sangha treasury reserve");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        emit DhammaDisbursement(initiative, recipient, amount, dhammaProof);
        return true;
    }
}
