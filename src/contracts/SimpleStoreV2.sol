pragma solidity 0.4.24;
import "./SimpleStoreV1.sol";
import "./Delegated.sol";

contract SimpleStoreV2 is Delegated {
    mapping (address => mapping (uint256 => Message)) private records;
    mapping (address => uint256[]) private timeline;
    address[] private users;


    struct Message {
        string msgType;
        string msgContent;
        uint256 msgTime;
    }

    event Recorded(address _sender, string indexed _text, string msgType, uint256 indexed _time);

    function migrate(address prev) public {
        SimpleStore prevStore = SimpleStore(prev);
        migratingUser(prevStore);
        migratingTimeline(prevStore);
        migratingRecords(prevStore);
    }


    function migratingUser(SimpleStore prevStore) {
        address[] memory oldUsers = prevStore.getUsersForMigrating();
        users = oldUsers;
    }

    function migratingTimeline(SimpleStore prevStore) {
        for(uint i = 0; i< users.length; i++) {
            uint256[] memory timestamps = prevStore.getTimelineForMigrating(users[i]);
            timeline[users[i]] = timestamps;
        }
    }

    function migratingRecords(SimpleStore prevStore) {
        for(uint i = 0; i< users.length; i++) {
            address user = users[i];
            for(uint j = 0; j < timeline[user].length; j ++) {
                uint256 timestamp = timeline[user][j];
                string memory text = prevStore.getMessageForMigrating(user, timestamp);
                Message memory textMsg = Message("text", text, timestamp);
                records[user][timestamp] = textMsg;
            }
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
        timeline[from].push(time);
    }

    function getList()
    public
    view
    returns (uint256[] memory)
    {
        return timeline[msg.sender];
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

    function getUsersForMigrating() public view  onlyDelegatesAndOwner returns(address[]) {
        return users;
    }

    function getTimelineForMigrating(address addr) public view onlyDelegatesAndOwner returns(uint256[] memory) {
        return timeline[addr];
    }

    function getMessageForMigrating(address addr, uint256 timestamp) public view onlyDelegatesAndOwner returns (string memory msgContent, string memory msgType,uint256 msgTime){
        Message memory message = records[addr][timestamp];
        return (message.msgContent, message.msgType, message.msgTime);
    }

}
