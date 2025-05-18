// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Proxy contract implementing EIP-1967 transparent proxy pattern
contract Proxy {
    // EIP-1967 storage slot for implementation address
    bytes32 private constant IMPLEMENTATION_SLOT = 
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    // EIP-1967 storage slot for admin address
    bytes32 private constant ADMIN_SLOT = 
        0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    // Event emitted when implementation is upgraded
    event Upgraded(address indexed implementation);

    // Constructor sets initial admin and implementation
    constructor(address _implementation) {
        _setAdmin(msg.sender);
        _setImplementation(_implementation);
    }

    // Modifier to restrict functions to admin
    modifier onlyAdmin() {
        require(msg.sender == _getAdmin(), "Proxy: caller is not admin");
        _;
    }

    // Fallback function delegates calls to implementation
    fallback() external payable {
        // If caller is admin, execute admin functions directly
        if (msg.sender == _getAdmin()) {
            revert("Proxy: admin cannot call delegate functions");
        }
        _delegate(_getImplementation());
    }

    // Receive function to accept Ether
    receive() external payable {}

    // Upgrade implementation (admin only)
    function upgradeTo(address _newImplementation) external onlyAdmin {
        require(_newImplementation != address(0), "Proxy: invalid implementation");
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }

    // Get current implementation address
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }

    // Get current admin address
    function getAdmin() external view returns (address) {
        return _getAdmin();
    }

    // Internal function to get implementation address from storage slot
    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    // Internal function to set implementation address
    function _setImplementation(address _implementation) internal {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _implementation)
        }
    }

    // Internal function to get admin address from storage slot
    function _getAdmin() internal view returns (address admin) {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            admin := sload(slot)
        }
    }

    // Internal function to set admin address
    function _setAdmin(address _admin) internal {
        bytes32 slot = ADMIN_SLOT;
        assembly {
            sstore(slot, _admin)
        }
    }

    // Delegate call to implementation contract
    function _delegate(address _implementation) internal {
        assembly {
            // Copy msg.data to memory
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            // Delegatecall to implementation
            let result := delegatecall(gas(), _implementation, ptr, calldatasize(), 0, 0)

            // Copy return data
            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            // Handle result
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}