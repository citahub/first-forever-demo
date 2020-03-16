pragma solidity 0.5.0;

import "./Proxy.sol";

contract SimpleStore is Proxy{
    mapping (address => mapping (uint256 => string)) private records;
    mapping (address => uint256[]) private categories;

    event Recorded(address _sender, string indexed _text, uint256 indexed _time);

    function _addToList(address from, uint256 time) private {
        categories[from].push(time);
    }

    function getList() public view returns (uint256[] memory) {
        return categories[msg.sender];
    }

    function add(string memory text, uint256 time) public {
        records[msg.sender][time]=text;
        _addToList(msg.sender, time);
        emit Recorded(msg.sender, text, time);
    }
    function get(uint256 time) public view returns(string memory) {

        return records[msg.sender][time];
    }
}
