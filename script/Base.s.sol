// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { Sphinx, Network } from "@sphinx-labs/plugins/SphinxPlugin.sol";

abstract contract BaseScript is Script, Sphinx {
  /// @dev Needed for the deterministic deployments.
  bytes32 internal constant ZERO_SALT = bytes32(0);

  constructor() {
    sphinxConfig.owners = [address(0)]; // Add owner address(es)
    sphinxConfig.orgId = ""; // Add org ID
    sphinxConfig.mainnets = [
      Network.arbitrum,
      Network.avalanche,
      Network.bnb,
      Network.gnosis,
      Network.ethereum,
      Network.optimism,
      Network.polygon
    ];
    // We don't include Sepolia because we already deployed the UniversalPermit2Adapter on it.
    sphinxConfig.testnets = [Network.optimism_sepolia, Network.arbitrum_sepolia];
    sphinxConfig.projectName = "Universal_Permit2_Adapter";
    sphinxConfig.threshold = 1;
  }
}
