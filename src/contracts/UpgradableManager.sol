pragma solidity 0.4.24;

contract UpgradableManager {
    address _implementation;
    address owner;
    address[] public delegates;
    event Upgraded(address implementation);

    constructor() public {
        owner = msg.sender;
        delegates.push(msg.sender);
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function implementation() public view returns (address) {
        return _implementation;
    }

    function inDelegates(address addr) public returns(bool) {
        for(uint i = 0; i< delegates.length; i++) {
            if(addr == delegates[i]) {
                return true;
            }
        }
        return false;
    }

    function upgradeTo(address impl) public onlyOwner returns (bool){
        require(_implementation != impl);
        // add to delegates
        if(!inDelegates(impl)) {
            delegates.push(impl);
        }
        //call register manager
        bytes4 methodId = bytes4(keccak256("setManagerAddr(address,address)"));
        impl.call(methodId, this, msg.sender);

        // call migrate
        bytes4 migrateId = bytes4(keccak256("migrate(address)"));
        bool isSuccess = impl.call(migrateId, _implementation);
        _implementation = impl;
        emit Upgraded(impl);

        return isSuccess;
    }

    // fallback function
    function() payable external {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)

        // (1) copy incoming call data
            calldatacopy(ptr, 0, calldatasize)

        // (2) forward call to logic contract
            let result := call(sub(gas, 10000), _impl, 0, ptr, calldatasize, 0, 0)
            let size := returndatasize

        // (3) retrieve return data
            returndatacopy(ptr, 0, size)

        // (4) forward return data back to caller
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
