// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

interface IBEP20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {    
      
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }


    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IBEP20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IBEP20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IBEP20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeBEP20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IBEP20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IBEP20 token, address spender) internal {
        uint256 newAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {
       
        bytes memory returndata = address(token).functionCall(data, "SafeBEP20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeBEP20: BEP20 operation did not succeed");
        }
    }
}

contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function geUnlockTime() public view returns (uint256) {
        return _lockTime;
    }

    //Locks the contract for owner for the amount of time provided
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    //Unlocks the contract for owner when _lockTime is exceeds
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime , "Contract is locked until 7 days");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

contract BEP20 is IBEP20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public override returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        uint256 taxFee = 300;

        _balances[from] = _balances[from].sub(value).sub(taxFee.div(100));
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 value) internal {
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

contract Winner is Ownable {
    using SafeMath for uint256;
    
    IBEP20 public Universal;
    uint256 public participantNum = 0;  
    uint256 randNonce = 0; 
    address[] public winners;  
    uint256 public prize; 
    uint256 public  taxFee = 3;
    uint256 public  liquidityFee = 2;
    uint256 public  tFeeTotal;
    
    //struct for Participants
    struct Participant {
        string name;
        bool isWhitelisted;
    }

    mapping (address => bool) public rewarded;     
    //mapping of selected numbers to the array of addresses that picked the number
    mapping (uint256 => address[]) public logs;
    mapping (address => Participant) public participants;
    
    enum GameState { Open, Closed }       
    GameState public gameState;     
    
    event NewRegistration(string name, address addr);
    event MemberJoined(address memberAddress, uint256 indexed chosenNumber);  
    event Blacklisted(address addr, string name);
    event WinnnerSelected(uint selected);
    
    modifier onlyWhitelisted(address _addr) {
        Participant memory _participantStruct = participants[_addr];
        require(_participantStruct.isWhitelisted == true, "This address is not whitelisted");
        _;
    } 
    
    constructor() {
        gameState = GameState.Closed;
    }
    
    function startgame() public {
        require(participantNum >= 1000, 'Total participants is less than 1000');
        gameState = GameState.Open;
    
    }
        
    function totalFees() public view returns (uint256) {
        uint256 _taxFee = taxFee.add(liquidityFee);
        return _taxFee;
    }
    
    function _reflectFee(uint256 tFee) public {
        tFeeTotal = taxFee.add(tFee);
    }
    
    function whitelistParticipant(string calldata _name) external {
        Participant memory _participantStruct = Participant(_name, true);
        participants[msg.sender] = _participantStruct;
        emit NewRegistration(_name, msg.sender);
    }
    
    function blackListParticipant(address _addr) external onlyOwner {
        Participant memory _participantStruct = participants[_addr];
        _participantStruct.isWhitelisted = false;
        emit Blacklisted(_addr, _participantStruct.name);
    }
    
    function isWhitelisted(address _addr) external view returns(bool) {
        Participant memory _participantStruct = participants[_addr];
        return _participantStruct.isWhitelisted;
    }
    
    function participate(uint256 _chosenNumber, address _addr) payable external {
        require(msg.sender == _addr, 'Must own whitelisted address');
        require(_chosenNumber > 0 && _chosenNumber <= 1000, 'Must be a number between 1-1000');
        // require(msg.value == 0.1 ether, 'Send 0.1 Eth to join'); //require user to perform atleast one transactions before participation 
        // require(gameState == GameState.Open, 'Game is closed');
        logs[_chosenNumber].push(msg.sender);  
        participantNum = participantNum.add(1);

        emit MemberJoined(msg.sender, _chosenNumber);
    }
    
    function _randomNumber(uint _limit) internal returns(uint256) {
        uint random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce))) % _limit;
        randNonce = randNonce.add(1);
        return random;
    }
    
    //function to select winners
    function selectWinners() external onlyOwner returns(uint256 selected) {
        require(gameState == GameState.Open, 'Game is closed');
        gameState = GameState.Closed;
        selected = _randomNumber(1000).add(1);
        winners = logs[selected];
        prize = taxFee / winners.length;
        emit WinnnerSelected(selected);
        return selected;
    }

    //function to check if caller is among the winners
    function isWinner() public view returns(bool winner) {
        for(uint i = 0; i < winners.length;) {
            if (winners[i] == msg.sender) {
                i++;
                return true;
            } else {
                return false;
            }
        }
    }
    
    //function for winners to withdraw the prize
    function withdrawPrize() public payable returns(bool success) {
        require(isWinner(), "You must be a winner");
        require(rewarded[msg.sender] != true, "You have taken your reward");
        rewarded[msg.sender] = true;
        Universal.transfer(msg.sender, prize);
        return true;
    }
    
}

