// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserManagement.sol";

/**
 * @title Accommodation Listing for Pet-Friendly dApp
 * @dev Manages accommodation listings, bookings, and availability.
 */
contract AccommodationListing {
    UserManagement private userManagement;

    struct Accommodation {
        uint id;
        address owner;
        string name;
        string description;
        uint pricePerNight;
        bool available;
    }

    uint private nextAccommodationId = 1;
    mapping(uint => Accommodation) private accommodations;
    mapping(address => uint[]) private ownerAccommodationIds;

    // Event declarations
    event AccommodationAdded(uint accommodationId, string name, address owner);
    event AccommodationBooked(uint accommodationId, address guest, uint numberOfNights);
    event AccommodationAvailabilityUpdated(uint accommodationId, bool available);

    constructor(address _userManagementAddress) {
        userManagement = UserManagement(_userManagementAddress);
    }

    /**
     * @notice Adds a new accommodation listing.
     * @param _name The name of the accommodation.
     * @param _description A brief description of the accommodation.
     * @param _pricePerNight The price per night for booking the accommodation.
     */
    function addAccommodation(string memory _name, string memory _description, uint _pricePerNight) public {
        (bool isRegistered, string memory role) = userManagement.getUserInfo(msg.sender);
        require(isRegistered && keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("host")), "Only registered hosts can add accommodations.");
  
        accommodations[nextAccommodationId] = Accommodation({
            id: nextAccommodationId,
            owner: msg.sender,
            name: _name,
            description: _description,
            pricePerNight: _pricePerNight,
            available: true
        });

        ownerAccommodationIds[msg.sender].push(nextAccommodationId);

        emit AccommodationAdded(nextAccommodationId, _name, msg.sender);

        nextAccommodationId++;
    }

    /**
     * @notice Books an accommodation for a specified number of nights.
     * @param _accommodationId The ID of the accommodation to be booked.
     * @param _numberOfNights The number of nights the accommodation is booked for.
     */
    function bookAccommodation(uint _accommodationId, uint _numberOfNights) public payable {
        Accommodation storage accommodation = accommodations[_accommodationId];
        require(accommodation.available, "Accommodation not available.");
        require(msg.value >= accommodation.pricePerNight * _numberOfNights, "Insufficient payment.");

        accommodation.available = false; // Mark as booked

        // Here you would add logic to transfer funds to the owner or to an escrow.
        // For simplicity, this is omitted.

        emit AccommodationBooked(_accommodationId, msg.sender, _numberOfNights);
    }

    /**
     * @notice Updates the availability of an accommodation.
     * @param _accommodationId The ID of the accommodation to update.
     * @param _available The new availability status.
     */
    function updateAccommodationAvailability(uint _accommodationId, bool _available) public {
        Accommodation storage accommodation = accommodations[_accommodationId];
        require(msg.sender == accommodation.owner, "Only the accommodation owner can update availability.");

        accommodation.available = _available;

        emit AccommodationAvailabilityUpdated(_accommodationId, _available);
    }

    /**
     * @notice Retrieves details for a specific accommodation.
     * @param _accommodationId The ID of the accommodation to retrieve.
     * @return Accommodation The accommodation details.
     */
    function getAccommodation(uint _accommodationId) public view returns (Accommodation memory) {
        return accommodations[_accommodationId];
    }

    /**
     * @notice Lists all accommodations owned by a specific user.
     * @param _owner The address of the accommodation owner.
     * @return uint[] A list of accommodation IDs owned by the user.
     */
    function listAccommodationsByOwner(address _owner) public view returns (uint[] memory) {
        return ownerAccommodationIds[_owner];
    }
}
