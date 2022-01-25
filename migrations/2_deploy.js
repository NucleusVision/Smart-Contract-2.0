const NitroNetwork = artifacts.require("NitroNetwork");
const { deployProxy } = require("@openzeppelin/truffle-upgrades");

module.exports = async function (deployer, accounts) {
  await deployProxy(NitroNetwork, { deployer, unsafeAllowCustomTypes: true });
};
