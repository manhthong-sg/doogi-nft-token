//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract Gold is ERC20, AccessControl, Pausable {
    bytes32 public constant PAUSE_ROLE = keccak256("PAUSE_ROLE");
    mapping(address=>bool) blackList;
    constructor() ERC20("GOLD", "GLD") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, 1000000 * 10**decimals());
    }
    event BlackListAdd(address account);
    event BlackListRemove(address account);
    function pause() public onlyRole(PAUSE_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSE_ROLE) {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override whenNotPaused {
        require(blackList[from]!=true, "Gold: Account sender in Blacklist");
        require(blackList[to]!=true, "Gold: Account recipient in Blacklist");
        super._beforeTokenTransfer(from, to, amount);
    }

    function _addToBlackList(address _account) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(_account != msg.sender, "Can not add yourself to blacklist");
        require(blackList[_account]==false, "Exist in blacklist");

        blackList[_account]=true;
        emit BlackListAdd(_account);
    }
    function _removeFromBlackList(address _account) external onlyRole(DEFAULT_ADMIN_ROLE){
        require(_account != msg.sender, "Can not add yourself to blacklist");
        require(blackList[_account]==true, "Do not exist in blacklist");

        blackList[_account]=false;
        emit BlackListRemove(_account);
    }
}
