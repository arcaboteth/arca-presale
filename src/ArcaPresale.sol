// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ArcaPresale
 * @notice Trustless presale contract for $ARCA token on Base
 * @dev Simple ETH collection with soft/hard caps, early bird bonus, and refund mechanism
 * 
 * Parameters:
 * - Soft Cap: ~5 ETH ($10K)
 * - Hard Cap: ~12.5 ETH ($25K)
 * - Min: 0.01 ETH | Max: 1 ETH per wallet
 * - Duration: 48 hours
 * - Early Bird: 10% bonus for first 24h (affects token allocation weight, not ETH)
 * - Refund: automatic if soft cap not met
 */
contract ArcaPresale {
    address public immutable owner;
    uint256 public immutable softCap;
    uint256 public immutable hardCap;
    uint256 public immutable minContribution;
    uint256 public immutable maxContribution;
    uint256 public immutable startTime;
    uint256 public immutable endTime;
    uint256 public immutable earlyBirdBonusBps; // 1000 = 10%
    // Early bird = before soft cap is reached (milestone-based, not time-based)

    uint256 public totalRaised;
    bool public finalized;

    mapping(address => uint256) public contributions;
    mapping(address => uint256) public effectiveContributions; // weighted with early bird bonus
    address[] public contributors;

    event Contributed(address indexed contributor, uint256 amount, uint256 effective, bool earlyBird);
    event Refunded(address indexed contributor, uint256 amount);
    event Finalized(uint256 totalRaised, uint256 contributorCount);

    error PresaleNotActive();
    error HardCapExceeded();
    error BelowMinimum();
    error AboveMaximum();
    error AlreadyFinalized();
    error RefundNotAvailable();
    error NoContribution();
    error TransferFailed();
    error OnlyOwner();
    error SoftCapNotMet();

    constructor(
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _minContribution,
        uint256 _maxContribution,
        uint256 _durationSeconds,
        uint256 _earlyBirdBonusBps
    ) {
        owner = msg.sender;
        softCap = _softCap;
        hardCap = _hardCap;
        minContribution = _minContribution;
        maxContribution = _maxContribution;
        startTime = block.timestamp;
        endTime = block.timestamp + _durationSeconds;
        earlyBirdBonusBps = _earlyBirdBonusBps;
    }

    /// @notice Contribute ETH to the presale
    function deposit() external payable {
        if (block.timestamp < startTime || block.timestamp >= endTime) revert PresaleNotActive();
        if (totalRaised + msg.value > hardCap) revert HardCapExceeded();
        if (msg.value < minContribution) revert BelowMinimum();
        if (contributions[msg.sender] + msg.value > maxContribution) revert AboveMaximum();
        if (finalized) revert AlreadyFinalized();

        // Track new contributors
        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        // Calculate effective contribution
        // Early bird = contributed BEFORE soft cap was reached (milestone-based)
        // The check uses totalRaised BEFORE this deposit was added
        uint256 effective = msg.value;
        bool isEarlyBird = (totalRaised - msg.value) < softCap;
        if (isEarlyBird) {
            effective = (msg.value * (10000 + earlyBirdBonusBps)) / 10000;
        }
        effectiveContributions[msg.sender] += effective;

        emit Contributed(msg.sender, msg.value, effective, isEarlyBird);
    }

    /// @notice Refund if soft cap not met or presale expired without finalization
    function refund() external {
        bool softCapMissed = block.timestamp >= endTime && totalRaised < softCap;
        bool safetyRefund = !finalized && block.timestamp >= endTime + 7 days;

        if (!softCapMissed && !safetyRefund) revert RefundNotAvailable();

        uint256 amount = contributions[msg.sender];
        if (amount == 0) revert NoContribution();

        contributions[msg.sender] = 0;
        effectiveContributions[msg.sender] = 0;

        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();

        emit Refunded(msg.sender, amount);
    }

    /// @notice Owner finalizes presale and withdraws funds (only if soft cap met)
    function finalize() external {
        if (msg.sender != owner) revert OnlyOwner();
        if (finalized) revert AlreadyFinalized();
        if (totalRaised < softCap) revert SoftCapNotMet();

        // Can finalize once soft cap met (even before endTime if hard cap hit)
        if (totalRaised < hardCap && block.timestamp < endTime) {
            // Only allow early finalization if hard cap reached
            revert PresaleNotActive();
        }

        finalized = true;

        (bool success,) = owner.call{value: address(this).balance}("");
        if (!success) revert TransferFailed();

        emit Finalized(totalRaised, contributors.length);
    }

    // ── View Functions ──

    function getContributorCount() external view returns (uint256) {
        return contributors.length;
    }

    function getContributors() external view returns (address[] memory) {
        return contributors;
    }

    function getContribution(address _addr) external view returns (uint256 actual, uint256 effective) {
        return (contributions[_addr], effectiveContributions[_addr]);
    }

    function isActive() external view returns (bool) {
        return block.timestamp >= startTime
            && block.timestamp < endTime
            && totalRaised < hardCap
            && !finalized;
    }

    function timeRemaining() external view returns (uint256) {
        if (block.timestamp >= endTime) return 0;
        return endTime - block.timestamp;
    }

    function isEarlyBirdActive() external view returns (bool) {
        return totalRaised < softCap && !finalized;
    }

    function getPresaleInfo() external view returns (
        uint256 _totalRaised,
        uint256 _softCap,
        uint256 _hardCap,
        uint256 _contributorCount,
        uint256 _timeRemaining,
        bool _isActive,
        bool _isEarlyBird,
        bool _finalized
    ) {
        _totalRaised = totalRaised;
        _softCap = softCap;
        _hardCap = hardCap;
        _contributorCount = contributors.length;
        _timeRemaining = block.timestamp >= endTime ? 0 : endTime - block.timestamp;
        _isActive = block.timestamp >= startTime && block.timestamp < endTime && totalRaised < hardCap && !finalized;
        _isEarlyBird = totalRaised < softCap && !finalized;
        _finalized = finalized;
    }

    /// @notice Accept direct ETH transfers as deposits
    receive() external payable {
        // Redirect to deposit logic
        if (block.timestamp < startTime || block.timestamp >= endTime) revert PresaleNotActive();
        if (totalRaised + msg.value > hardCap) revert HardCapExceeded();
        if (msg.value < minContribution) revert BelowMinimum();
        if (contributions[msg.sender] + msg.value > maxContribution) revert AboveMaximum();
        if (finalized) revert AlreadyFinalized();

        if (contributions[msg.sender] == 0) {
            contributors.push(msg.sender);
        }

        contributions[msg.sender] += msg.value;
        totalRaised += msg.value;

        uint256 effective = msg.value;
        bool isEarlyBird = (totalRaised - msg.value) < softCap;
        if (isEarlyBird) {
            effective = (msg.value * (10000 + earlyBirdBonusBps)) / 10000;
        }
        effectiveContributions[msg.sender] += effective;

        emit Contributed(msg.sender, msg.value, effective, isEarlyBird);
    }
}
