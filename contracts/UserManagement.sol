// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title User Management for Pet-Friendly dApp
 * @dev Manages user registrations, profiles, and roles within the dApp.
 */
contract UserManagement {
    struct UserProfile {
        address userAddress;
        string username;
        string role; // e.g., "host", "guest", "serviceProvider"
        bool isRegistered;
    }

    // Mapping from user address to user profile
    mapping(address => UserProfile) private userProfiles;

    // Event declarations
    event UserRegistered(address userAddress, string username, string role);
    event UserProfileUpdated(address userAddress, string newUsername, string newRole);

    /**
     * @notice Registers a new user in the dApp.
     * @param _username The username of the new user.
     * @param _role The role of the new user (e.g., "host", "guest", "serviceProvider").
     */
    function registerUser(string memory _username, string memory _role) public {
        require(!userProfiles[msg.sender].isRegistered, "User already registered.");

        userProfiles[msg.sender] = UserProfile({
            userAddress: msg.sender,
            username: _username,
            role: _role,
            isRegistered: true
        });

        emit UserRegistered(msg.sender, _username, _role);
    }

    /**
     * @notice Updates the profile of an existing user.
     * @param _newUsername The new username for the user.
     * @param _newRole The new role for the user.
     */
    function updateUserProfile(string memory _newUsername, string memory _newRole) public {
        require(userProfiles[msg.sender].isRegistered, "User not registered.");

        userProfiles[msg.sender].username = _newUsername;
        userProfiles[msg.sender].role = _newRole;

        emit UserProfileUpdated(msg.sender, _newUsername, _newRole);
    }

    /**
     * @notice Retrieves the profile of a user.
     * @param _userAddress The address of the user whose profile is being queried.
     * @return UserProfile The profile of the requested user.
     */
    function getUserProfile(address _userAddress) public view returns (UserProfile memory) {
        require(userProfiles[_userAddress].isRegistered, "User not registered.");
        return userProfiles[_userAddress];
    }

    /**
    * @notice Checks if a user is registered and returns their role.
    * @param _userAddress The address of the user to check.
    * @return isRegistered Indicates if the user is registered.
    * @return role The role of the user.
    */
    function getUserInfo(address _userAddress) public view returns (bool isRegistered, string memory role) {
        UserProfile storage profile = userProfiles[_userAddress];
        return (profile.isRegistered, profile.role);
    }
}
