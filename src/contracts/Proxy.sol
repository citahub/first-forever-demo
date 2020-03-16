pragma solidity ^0.5.0;

import "@openzeppelin/contracts/ownership/Ownable.sol";

contract Proxy is Ownable {

    event Upgraded(address indexed implementation);

    address internal _implementation;

    function implementation() public view returns (address) {
        return _implementation;
    }

    function upgradeTo(address impl) public onlyOwner {
        require(_implementation != impl);
        _implementation = impl;
        emit Upgraded(impl);
    }
    // fallback function
    function () payable external {
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
