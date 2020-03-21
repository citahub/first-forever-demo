pragma solidity 0.4.24;
import "./Delegated.sol";

contract SimpleStore is Delegated {
    mapping (address => mapping (uint256 => string)) private records;
    mapping (address => uint256[]) private categories;


    address[] private users;

    event Recorded(address _sender, string indexed _text, uint256 indexed _time);

    function _addToList(address from, uint256 time) private {
        categories[from].push(time);
    }

    function getList() public view returns (uint256[] memory) {
        return categories[msg.sender];
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

    function getListFromAddress(address addr) public view onlyDelegatesAndOwner returns(uint256[] memory) {
        return categories[addr];
    }

}
