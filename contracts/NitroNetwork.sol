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

    mapping(address => bool) public isBlackListed;
    event AddedBlackList(address _who, uint256 _when);
    event RemovedBlackList(address _who, uint256 _when);
    event DestroyedBlackFunds(address _who, uint256 _howmuch, uint256 _when);

    constructor() initializer {}

    function initialize(
        address _admin,
        address _governance,
        address _operator,
        address _pauser,
        address _minter,
        address _mintTo
    ) public initializer {
        __ERC20_init("Nitro Network", "NITRO");
        __ERC20Burnable_init();
        __Pausable_init();
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, _admin);
        _setupRole(GOVERNANCE_ROLE, _governance);
        _setupRole(OPERATOR_ROLE, _operator);
        _setupRole(PAUSER_ROLE, _pauser);
        _mint(_mintTo, 1000000 * 10**decimals());
        _setupRole(MINTER_ROLE, _minter);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
    
    function addBlackList(address _who) public onlyRole(OPERATOR_ROLE) {
        isBlackListed[_who] = true;
        emit AddedBlackList(_who, block.number);
    }

    function removeBlackList(address _who) public onlyRole(OPERATOR_ROLE) {
        isBlackListed[_who] = false;
        emit RemovedBlackList(_who, block.number);
    }

    function getBlackListStatus(address _who) external view returns (bool) {
        return isBlackListed[_who];
    }

    function burnBlackFunds(address _blackListedUser)
        public
        onlyRole(OPERATOR_ROLE)
    {
        require(
            isBlackListed[_blackListedUser],
            "BurnBlackFunds:: Blacklist user before destroy funds"
        );
        uint256 dirtyFunds = balanceOf(_blackListedUser);
        _burn(_blackListedUser, dirtyFunds);
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds, block.number);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(!isBlackListed[from], "BeforeTokenTransfer:: User blacklisted");
        super._beforeTokenTransfer(from, to, amount);
    }
}