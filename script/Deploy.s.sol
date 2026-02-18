// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/ArcaPresale.sol";

contract DeployPresale is Script {
    function run() external {
        vm.startBroadcast();

        // Presale parameters
        uint256 softCap = 5 ether;       // ~$10K at $2000/ETH
        uint256 hardCap = 12.5 ether;    // ~$25K at $2000/ETH
        uint256 minContrib = 0.01 ether; // ~$20
        uint256 maxContrib = 1 ether;    // ~$2,000
        uint256 duration = 48 hours;
        uint256 earlyBirdBonusBps = 1000; // 10%

        ArcaPresale presale = new ArcaPresale(
            softCap,
            hardCap,
            minContrib,
            maxContrib,
            duration,
            earlyBirdBonusBps
        );

        console.log("Presale deployed at:", address(presale));
        console.log("Owner:", msg.sender);
        console.log("Soft Cap:", softCap / 1 ether, "ETH");
        console.log("Hard Cap:", hardCap / 1 ether, "ETH");

        vm.stopBroadcast();
    }
}
