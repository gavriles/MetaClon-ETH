// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MetaToken is Ownable {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public originalTokenAddress;
    uint256 public lockTime;

    mapping(address => uint256) private _balances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    constructor(
        string memory _name,
        string memory _symbol,
        address _originalTokenAddress,
        uint256 _amountToWrap,
        uint256 _lockTime
    ) {
        name = _name;
        symbol = _symbol;
        originalTokenAddress = _originalTokenAddress;
        lockTime = _lockTime;
        totalSupply = _amountToWrap;

        IERC20 originalToken = IERC20(_originalTokenAddress);
        require(originalToken.transferFrom(msg.sender, address(this), _amountToWrap), "Transfer failed");
        _balances[msg.sender] = _amountToWrap;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function unwrap(uint256 amount) public returns (bool) {
        require(block.timestamp >= lockTime, "Tokens are still locked");
        require(_balances[msg.sender] >= amount, "Insufficient balance");

        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        totalSupply = totalSupply.sub(amount);

        IERC20 originalToken = IERC20(originalTokenAddress);
        require(originalToken.transfer(msg.sender, amount), "Transfer failed");
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }
}
