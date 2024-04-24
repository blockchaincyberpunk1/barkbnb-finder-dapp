// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./UserManagement.sol";

/**
 * @title Pet Care Service Listing for Pet-Friendly dApp
 * @dev Manages pet care service listings, bookings, and availability.
 */
contract PetCareServiceListing {
    UserManagement private userManagement;

    struct Service {
        uint id;
        address provider;
        string name;
        string description;
        uint price;
        bool available;
    }

    uint private nextServiceId = 1;
    mapping(uint => Service) private services;
    mapping(address => uint[]) private providerServiceIds;

    // Event declarations
    event ServiceAdded(uint serviceId, string name, address provider);
    event ServiceBooked(uint serviceId, address customer, uint price);
    event ServiceAvailabilityUpdated(uint serviceId, bool available);

    constructor(address _userManagementAddress) {
        userManagement = UserManagement(_userManagementAddress);
    }

    /**
     * @notice Adds a new pet care service listing.
     * @param _name The name of the service.
     * @param _description A brief description of the service.
     * @param _price The price for the service.
     */
    function addService(string memory _name, string memory _description, uint _price) public {
        (bool isRegistered, string memory role) = userManagement.getUserInfo(msg.sender);
        require(isRegistered && keccak256(abi.encodePacked(role)) == keccak256(abi.encodePacked("serviceProvider")), "Only registered service providers can add services.");

        services[nextServiceId] = Service({
            id: nextServiceId,
            provider: msg.sender,
            name: _name,
            description: _description,
            price: _price,
            available: true
        });

        providerServiceIds[msg.sender].push(nextServiceId);

        emit ServiceAdded(nextServiceId, _name, msg.sender);

        nextServiceId++;
    }

    /**
     * @notice Books a pet care service.
     * @param _serviceId The ID of the service to be booked.
     */
    function bookService(uint _serviceId) public payable {
        Service storage service = services[_serviceId];
        require(service.available, "Service not available.");
        require(msg.value >= service.price, "Insufficient payment.");

        service.available = false; // Mark as booked

        // Here you would add logic to transfer funds to the provider or to an escrow.
        // For simplicity, this is omitted.

        emit ServiceBooked(_serviceId, msg.sender, service.price);
    }

    /**
     * @notice Updates the availability of a pet care service.
     * @param _serviceId The ID of the service to update.
     * @param _available The new availability status.
     */
    function updateServiceAvailability(uint _serviceId, bool _available) public {
        Service storage service = services[_serviceId];
        require(msg.sender == service.provider, "Only the service provider can update availability.");

        service.available = _available;

        emit ServiceAvailabilityUpdated(_serviceId, _available);
    }

    /**
     * @notice Retrieves details for a specific service.
     * @param _serviceId The ID of the service to retrieve.
     * @return Service The service details.
     */
    function getService(uint _serviceId) public view returns (Service memory) {
        return services[_serviceId];
    }

    /**
     * @notice Lists all services offered by a specific provider.
     * @param _provider The address of the service provider.
     * @return uint[] A list of service IDs offered by the provider.
     */
    function listServicesByProvider(address _provider) public view returns (uint[] memory) {
        return providerServiceIds[_provider];
    }
}
