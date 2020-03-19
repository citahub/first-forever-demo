pragma solidity 0.4.24;
import "./Upgradable.sol";

contract SimpleStore {
    address owner;
    mapping (address => mapping (uint256 => string)) private records;
    mapping (address => uint256[]) private categories;
    address public managerAddr;
    address[] private users;

    function SimpleStore() public {
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


    event Recorded(address _sender, string indexed _text, uint256 indexed _time);

    function _addToList(address from, uint256 time) private {
        categories[from].push(time);
    }

    function getList() public view returns (uint256[] memory) {
        return categories[msg.sender];
    }

    function getListFromAddress(address addr) public view onlyOwner returns(uint256[] memory) {
        return categories[addr];
    }

    function _addUser(address newUser) private {
        uint arrayLength = users.length;
        if(arrayLength == 0) {
            users.push(newUser);
        } else {
            bool found=false;
            for (uint i=0; i<arrayLength; i++) {
                if(users[i] == newUser){
                    found=true;
                    break;
                }
            }
            if(!found){
                users.push(newUser);
            }
        }

    }

    function add(string memory text, uint256 time) public {
        records[msg.sender][time]=text;
        _addUser(msg.sender);
        _addToList(msg.sender, time);
        emit Recorded(msg.sender, text, time);
    }

    function get(uint256 time) public view returns(string memory) {
        return records[msg.sender][time];
    }

    function getUsers() public view onlyDelegatesAndOwner returns(address[]) {
        return users;
    }

    function setManagerAddr(address _managerAddr, address senderAddr) {
        require(senderAddr == owner);
        managerAddr = _managerAddr;
    }
}