abstract contract ABC is IBEP20 {
    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

}

contract ABCUniversal is BEP20, Winner, ABC {
    uint8 public constant DECIMALS = 9;
    uint256 public constant INITIAL_SUPPLY = 1000000 * (100 ** uint256(DECIMALS));

    constructor () ABC("ABC coin", "ABC") {
        _mint(msg.sender, INITIAL_SUPPLY);
        Universal = IBEP20(this);
    }
}

contract ABCLP is Winner, ABCUniversal {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
    }

    struct PoolInfo {
        IBEP20 lpToken;
        uint256 lastRewardBlock;
        uint256 accABCPerShare;
    }

    uint256 public ABCPerBlock = uint256(1 ether).div(1000000); //0.0000001 ABC

    PoolInfo public liquidityMining;
    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);

    function setABCTokens(IBEP20 _lpToken) external onlyOwner {
        require(address(Universal) == address(0) && address(liquidityMining.lpToken) == address(0), 'Tokens already set!');
        liquidityMining =
            PoolInfo({
                lpToken: _lpToken,
                lastRewardBlock: 0,
                accABCPerShare: 0
        });
    }

    function pendingRewards(address _user) external view returns (uint256) {
        require(liquidityMining.lastRewardBlock > 0 && block.number >= liquidityMining.lastRewardBlock, 'Mining not yet started');
        UserInfo storage user = userInfo[_user];
        uint256 accABCPerShare = liquidityMining.accABCPerShare;
        uint256 lpSupply = liquidityMining.lpToken.balanceOf(address(this));
        if (block.number > liquidityMining.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = block.number.sub(liquidityMining.lastRewardBlock);
            uint256 ABCReward = multiplier.mul(ABCPerBlock);
            accABCPerShare = liquidityMining.accABCPerShare.add(ABCReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accABCPerShare).div(1e12).sub(user.rewardDebt).add(user.pendingRewards);
    }

    function deposit(uint256 amount) external {
        UserInfo storage user = userInfo[msg.sender];
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(liquidityMining.accABCPerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                user.pendingRewards = user.pendingRewards.add(pending);
            }
        }
        if (amount > 0) {
            liquidityMining.lpToken.safeTransferFrom(address(msg.sender), address(this), amount);
            user.amount = user.amount.add(amount);
        }
        user.rewardDebt = user.amount.mul(liquidityMining.accABCPerShare).div(1e12);
        emit Deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        UserInfo storage user = userInfo[msg.sender];
        require(user.amount >= amount, "Withdrawing more than you have!");
        uint256 pending = user.amount.mul(liquidityMining.accABCPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
        }
        if (amount > 0) {
            user.amount = user.amount.sub(amount);
            liquidityMining.lpToken.safeTransfer(address(msg.sender), amount);
        }
        user.rewardDebt = user.amount.mul(liquidityMining.accABCPerShare).div(1e12);
        emit Withdraw(msg.sender, amount);
    }

    function claim() external {
        UserInfo storage user = userInfo[msg.sender];
        uint256 pending = user.amount.mul(liquidityMining.accABCPerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0 || user.pendingRewards > 0) {
            user.pendingRewards = user.pendingRewards.add(pending);
            uint256 claimedAmount = safeABCTransfer(msg.sender, user.pendingRewards);
            emit Claim(msg.sender, claimedAmount);
            user.pendingRewards = user.pendingRewards.sub(claimedAmount);
        }
        user.rewardDebt = user.amount.mul(liquidityMining.accABCPerShare).div(1e12);
    }

    function safeABCTransfer(address to, uint256 amount) internal returns (uint256) {
        uint256 ABCBalance = Universal.balanceOf(address(this));
        if (amount > ABCBalance) {
            Universal.safeTransfer(to, ABCBalance);
            return ABCBalance;
        } else {
            Universal.safeTransfer(to, amount);
            return amount;
        }
    }
    
    function setABCPerBlock(uint256 _ABCPerBlock) external onlyOwner {
        require(_ABCPerBlock > 0, "ABC per block should be greater than 0!");
        ABCPerBlock = _ABCPerBlock;
    }
    
}
