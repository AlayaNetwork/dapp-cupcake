pragma solidity ^0.5.17;

import "./libraries/SafeERC20.sol";
import "./libraries/SafeMath.sol";
import "./libraries/Address.sol";
import "./libraries/Strings.sol";
import "./libraries/Integers.sol";

contract CupCake {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using Strings for string;
    using Integers for uint256;

    address public owner;
    uint256 public minProductDuration = 86400000;

    struct Product {
        address tokenContractAddress;
        string  name;
        string  symbol;
        uint256 productDuration;
        uint256 rewardsPerLockToken;
        uint256 minIncrease;
        uint256 totalQuota;
        uint256 minPurchase;
        uint256 beginSaleTimestamp;
        uint256 endSaleTimestamp;
        uint256 releaseTime;
    }

    event RegisterATP(
        uint256 _minIncrease,
        uint256 _minPurchase,
        string  _product
    );

    event Register(
        uint256 _minIncrease,
        uint256 _minPurchase,
        address _tokenContractAddress,
        string  _product
    );

    event Deposit(
        address indexed _user, 
        string  _productID,
        string  _symbol,
        uint256 _amount, 
        uint256 _rewards
    );

    event Redeem(
        address indexed _user, 
        string  _productID,
        string  _symbol,
        uint256 _amount, 
        uint256 _rewards
    );

    event SaveATP (
        string  _productID,
        address _user,
        uint256 _amount
    );

    mapping(string => Product) public products;
    mapping(string => uint256) public remainQuotas;
    mapping(string => mapping(address => uint256)) public balances;
    mapping(string => mapping(address => uint256)) public rewards;
    mapping(string => uint256) public total_locks;
    mapping(string => uint256) public total_rewards;
    mapping (string => mapping (address => bool)) private _switch;
    mapping (string => bool) public saveSwitch;

    constructor() public {
        owner = msg.sender;
    }

   modifier onlyOwner() {
       require(msg.sender == owner, "Caller is not owner");
       _;
   }

    modifier isSalePeriod(string memory _productID) {
        require(block.timestamp >= products[_productID].beginSaleTimestamp, "Sale period has not passed");
        require(block.timestamp < products[_productID].endSaleTimestamp, "Sale period has already passed");
        _;
    }

    modifier redeemPeriod(string memory _productID) {
        require(block.timestamp > expiration(_productID), "Lock period has already passed");
        _;
    }

    function () external payable {
    }

    /**
     * @dev Change contract owner
     */

    function setOwner(address _owner) external onlyOwner {
        require(_owner != address(uint160(0)), "New owner is the zero address");
        owner = _owner;
    }

    /**
     * @dev Product revenue payment
     */

    function saveATP(string calldata _productID) external payable {
        require(!saveSwitch[_productID]);
        require(msg.value == total_rewards[_productID]);
        saveSwitch[_productID] = true;
        emit SaveATP(_productID, msg.sender, msg.value);
    }

    /**
     * @dev Product registration
     */

    function register(string memory _productID, address _tokenContractAddress, string memory _name, string memory _symbol, uint256 _productDuration, uint256 _rewardsPerLockToken, uint256 _minIncrease, uint256 _totalQuota, uint256 _minPurchase, uint256 _beginSaleTimestamp, uint256 _endSaleTimestamp, uint256 _releaseTime) public onlyOwner {
        require(_productDuration >= minProductDuration);
        require(_endSaleTimestamp > _beginSaleTimestamp); 
        require(_totalQuota > 0); 
        require(_minPurchase > 0);
        require(_minIncrease > 0);
        require(_rewardsPerLockToken > 0);
        require(bytes(_name).length > 0);
        require(bytes(_symbol).length > 0);
        require(bytes(products[_productID].name).length == 0);
        if (_symbol.compareTo("ATP")) {
            products[_productID].tokenContractAddress = _tokenContractAddress;
            products[_productID].name = _name;
            products[_productID].symbol = _symbol;
            products[_productID].productDuration = _productDuration;
            products[_productID].rewardsPerLockToken = _rewardsPerLockToken;
            products[_productID].minIncrease = _minIncrease;
            products[_productID].totalQuota = _totalQuota;
            products[_productID].minPurchase = _minPurchase;
            products[_productID].beginSaleTimestamp = _beginSaleTimestamp;
            products[_productID].endSaleTimestamp = _endSaleTimestamp;
            products[_productID].releaseTime = _releaseTime;
            remainQuotas[_productID] = _totalQuota;
            string memory product = _productID.concat("||");
            product = product.concat(_name);
            product = product.concat("||");
            product = product.concat(_symbol);
            product = product.concat("||");
            product = product.concat(_totalQuota.toString());
            product = product.concat("||");
            product = product.concat(_productDuration.toString());
            product = product.concat("||");
            product = product.concat(_rewardsPerLockToken.toString());
            product = product.concat("||");
            product = product.concat(_beginSaleTimestamp.toString());
            product = product.concat("||");
            product = product.concat(_endSaleTimestamp.toString());
            if (_releaseTime == 0) {
                product = product.concat("||0");
            } else {
                product = product.concat("||");
                product = product.concat(_releaseTime.toString());
            }
            emit RegisterATP(_minIncrease, _minPurchase, product);
        } else {
            require(_tokenContractAddress.isContract(), "tokenContractAddress is non-contract");
            products[_productID].tokenContractAddress = _tokenContractAddress;
            products[_productID].name = _name;
            products[_productID].symbol = _symbol;
            products[_productID].productDuration = _productDuration;
            products[_productID].rewardsPerLockToken = _rewardsPerLockToken;
            products[_productID].minIncrease = _minIncrease;
            products[_productID].totalQuota = _totalQuota;
            products[_productID].minPurchase = _minPurchase;
            products[_productID].beginSaleTimestamp = _beginSaleTimestamp;
            products[_productID].endSaleTimestamp = _endSaleTimestamp;
            products[_productID].releaseTime = _releaseTime;
            remainQuotas[_productID] = _totalQuota;
            string memory product = _productID.concat("||");
            product = product.concat(_name);
            product = product.concat("||");
            product = product.concat(_symbol);
            product = product.concat("||");
            product = product.concat(_totalQuota.toString());
            product = product.concat("||");
            product = product.concat(_productDuration.toString());
            product = product.concat("||");
            product = product.concat(_rewardsPerLockToken.toString());
            product = product.concat("||");
            product = product.concat(_beginSaleTimestamp.toString());
            product = product.concat("||");
            product = product.concat(_endSaleTimestamp.toString());
            if (_releaseTime == 0) {
                product = product.concat("||0");
            } else {
                product = product.concat("||");
                product = product.concat(_releaseTime.toString());
            }
            emit Register(_minIncrease, _minPurchase, _tokenContractAddress, product);
        }
    }

    /**
     * @dev User deposits locked token
     * @param _productID Product ID
     * @param amount Amounts of locked tokens
     */

    function deposit(string calldata _productID, uint256 amount) external isSalePeriod(_productID) payable {
        uint256 depositReward = 0;
        if (products[_productID].symbol.compareTo("ATP")) {
            require(amount == msg.value, "deposit amount is incorrect");
            require(msg.value >= products[_productID].minPurchase, "ATP amount lower than lock threshold");
            require(msg.value <= remainQuotas[_productID], "ATP amount exceeds the remaining quota");
            require(msg.value.mod(products[_productID].minIncrease) == 0, "Can't buy part ATP amount");
            depositReward = msg.value.div(products[_productID].minIncrease).mul(products[_productID].rewardsPerLockToken);
            balances[_productID][msg.sender] = balances[_productID][msg.sender].add(msg.value);
            rewards[_productID][msg.sender] = rewards[_productID][msg.sender].add(depositReward);        
        } else {
            require(IERC20(products[_productID].tokenContractAddress).balanceOf(msg.sender) >= amount, "Your balance is insufficient");
            require(amount >= products[_productID].minPurchase, "Cannot deposit lower than minPurchase");
            require(amount <= remainQuotas[_productID], "Token amount exceeds the remaining quota");
            require(amount.mod(products[_productID].minIncrease) == 0, "Can't buy part Token amount");
            depositReward = amount.div(products[_productID].minIncrease).mul(products[_productID].rewardsPerLockToken);
            IERC20(products[_productID].tokenContractAddress).safeTransferFrom(msg.sender, address(this), amount);
            balances[_productID][msg.sender] = balances[_productID][msg.sender].add(amount);
            rewards[_productID][msg.sender] = rewards[_productID][msg.sender].add(depositReward);
        }
        remainQuotas[_productID] = remainQuotas[_productID].sub(amount);
        total_locks[_productID] = total_locks[_productID].add(amount);
        total_rewards[_productID] = total_rewards[_productID].add(depositReward);
        _switch[_productID][msg.sender] = true;
        emit Deposit(msg.sender, _productID, products[_productID].symbol, amount, depositReward);
    }

    /**
     * @dev Users redeem locked assets and receive income
     * @param _productID Product ID
     */

    function redeem(string calldata _productID) external redeemPeriod(_productID) {
        if (products[_productID].symbol.compareTo("ATP")) {
            require(_switch[_productID][msg.sender], "User has already redeem");
            require(address(this).balance >= balances[_productID][msg.sender].add(rewards[_productID][msg.sender]), "Contract ATP balance is insufficient");
            msg.sender.transfer(balances[_productID][msg.sender].add(rewards[_productID][msg.sender]));
        } else {
            require(_switch[_productID][msg.sender], "User has already redeem");
            require(IERC20(products[_productID].tokenContractAddress).balanceOf(address(this)) >= balances[_productID][msg.sender], "Contract token balance is insufficient");
            require(address(this).balance >=  rewards[_productID][msg.sender], "Contract ATP balance is insufficient");
            IERC20(products[_productID].tokenContractAddress).safeTransfer(msg.sender, balances[_productID][msg.sender]);
            msg.sender.transfer(rewards[_productID][msg.sender]);
        }
        _switch[_productID][msg.sender] = false;
        total_rewards[_productID] = total_rewards[_productID].sub(rewards[_productID][msg.sender]);
        uint256 balance_user = balances[_productID][msg.sender];
        uint256 reward_user = rewards[_productID][msg.sender];
        balances[_productID][msg.sender] = 0;
        rewards[_productID][msg.sender] = 0;
        emit Redeem(msg.sender, _productID, products[_productID].symbol, balance_user, reward_user);
    }

    /**
     * @dev Product lock in deadline
     * @param _productID Product ID
    */

    function lastTimeLockPeriod(string memory _productID) public view returns(uint256) {
        return products[_productID].endSaleTimestamp.add(products[_productID].productDuration);
    }

    /**
     * @dev Product lock expiration notice time
     * @param _productID Product ID
    */

    function expiration(string memory _productID) public view returns(uint256) {
        return products[_productID].endSaleTimestamp.add(products[_productID].productDuration).add(products[_productID].releaseTime);
    }
}
