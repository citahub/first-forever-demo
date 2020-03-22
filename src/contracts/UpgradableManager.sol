pragma solidity 0.4.24;
pragma experimental ABIEncoderV2;

contract UpgradableManager {
    address _implementation;
    address owner;
    address[] public delegates;
    string[] public versions;
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

    function upgradeTo(address impl, string name) public onlyOwner returns (bool){
        require(_implementation != impl);
        // add to delegates
        _addToDelegates(impl, name);
        // call register manager
        impl.call(bytes4(keccak256("setManagerAddr(address,address)")), this, msg.sender);
        // call migrate
        bool isSuccess = impl.call(bytes4(keccak256("migrate(address)")), _implementation);
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
            return string(abi.encodePacked("v", _uint2str(delegates.length)));
        }
    }

    function _addressToString(address _address) public pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
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

    function _addToDelegates(address impl, string name) private {
        if(!inDelegates(impl)) {
            delegates.push(impl);
            string memory versionName = _toVersionName(name);
            delegateNames[impl] = versionName;
            string memory versionInfo = string(abi.encodePacked(versionName, ": ", _addressToString(impl)));
            versions.push(versionInfo);
        }
    }
}
