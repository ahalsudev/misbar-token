// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { Script, console } from 'forge-std/Script.sol';
import { Vm } from 'forge-std/Vm.sol';
import { ICreateX } from 'createx/ICreateX.sol';

import { DeployUtils } from '../libraries/DeployUtils.sol';
import { InitialSupplyMisbarTokenERC20 } from '../src/InitialSupplyMisbarTokenERC20.sol';

// Example forge script for deploying as an alternative to sup: super-cli (https://github.com/ethereum-optimism/super-cli)
contract Deploy is Script {
  /// @notice Array of RPC URLs to deploy to, deploy to supersim 901 and 902 by default.
  string[] private rpcUrls = ['http://localhost:9545', 'http://localhost:9546'];

  /// @notice Modifier that wraps a function in broadcasting.
  modifier broadcast() {
    vm.startBroadcast(msg.sender);
    _;
    vm.stopBroadcast();
  }

  function run() public {
    for (uint256 i = 0; i < rpcUrls.length; i++) {
      string memory rpcUrl = rpcUrls[i];

      console.log('Deploying to RPC: ', rpcUrl);
      vm.createSelectFork(rpcUrl);
      deployInitialSupplyMisbarTokenERC20Contract();
    }
  }

  function deployInitialSupplyMisbarTokenERC20Contract() public broadcast returns (address addr_) {
    bytes memory initCode = abi.encodePacked(
      type(InitialSupplyMisbarTokenERC20).creationCode,
      abi.encode(msg.sender, 'Misbar', 'MISBAR', 18, 1000, block.chainid)
    );
    addr_ = DeployUtils.deployContract('InitialSupplyMisbarTokenERC20', _implSalt(), initCode);
  }

  /// @notice The CREATE2 salt to be used when deploying a contract.
  function _implSalt() internal view returns (bytes32) {
    return keccak256(abi.encodePacked(vm.envOr('DEPLOY_SALT', string('misbar-token-v3'))));
  }
}
