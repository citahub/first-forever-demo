pragma solidity 0.4.24;
import "./Delegated.sol";

contract SimpleStore is Delegated {
    mapping (address => mapping (uint256 => string)) private records;
    mapping (address => uint256[]) private timeline;
    address[] private users;

    event Recorded(address _sender, string indexed _text, uint256 indexed _time);

    function _addToList(address from, uint256 time) private {
        timeline[from].push(time);
    }

    function getList() public view returns (uint256[] memory) {
        return timeline[msg.sender];
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

    function getUsersForMigrating() public view onlyDelegatesAndOwner returns(address[]) {
        return users;
    }

    function getTimelineForMigrating(address addr) public view onlyDelegatesAndOwner returns(uint256[] memory) {
        return timeline[addr];
    }

    function getMessageForMigrating(address addr, uint256 timestamp) public view onlyDelegatesAndOwner returns (string){
        return records[addr][timestamp];
    }

}
