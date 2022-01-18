// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract NitroNetwork is
  Initializable,
  ERC20Upgradeable,
  ERC20BurnableUpgradeable,
  PausableUpgradeable,
  AccessControlUpgradeable
{
  bytes32 public constant GOVERNANCE_ROLE = keccak256("GOVERNANCE_ROLE");
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  // 500 Million per Mint
  uint256 public maxPerMint;

  mapping(address => bool) private isBlackListed;
  event AddedBlackList(address _who, uint256 _when);
  event RemovedBlackList(address _who, uint256 _when);
  event RecoverBlackFunds(
    address _from,
    address _to,
    uint256 _howmuch,
    uint256 _when
  );
  event BurnBlackFunds(address _from, uint256 _howmuch, uint256 _when);

  function initialize(
    address _admin,
    address _governance,
    address _operator,
    address _pauser,
    address _minter
  ) public initializer {
    __ERC20_init("NitroNetwork", "NITRO");
    __ERC20Burnable_init();
    __Pausable_init();
    __AccessControl_init();
    _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    _setupRole(GOVERNANCE_ROLE, _governance);
    _setupRole(OPERATOR_ROLE, _operator);
    _setupRole(PAUSER_ROLE, _pauser);
    _setupRole(MINTER_ROLE, _minter);
    maxPerMint = 500 * 10**6 * 10**18;
  }

  function pause() public onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause() public onlyRole(PAUSER_ROLE) {
    _unpause();
  }

  function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
    require(amount <= maxPerMint, "Mint:: Max limit reached per mint");
    _mint(to, amount);
  }

  function addBlackList(address _who) public onlyRole(OPERATOR_ROLE) {
    _updateBlackList(_who, true);
    emit AddedBlackList(_who, block.number);
  }

  function removeBlackList(address _who) public onlyRole(OPERATOR_ROLE) {
    _updateBlackList(_who, false);
    emit RemovedBlackList(_who, block.number);
  }

  function getBlackListStatus(address _who) public view returns (bool) {
    return isBlackListed[_who];
  }

  function recoverBlackFunds(
    address _from,
    address _to,
    uint256 _howmuch
  ) public onlyRole(GOVERNANCE_ROLE) {
    require(
      _from != address(0),
      "RecoverBlackFunds: Transfer from the zero address"
    );
    require(
      _to != address(0),
      "RecoverBlackFunds: Transfer to the zero address"
    );
    require(
      getBlackListStatus(_from),
      "RecoverBlackFunds:: User must be Blacklisted before transfer"
    );
    _updateBlackList(_from, false);
    _transfer(_from, _to, _howmuch);
    _updateBlackList(_from, true);
    emit RecoverBlackFunds(_from, _to, _howmuch, block.timestamp);
  }

  function burnBlackFunds(address _from, uint256 _howmuch)
    public
    onlyRole(GOVERNANCE_ROLE)
  {
    require(
      _from != address(0),
      "BurnBlackFunds: Transfer from the zero address"
    );
    require(
      getBlackListStatus(_from),
      "BurnBlackFunds:: User must be Blacklisted before transfer"
    );
    _updateBlackList(_from, false);
    _burn(_from, _howmuch);
    _updateBlackList(_from, true);
    emit BurnBlackFunds(_from, _howmuch, block.timestamp);
  }

  function _updateBlackList(address _wallet, bool _status) internal {
    isBlackListed[_wallet] = _status;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override whenNotPaused {
    require(
      !getBlackListStatus(from),
      "BeforeTokenTransfer:: User blacklisted"
    );
    super._beforeTokenTransfer(from, to, amount);
  }
}
