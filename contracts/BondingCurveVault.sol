pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract BondingCurveVault is Ownable {

    // Where business logic resides
    address public logicContract;

    event LogLogicContractChanged
    (
        address byWhom,
        address indexed oldContract,
        address newContract
    );

    event LogEthSent(
        uint256 amount,
        address indexed account
    );

    event LogEthReceived(
        uint256 amount,
        address indexed account
    );

    // Enforce logicContract only calls
    modifier onlyLogicContract() {
        require(msg.sender == logicContract);
        _;
    }

    constructor(address _logicContract) public {
        setLogicContract(_logicContract);
    }

    /**
    * @dev Send ETH _amount to _account
    */
    function sendEth(uint256 _amount, address _account) public onlyLogicContract {
        _account.transfer(_amount);
        emit LogEthSent(_amount, _account);
    }

    // payable function mints tokens to sender (donation), sends 90% to logic contract for charity
    /**
     * @dev The fallback function - accepts all ETH as donations to bonding curve. Need this as
     * logic contract transfers the ETH allocation here (i.e. can't use this fallback function to call
     * donate() in Logic.sol)
     */
    function () public payable {
        emit LogEthReceived(msg.value, msg.sender);
    }

    /**
    * @dev Set the 'logicContract' to a different contract address
    */
    function setLogicContract(address _logicContract) public onlyOwner {
        address oldContract = logicContract;
        logicContract = _logicContract;
        emit LogLogicContractChanged(msg.sender, oldContract, _logicContract);
    }

    //allow freezing (only logicContract)
}