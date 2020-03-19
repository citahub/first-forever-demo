pragma solidity 0.4.24;
import "./Upgradable.sol";
import "./SimpleStore.sol";

contract SimpleStoreV2 {
    address owner;
    mapping (address => mapping (uint256 => Message)) private records;
    mapping (address => uint256[]) private categories;
    address public managerAddr;
    address[] public users;
    address public prevAddr;

    struct Message {
        string msgType;
        string msgContent;
        uint256 msgTime;
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

    event Recorded(address _sender, string indexed _text, string msgType, uint256 indexed _time);

    function SimpleStoreV2() public {
        owner = msg.sender;
    }

    function migrate(address prev) public {
        prevAddr = prev;
        SimpleStore old = SimpleStore(prev);
        address[] memory oldUsers = old.getUsers();
        users = oldUsers;
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

    function _addToList(address from, uint256 time) private {
        categories[from].push(time);
    }

    function getList()
    public
    view
    returns (uint256[] memory)
    {
        return categories[msg.sender];
    }

    function add(string memory text, uint256 time, string memory msgType) public {
        Message memory message;

        if(keccak256(abi.encodePacked(msgType)) == keccak256("image")) {
            message = Message("image", text, time);
        } else {
            message = Message("text", text, time);
        }

        records[msg.sender][time]=message;
        _addUser(msg.sender);
        _addToList(msg.sender, time);
        emit Recorded(msg.sender, text, msgType, time);
    }

    function get(uint256 time) public view returns(string memory msgContent, string memory msgType,uint256 msgTime) {
        Message memory message = records[msg.sender][time];
        return (message.msgContent, message.msgType, message.msgTime);
    }

    function getUsers() public view onlyDelegatesAndOwner returns(address[]) {
        return users;
    }

    function setManagerAddr(address _managerAddr, address senderAddr) {
        require(senderAddr == owner);
        managerAddr = _managerAddr;
    }
}
