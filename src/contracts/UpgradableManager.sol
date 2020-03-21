pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract UpgradableManager {
    address _implementation;
    address owner;
    address[] public delegates;
    mapping(address => string) delegateNames;
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

    function inDelegates(address addr) public returns (bool) {
        for(uint i = 0; i < delegates.length; i++) {
            if(addr == delegates[i]) {
                return true;
            }
        }
        return false;
    }

    function getDelegateName(address delegate) public returns (string) {
        return delegateNames[delegate];
    }

    function upgradeTo(address impl, string name) public onlyOwner returns (bool){
        require(_implementation != impl);
        // add to delegates
        if(!inDelegates(impl)) {
            delegates.push(impl);
            delegateNames[impl] = _toVersionName(name);
        }
        // call register manager
        bytes4 setManagerId = bytes4(keccak256("setManagerAddr(address,address)"));
        impl.call(setManagerId, this, msg.sender);
        // call migrate
        bytes4 migrateId = bytes4(keccak256("migrate(address)"));
        bool isSuccess = impl.call(migrateId, _implementation);
        // replace new implementation address
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

    function _toVersionName(string name) private returns (string) {
        if(bytes(name).length > 0) {
            return name;
        } else {
            return string(abi.encodePacked("version: ", _uint2str(delegates.length)));
        }
    }

    function _uint2str(uint i) internal pure returns (string){
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}
