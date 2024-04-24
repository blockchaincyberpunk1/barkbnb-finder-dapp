// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BookingManagement.sol";

/**
 * @title Ratings and Reviews for Pet-Friendly dApp
 * @dev Manages the submission and retrieval of ratings and reviews for services and accommodations.
 */
contract RatingsAndReviews {
    BookingManagement private bookingManagement;

    // Struct for holding rating and review details
    struct RatingReview {
        uint256 bookingId;
        address reviewer;
        uint8 rating; // Rating out of 5
        string review;
        bool isAccommodation;
    }

    // Mapping of listing ID to an array of ratings and reviews
    mapping(uint256 => RatingReview[]) private listingReviews;

    // Event declarations
    event ReviewSubmitted(uint256 listingId, address reviewer, uint8 rating, bool isAccommodation);

    /**
     * @dev Constructor to set the BookingManagement contract address.
     * @param _bookingManagementAddress Address of the BookingManagement contract.
     */
    constructor(address _bookingManagementAddress) {
        bookingManagement = BookingManagement(_bookingManagementAddress);
    }

    /**
     * @notice Submits a review for a completed booking.
     * @param _bookingId The ID of the booking being reviewed.
     * @param _rating The rating out of 5 given by the reviewer.
     * @param _review The textual review.
     */
    function submitReview(uint256 _bookingId, uint8 _rating, string calldata _review) external {
        BookingManagement.Booking memory booking = bookingManagement.getBooking(_bookingId);
        
        // Verify that the sender is the user who made the booking
        require(msg.sender == booking.user, "Only the booking user can submit a review");
        
        // Ensure the booking is completed (i.e., not cancelled and the end date has passed for accommodations)
        require(!booking.isCancelled, "Cannot review a cancelled booking");
        require(block.timestamp > booking.endDate || !booking.isAccommodation, "Booking must be completed to review");

        // Rating should be between 1 and 5
        require(_rating >= 1 && _rating <= 5, "Rating must be between 1 and 5");

        listingReviews[booking.listingId].push(RatingReview({
            bookingId: _bookingId,
            reviewer: msg.sender,
            rating: _rating,
            review: _review,
            isAccommodation: booking.isAccommodation
        }));

        emit ReviewSubmitted(booking.listingId, msg.sender, _rating, booking.isAccommodation);
    }

    /**
     * @notice Retrieves all reviews for a given listing.
     * @param _listingId The ID of the listing whose reviews are being requested.
     * @return An array of RatingReview structs for the specified listing.
     */
    function getReviewsForListing(uint256 _listingId) external view returns (RatingReview[] memory) {
        return listingReviews[_listingId];
    }

    // Additional functions can be implemented as needed, such as calculating average ratings, filtering reviews, etc.
}
