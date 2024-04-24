// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./AccommodationListing.sol";
import "./PetCareServiceListing.sol";

/**
 * @title Booking Management for Pet-Friendly dApp
 * @dev Central contract for managing bookings, payments, and cancellations.
 */
contract BookingManagement {
    AccommodationListing private accommodationListing;
    PetCareServiceListing private petCareServiceListing;

    // Structure to hold booking details
    struct Booking {
        uint256 id;
        address user;
        uint256 listingId;
        uint256 startDate;
        uint256 endDate;
        uint256 amountPaid;
        bool isAccommodation;
        bool isCancelled;
    }

    uint256 private nextBookingId = 1;
    mapping(uint256 => Booking) public bookings;
    mapping(address => uint256[]) public userBookings;

    event BookingCreated(uint256 indexed bookingId, uint256 listingId, address user, bool isAccommodation);
    event BookingCancelled(uint256 indexed bookingId, uint256 listingId, address user, bool isAccommodation);

    /**
     * @dev Constructor function to set the listings contracts addresses.
     * @param _accommodationListingAddress Address of the AccommodationListing contract.
     * @param _petCareServiceListingAddress Address of the PetCareServiceListing contract.
     */
    constructor(address _accommodationListingAddress, address _petCareServiceListingAddress) {
        accommodationListing = AccommodationListing(_accommodationListingAddress);
        petCareServiceListing = PetCareServiceListing(_petCareServiceListingAddress);
    }

    /**
     * @notice Creates a booking for an accommodation or service.
     * @param _listingId ID of the listing (accommodation or service) to be booked.
     * @param _startDate Start date of the booking (for accommodations).
     * @param _endDate End date of the booking (for accommodations).
     * @param _isAccommodation True if booking an accommodation, false for service.
     */
    function createBooking(uint256 _listingId, uint256 _startDate, uint256 _endDate, bool _isAccommodation) external payable {
        require(msg.value > 0, "Payment must be greater than 0");

        // Logic to handle accommodation booking
        if (_isAccommodation) {
            require(_endDate > _startDate, "Invalid booking dates");
            // Additional checks and logic specific to accommodations
            // accommodationListing.bookAccommodation(_listingId, ...);
        } else {
            // Logic to handle pet care service booking
            // petCareServiceListing.bookService(_listingId, ...);
        }

        bookings[nextBookingId] = Booking({
            id: nextBookingId,
            user: msg.sender,
            listingId: _listingId,
            startDate: _startDate,
            endDate: _endDate,
            amountPaid: msg.value,
            isAccommodation: _isAccommodation,
            isCancelled: false
        });

        userBookings[msg.sender].push(nextBookingId);

        emit BookingCreated(nextBookingId, _listingId, msg.sender, _isAccommodation);

        nextBookingId++;
    }

    /**
     * @notice Cancels a booking.
     * @param _bookingId ID of the booking to cancel.
     */
    function cancelBooking(uint256 _bookingId) external {
        Booking storage booking = bookings[_bookingId];
        require(msg.sender == booking.user, "Only the booking user can cancel");
        require(!booking.isCancelled, "Booking is already cancelled");

        booking.isCancelled = true;
        // Refund logic or handling fees

        emit BookingCancelled(_bookingId, booking.listingId, msg.sender, booking.isAccommodation);
    }

    /**
     * @notice Retrieves details for a specific booking.
     * @param _bookingId ID of the booking to retrieve.
     * @return Booking details.
     */
    function getBooking(uint256 _bookingId) external view returns (Booking memory) {
        return bookings[_bookingId];
    }

    // Additional functions as needed for managing bookings, payments, and disputes
}
