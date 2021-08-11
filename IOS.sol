// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./Include.sol";

contract IOS is PermitERC20UpgradeSafe {
	function __IOS_init(address mine_, address team_, address fund_, address eco_, address liquidity_) external initializer {
        __Context_init_unchained();
		__ERC20_init_unchained("IOSwap.io Governance Token", "IOS");
		__IOS_init_unchained(mine_, team_, fund_, eco_, liquidity_);
	}
	
	function __IOS_init_unchained(address mine_, address team_, address fund_, address eco_, address liquidity_) public initializer {
		_mint(mine_,     1_600_000_000 * 10 ** uint256(decimals()));
		_mint(team_,       160_000_000 * 10 ** uint256(decimals()));
		_mint(fund_,       100_000_000 * 10 ** uint256(decimals()));
		_mint(eco_,        100_000_000 * 10 ** uint256(decimals()));
		_mint(liquidity_,   40_000_000 * 10 ** uint256(decimals()));
	}
}


contract Timelock is Configurable {
	using SafeMath for uint;
	using SafeERC20 for IERC20;
	
	IERC20 public token;
	address public recipient;
	uint public begin;
	uint public span;
	uint public times;
	uint public total;
	
	function start(address _token, address _recipient, uint _begin, uint _span, uint _times) external governance {
		//require(address(token) == address(0), 'already start');
		token = IERC20(_token);
		recipient = _recipient;
		begin = _begin;
		span = _span;
		times = _times;
		total = token.balanceOf(address(this));
	}

    function unlockCapacity() public view returns (uint) {
       if(begin == 0 || now < begin)
            return 0;
            
        for(uint i=1; i<=times; i++)
            if(now < span.mul(i).div(times).add(begin))
                return token.balanceOf(address(this)).sub(total.mul(times.sub(i)).div(times));
                
        return token.balanceOf(address(this));
    }
    
    function unlock() public {
        token.safeTransfer(recipient, unlockCapacity());
    }
    
    fallback() external {
        unlock();
    }
}


