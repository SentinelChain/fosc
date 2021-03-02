pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "solidity-bytes-utils/contracts/BytesLib.sol";
import "./shared/ERC677Receiver.sol";

contract FOSC is ERC677Receiver {
    using BytesLib for bytes;

    IERC20 public token;
    uint256 public callValue;
    address public oracle;
    address public owner;
    uint256 private callId = 0;

    enum Status {NEW, PENDING, SUCCESS, FAILED}

    struct CallStruct {
        bytes data;
        address caller;
        uint256 callValue;
        Status status;
        bytes result;
        uint256 entrypointId;
    }

    mapping(uint256 => CallStruct) public calls;

    event LogNewAPICall(
        address indexed _caller,
        uint256 indexed _callId,
        bytes _data
    );
    event LogOracleAddressChanged(
        address _oldAddress, 
        address _newAddress
    );
    event LogCallValueUpdated(
        uint256 _oldValue, 
        uint256 _newValue
    );
    event LogWithdraw(
        address _account, 
        uint256 _amount
    );
    event LogCallStatusUpdated(
        address _caller,
        uint256 _callId,
        Status _newStatus
    );
    event LogCallFinished(
        address _caller,
        uint256 _callId,
        Status _newStatus,
        bytes _result
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier onlyOracle() {
        require(msg.sender == oracle, "Caller is not the oracle");
        _;
    }

    constructor(
        address _newOracle,
        uint256 _callValue,
        IERC20 _token
    ) public {
        require(_newOracle != address(0), "New oracle address is required");
        require(_callValue != 0, "Call value must be greater than 0");
        require(address(_token) != address(0), "Token address is required");
        owner = msg.sender;
        oracle = _newOracle;
        callValue = _callValue;
        token = _token;
    }

    struct InputStruct
    {
        uint256 entrypointId;
        bytes data;
    }

    function convertByteToStruct(bytes inputData) private
    returns (InputStruct output)
    {
        for (uint i=0; i<4; i++)
        {
            uint256 temp = uint256(inputData[i]);
            temp <<= 8 * i;
            output.entrypointId ^= temp;
        }

        output.data = inputData;
    }    

    function onTokenTransfer(
        address _from,
        uint256 _value,
        bytes memory _data
    ) external override returns (bool) {
        require(msg.sender == address(token), "Sender must be SENI token");
        require(_value == callValue, "Wrong amount of SENI");

        InputStruct memory inputStruct = convertByteToStruct(_data);

        require(inputStruct.data.length > uint256, "Length of InputStruct.data cannot exist 256 bytes");

        callId++;
        calls[callId].data = inputStruct.data;
        calls[callId].entrypointId = inputStruct.entrypointId;
        calls[callId].caller = _from;
        calls[callId].callValue = _value;
        calls[callId].status = Status.NEW;

        emit LogNewAPICall(_from, callId, _data);
        return true;
    }

    function setOracle(address _newOracle) external onlyOwner {
        require(_newOracle != address(0), "New oracle address is required");
        address oldAddress = oracle;
        oracle = _newOracle;

        emit LogOracleAddressChanged(oldAddress, _newOracle);
    }

    function setCallValue(uint256 _callValue) external onlyOwner {
        require(_callValue != 0, "CallValue is required");
        uint256 oldValue = _callValue;
        callValue = _callValue;

        emit LogCallValueUpdated(oldValue, callValue);
    }

    function updateCallStatus(
        uint256 _callId,
        Status _newStatus,
        bytes memory _result
    ) external onlyOracle {
        require(_callId != 0, "CallId is required field");
        require(calls[_callId].caller != address(0), "Invalid callId");
        require(_newStatus == Status.PENDING || _newStatus == Status.SUCCESS || _newStatus == Status.FAILED,"Invalid status.");
        require(calls[_callId].status != Status.SUCCESS && calls[_callId].status != Status.FAILED,"Status is final and cannot be changed.");

        calls[_callId].status = _newStatus;
        if (_newStatus == Status.SUCCESS) {
            calls[_callId].result = _result;
            emit LogCallFinished(
                calls[_callId].caller,
                _callId,
                _newStatus,
                _result
            );
        } else if (_newStatus == Status.FAILED){
            emit LogCallFinished(
                calls[_callId].caller,
                _callId,
                _newStatus,
                _result
            );
        }
        else
        {
            emit LogCallStatusUpdated(
                calls[_callId].caller,
                _callId,
                _newStatus
            );
        }
    }

    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0, "Amount parameter is required");
        require(
            token.balanceOf(address(this)) >= _amount,
            "FOSC contrac do not have enough balance"
        );
        token.transfer(msg.sender, _amount);

        emit LogWithdraw(msg.sender, _amount);
    }

}
