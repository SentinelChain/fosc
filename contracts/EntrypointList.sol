pragma solidity 0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Operatable.sol";

contract EntrypointList is Operatable {        
    uint public _nextId = 0;

    mapping(uint => bytes) public _entrypointList;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address is required");
        owner = _owner;
    }
    
    function AddEntryPoint(bytes entryPoint) external onlyOperator    
    {        
         _entrypointList[_nextId] = entryPoint;
         _nextId++;         
    }

    function EntryPoint(uint id) external onlyOperator  
    returns(bytes)  
    {
        return _entrypointList[id];
    }
}