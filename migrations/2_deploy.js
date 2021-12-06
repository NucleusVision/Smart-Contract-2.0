const NitroNetwork = artifacts.require("NitroNetwork");
const { deployProxy } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer, accounts) {
  await deployProxy(
    NitroNetwork,
    ["admin_address", "governance_address", "operator_address", "pauser_address", "minter_address", "mint_to"],
    { deployer, unsafeAllowCustomTypes: true }
  );
};
