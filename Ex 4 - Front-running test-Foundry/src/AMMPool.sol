// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0; 

// interface BaddToken {
//   function transfer(address to, uint256 amount) external returns (bool);
//   function transferFrom(address from, address to, uint256 amount) external returns (bool);
//   function balanceOf(address account) external view returns (uint256);
// }


import {BaddToken} from "./BaddToken.sol";

contract AMMPool {
  BaddToken tokenX;
  BaddToken tokenY;
  // _tokenX and _tokenY are contract-addresses running BaddToken SC
  constructor(address _tokenX, address _tokenY){
    tokenX = BaddToken(_tokenX); tokenY = BaddToken(_tokenY);
  }

  function swapXY(uint amountX) public payable {
      require(amountX > 0, "Swap amount should be > 0");
      // uint256 amountY = 2 * amountX;

      uint256 x = tokenX.balanceOf(address(this));
      uint256 y = tokenY.balanceOf(address(this));

      //  I am considering amountY = dy and amountX = dx
      uint256 amountY = y - (x * y) / (x + amountX);

      /*************************************************** 
      // Using below two lines makes thi SC vulnerable.
      /***************************************************/
      tokenY.transfer(msg.sender, amountY);
      tokenX.transferFrom(msg.sender, address(this), amountX);
      
      
      /*************************************************************************** 
      // Using below two lines with require will makes help the SC to be secured.
      /*****************************************************************************/
      // require(tokenY.transfer(msg.sender, amountY), "Token transfer failed");
      // require(tokenX.transferFrom(msg.sender, address(this), amountX), "Token transferFrom failed");
      

      
  } 
}