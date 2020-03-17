pragma solidity 0.4.24;

contract SimpleStoreV2 {
    address owner;
    mapping (address => mapping (uint256 => Message)) private records;
    mapping (address => uint256[]) private categories;
    struct Message {
        string msgType;
        string msgContent;
        uint256 msgTime;
    }

    event Recorded(address _sender, string indexed _text, string msgType, uint256 indexed _time);

    constructor() public {
        owner = msg.sender;
    }

    function migration(address) {
        require(msg.sender == owner);
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
        _addToList(msg.sender, time);
        emit Recorded(msg.sender, text, msgType, time);
    }

    function get(uint256 time) public view returns(string memory msgContent, string memory msgType,uint256 msgTime) {
        Message memory message = records[msg.sender][time];
//        if(bytes(message.msgType).length == 0) {
//            message =  Message({msgType: 'text', msgContent: , msgTime: time});
//
//        }
        return (message.msgContent, message.msgType, message.msgTime);
    }
}
