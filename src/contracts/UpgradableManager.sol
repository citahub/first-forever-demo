pragma solidity 0.4.24;

contract UpgradableManager {
    address _implementation;
    address owner;
    event Upgraded(address indexed implementation);

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
        // copy incoming call data
        // official new version is 'calldatacopy(ptr, 0, calldatasize)'

        bytes memory data = msg.data;

        assembly {
        // forward call to logic contract
            let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
        // 获取0x40位置往下32个字节存储的数据
            let ptr := mload(0x40)
        // retrieve return data
            returndatacopy(ptr, 0, size)
        // forward return data back to caller
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
