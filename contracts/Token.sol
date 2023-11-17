// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract Token is AccessControl, ERC20Permit {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    constructor(
        string memory name, 
        string memory symbol
    ) ERC20(name, symbol) ERC20Permit(name) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(BURNER_ROLE, msg.sender);
        _mint(msg.sender, 100000 * 10 ** decimals());
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(
        address to,
        uint256 amount
    ) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function burn(
        address from,
        uint256 amount
    ) public onlyRole(BURNER_ROLE) {
        _burn(from, amount);
    }
}