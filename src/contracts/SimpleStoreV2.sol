pragma solidity 0.4.24;
import "./SimpleStoreV1.sol";
import "./Delegated.sol";

contract SimpleStoreV2 is Delegated {
    mapping (address => mapping (uint256 => Message)) private records;
    mapping (address => uint256[]) private categories;
    address[] public users;

    struct Message {
        string msgType;
        string msgContent;
        uint256 msgTime;
    }

    event Recorded(address _sender, string indexed _text, string msgType, uint256 indexed _time);

    function migrate(address prev) public {
        SimpleStore old = SimpleStore(prev);
        address[] memory oldUsers = old.getUsers();
        users = oldUsers;
        for(uint i = 0; i< oldUsers.length; i++) {
            uint256[] memory timestamps = old.getListFromAddress(oldUsers[i]);
            categories[oldUsers[i]] = timestamps;
        }
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

    function getUsers() public view  returns(address[]) {
        return users;
    }


}
