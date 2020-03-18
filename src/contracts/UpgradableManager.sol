pragma solidity 0.4.24;

contract UpgradableManager {
    address _implementation;
    address owner;
    event Upgraded(address implementation);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    function implementation() public view returns (address) {
        return _implementation;
    }

    function upgradeTo(address impl) public onlyOwner {
        require(_implementation != impl);
        // call migrate
        impl.call(bytes4(keccak256("migrate(address)")), _implementation);
        _implementation = impl;
        emit Upgraded(impl);
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
