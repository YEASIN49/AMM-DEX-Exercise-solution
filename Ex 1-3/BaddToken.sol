// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0; 
contract BaddToken {  
  uint _totalSupply = 0; string _symbol; 
  // uint256 public test;  
  mapping(address => uint) balances;  

  // Added on Ex: 2 (I am following ERC20 structure)
  mapping(address => mapping(address => uint256)) private allowances;
  
  constructor(string memory symbol, uint256 initialSupply) {
    _symbol = symbol;
    _totalSupply = initialSupply;
    balances[msg.sender] = _totalSupply;  
  }
  
  function transfer(address receiver, uint amount) public returns (bool) {    
    require(amount <= balances[msg.sender]);        
    balances[msg.sender] = balances[msg.sender] - amount;    
    balances[receiver] = balances[receiver] + amount;    
    return true;  
  }

  function balanceOf(address account) public view returns(uint256){
    return balances[account];
  }


  function transferFrom(address from, address to, uint256 amount) external returns (bool) {
      // test = balances[from];

      /**************************************************************** 
      // Commenting out below two lines will make this SC vulnerable
      /*********************************************************************/
      require(amount <= balances[from], "Spender do not have enough balance");
      require(amount <= allowances[from][msg.sender], "Spender did not provide enough allowance");

      balances[from] -= amount;
      balances[to] += amount;
      /**********************************************************************************************************************
      // Solidity version greater than 0.8 by default checks, undrflow, and overflow. 
      // Therefore, the lack of proper require/checks and using the below line in compiler 0.7 or below will make it vulnerable
      /***********************************************************************************************************************/
      allowances[from][msg.sender] -= amount;

      return true;
    }

    function approve(address spender, uint256 amount) external returns (bool){
      allowances[msg.sender][spender] = amount;
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return allowances[owner][spender];
    }

    // function undo_approve(address spender) external {
    // uint256 tradeInProgressAmount = allowances[msg.sender][spender];
    // require(tradeInProgressAmount > 0, "There is no approval for the sender");  
    // allowances[msg.sender][spender] = 0;
    //}

}
