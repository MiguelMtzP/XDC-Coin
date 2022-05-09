// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 < 0.7.0;
pragma experimental ABIEncoderV2;
import "./SafeMath.sol";
import "./XRC20.sol";



//Implementación de las funciones del token ERC20
contract EnigmoTokenXdc is IXRC20{

    string public constant name = "EnigmoToken";
    string public constant symbol = "ENIGMO";
    uint8 public constant decimals = 18;

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed owner, address indexed spender, uint256 tokens);


    using SafeMath for uint256;

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint256 totalSupply_;
    uint256 coinPrice;
    address private ownerContract;

    constructor (uint256 initialSupply) public{
        totalSupply_ = initialSupply;
        balances[msg.sender] = totalSupply_;
        ownerContract = msg.sender;
    }

    // modificador que valida si el que llama a la funcion es el owner
    modifier isOwner() {
        require(msg.sender == ownerContract, "Caller is not owner");
        _;
    }

    function totalSupply() public override view returns (uint256){
        return totalSupply_;
    }
    
    function getCoinPrice() public view returns (uint256){
        return coinPrice;
    }

    function increaseTotalSupply(uint newTokensAmount) public payable isOwner {
        totalSupply_ += newTokensAmount;
        balances[msg.sender] += newTokensAmount;
    }
    function setCoinPrice(uint256 newPrice) public isOwner {
        coinPrice = newPrice;
    }

    function buyEnigmoCoins(uint256 coins) public payable returns (bool){
        require(coins <= balances[ownerContract], "insuficient balance");
        balances[ownerContract] = balances[ownerContract].sub(coins);
        balances[msg.sender] = balances[msg.sender].add(coins);
        emit Transfer(ownerContract,msg.sender, coins);
        return true;
    }

    function balanceOf(address tokenOwner) public override view returns (uint256){
        return balances[tokenOwner];
    }

    function xdcSupport() public view returns (uint256){
        return address(this).balance;
    }

    function extractXDCSupport(uint256 coins) public isOwner returns (bool){
        require(xdcSupport() >= coins, "insuficient XDC Support");
        msg.sender.transfer(coins);
        return true;
    }

    function allowance(address owner, address delegate) public override view returns (uint256){
        return allowed[owner][delegate];
    }

    function transfer(address recipient, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(numTokens);
        balances[recipient] = balances[recipient].add(numTokens);
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }

    function approve(address delegate, uint256 numTokens) public override returns (bool){
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool){
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);

        balances[owner] = balances[owner].sub(numTokens);
        allowed[owner][msg.sender] = allowed[owner][msg.sender].sub(numTokens);
        balances[buyer] = balances[buyer].add(numTokens);
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
}