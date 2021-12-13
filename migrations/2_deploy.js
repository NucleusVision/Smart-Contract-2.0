const NitroNetwork = artifacts.require("NitroNetwork");
const { deployProxy } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer, accounts) {
  await deployProxy(
    NitroNetwork,
    [
      "0x4d09c1eBa78c6f8EC4bB443F949118C9c5C2ad3B", // "admin_address",
      "0x4d09c1eBa78c6f8EC4bB443F949118C9c5C2ad3B", //"governance_address",
      "0x4d09c1eBa78c6f8EC4bB443F949118C9c5C2ad3B", //"operator_address",
      "0x4d09c1eBa78c6f8EC4bB443F949118C9c5C2ad3B", //"pauser_address",
      "0x4d09c1eBa78c6f8EC4bB443F949118C9c5C2ad3B", //"minter_address",
      "0x4d09c1eBa78c6f8EC4bB443F949118C9c5C2ad3B", //"mint_to",
    ],
    { deployer, unsafeAllowCustomTypes: true }
  );
};
