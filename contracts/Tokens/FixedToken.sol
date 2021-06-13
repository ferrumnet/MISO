pragma solidity 0.6.12;

import "./ERC20.sol";
import "../interfaces/IMisoToken.sol";

// ---------------------------------------------------------------------
//
// From the MISO Token Factory
//
// Made for Sushi.com 
// 
// Enjoy. (c) Chef Gonpachi 2021 
// <https://github.com/chefgonpachi/MISO/>
//
// ---------------------------------------------------------------------
// SPDX-License-Identifier: GPL-3.0-or-later                        
// ---------------------------------------------------------------------

interface ILocker {
    /**
     * @dev Fails if transaction is not allowed. Otherwise returns the penalty.
     * Returns a bool and a uint16, bool clarifying the penalty applied, and uint16 the penaltyOver1000
     */
    function lockOrGetPenalty(address source, address dest)
    external
    returns (bool, uint256);
}

contract FixedToken is ERC20, IMisoToken, Ownable {

    /// @notice Miso template id for the token factory.
    /// @dev For different token types, this must be incremented.
    uint256 public constant override tokenTemplate = 1;
    
    /// @dev First set the token variables. This can only be done once
    function initToken(string memory _name, string memory _symbol, address _owner, uint256 _initialSupply) public  {
        _initERC20(_name, _symbol);
        _mint(msg.sender, _initialSupply);
    }
    function init(bytes calldata _data) external override payable {}

   function initToken(
        bytes calldata _data
    ) public override {
        (string memory _name,
        string memory _symbol,
        address _owner,
        uint256 _initialSupply) = abi.decode(_data, (string, string, address, uint256));

        initToken(_name,_symbol,_owner,_initialSupply);
    }

   /** 
     * @dev Generates init data for Farm Factory
     * @param _name - Token name
     * @param _symbol - Token symbol
     * @param _owner - Contract owner
     * @param _initialSupply Amount of tokens minted on creation
  */
    function getInitData(
        string calldata _name,
        string calldata _symbol,
        address _owner,
        uint256 _initialSupply
    )
        external
        pure
        returns (bytes memory _data)
    {
        return abi.encode(_name, _symbol, _owner, _initialSupply);
    }

    ILocker public override locker;
    function setLocker(address _locker)
    external onlyOwner() {
        locker = ILocker(_locker);
    }

    function _transfer(address sender, address recipient, uint256 amount)
    internal virtual override {
        if (address(locker) != address(0)) {
            locker.lockOrGetPenalty(sender, recipient);
        }
        return ERC20._transfer(sender, recipient, amount);
    }
}

// NOTE: Copied from @openzepplin
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
