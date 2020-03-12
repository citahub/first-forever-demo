pragma solidity 0.4.24;


contract SimpleStore {
    mapping (address => mapping (uint256 => Message)) private records;
    mapping (address => uint256[]) private categories;

    struct Message {
        string msgType;
        string msgContent;
        uint256 time;
    }

    event Recorded(address _sender, string indexed _text, string msgType, uint256 indexed _time);

    function _addToList(address from, uint256 time) private {
        categories[from].push(time);
    }

    function getList()
    public
    view
    returns (uint256[])
    {
        return categories[msg.sender];
    }

    function add(string text, uint256 time, string msgType) public {
        Message memory message;

        if(keccak256(msgType) == keccak256("image")) {
            message = Message("image", text, time);
        } else {
            message = Message("text", text, time);
        }

        records[msg.sender][time]=message;
        _addToList(msg.sender, time);
        emit Recorded(msg.sender, text, msgType, time);
    }

    function get(uint256 time) public view returns(string msgType, string msgContent, uint256 msgTime) {
        Message message = records[msg.sender][time];
        return (message.msgType, message.msgContent, message.time);
    }
}
