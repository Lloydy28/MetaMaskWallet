// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Assessment {
    address payable public owner;
    uint256 public balance;

    event Deposit(address indexed account, uint256 amount, uint256 newBalance, uint256 timestamp);
    event Withdraw(address indexed account, uint256 amount, uint256 newBalance, uint256 timestamp);
    event Transfer(address indexed from, address indexed to, uint256 amount, uint256 newBalanceFrom, uint256 newBalanceTo, uint256 timestamp);
    event Redeem(address indexed account, uint256 amount, uint256 newBalance, uint256 timestamp);

    constructor(uint initBalance) payable {
        owner = payable(msg.sender);
        balance = initBalance;
    }

    function getBalance() public view returns (uint256) {
        return balance;
    }

    function deposit(uint256 _amount) public payable {
        uint _previousBalance = balance;

        // make sure this is the owner
        require(msg.sender == owner, "You are not the owner of this account");

        // perform transaction
        balance += _amount;

        // assert transaction completed successfully
        assert(balance == _previousBalance + _amount);

        // emit the event
        emit Deposit(msg.sender, _amount, balance, block.timestamp);
    }

    // custom error
    error InsufficientBalance(uint256 balance, uint256 withdrawAmount);

    function withdraw(uint256 _withdrawAmount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        uint _previousBalance = balance;
        if (balance < _withdrawAmount) {
            revert InsufficientBalance({
                balance: balance,
                withdrawAmount: _withdrawAmount
            });
        }

        // withdraw the given amount
        balance -= _withdrawAmount;

        // assert the balance is correct
        assert(balance == (_previousBalance - _withdrawAmount));

        // emit the event
        emit Withdraw(msg.sender, _withdrawAmount, balance, block.timestamp);
    }

    function transfer(address payable _to, uint256 _amount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        require(_to != address(0), "Cannot transfer to the zero address");
        require(balance >= _amount, "Insufficient balance for transfer");

        uint _previousBalance = balance;
        uint _toPreviousBalance = _to.balance;

        // Perform the transfer
        balance -= _amount;
        _to.transfer(_amount);

        // Emit the event
        emit Transfer(msg.sender, _to, _amount, balance, _to.balance, block.timestamp);

        // Assert the balance is correct
        assert(balance == _previousBalance - _amount);
        assert(_to.balance == _toPreviousBalance + _amount);
    }

    function redeem(uint256 _amount) public {
        require(msg.sender == owner, "You are not the owner of this account");
        require(balance >= _amount, "Insufficient balance to redeem");

        uint _previousBalance = balance;

        // Perform the redeem
        balance -= _amount;
        owner.transfer(_amount);

        // Emit the event
        emit Redeem(msg.sender, _amount, balance, block.timestamp);

        // Assert the balance is correct
        assert(balance == _previousBalance - _amount);
    }
}
