pragma solidity 0.4.24;
import "./UpgradableManager.sol";

interface migration {
    function migrate(address prev) external;
}

contract Delegated is migration{
    address internal managerAddr;
    address internal owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier onlyDelegatesAndOwner() {
        UpgradableManager manager = UpgradableManager(managerAddr);
        require(msg.sender == owner || manager.inDelegates(msg.sender));
        _;
    }

    function setManagerAddr(address _managerAddr, address senderAddr) public {
        require(senderAddr == owner);
        managerAddr = _managerAddr;
    }

    function migrate(address prev) public {}
}
