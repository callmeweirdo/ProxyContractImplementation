// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Example implementation contract for the EIP-1967 proxy
contract Logic {
    // State variable stored in proxy's storage
    uint256 public value;

    // Event emitted when value is updated
    event ValueUpdated(uint256 newValue);

    // Initialize contract with an initial value
    function initialize(uint256 _value) external {
        require(value == 0, "Logic: already initialized");
        value = _value;
        emit ValueUpdated(_value);
    }

    // Set a new value
    function setValue(uint256 _newValue) external {
        value = _newValue;
        emit ValueUpdated(_newValue);
    }

    // Get the current value
    function getValue() external view returns (uint256) {
        return value;
    }

    // Example function to demonstrate upgradability
    function incrementValue() external {
        value += 1;
        emit ValueUpdated(value);
    }
}