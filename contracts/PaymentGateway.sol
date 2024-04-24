// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Payment Gateway for Pet-Friendly dApp
 * @dev Handles escrow and payments for bookings of accommodations and services.
 */
contract PaymentGateway {
    struct Payment {
        uint256 amount;
        address payer;
        address payee;
        bool isReleased;
    }

    uint256 private nextPaymentId = 1;
    mapping(uint256 => Payment) public payments;

    // Event declarations
    event PaymentDeposited(uint256 paymentId, uint256 amount, address indexed payer, address indexed payee);
    event PaymentReleased(uint256 paymentId, address indexed payee);

    /**
     * @notice Deposits a payment for a booking into escrow.
     * @param _payee The address of the service provider or accommodation owner to receive the payment.
     * @param _amount The amount of the payment.
     * @return The id of the payment deposited.
     */
    function depositPayment(address _payee, uint256 _amount) external payable returns (uint256) {
        require(msg.value == _amount, "Transferred amount does not match the booking cost");

        payments[nextPaymentId] = Payment({
            amount: _amount,
            payer: msg.sender,
            payee: _payee,
            isReleased: false
        });

        emit PaymentDeposited(nextPaymentId, _amount, msg.sender, _payee);

        return nextPaymentId++;
    }

    /**
     * @notice Releases a payment from escrow to the payee.
     * @dev This should ideally be called after the completion of a service or stay.
     * @param _paymentId The id of the payment to be released.
     */
    function releasePayment(uint256 _paymentId) public {
        Payment storage payment = payments[_paymentId];
        
        require(!payment.isReleased, "Payment already released");
        require(msg.sender == payment.payer, "Only the payer can release the payment");
        
        payment.isReleased = true;
        payable(payment.payee).transfer(payment.amount);

        emit PaymentReleased(_paymentId, payment.payee);
    }

    /**
     * @notice Returns payment details.
     * @param _paymentId The id of the payment to retrieve details for.
     * @return Payment details including amount, payer, payee, and release status.
     */
    function getPaymentDetails(uint256 _paymentId) external view returns (Payment memory) {
        return payments[_paymentId];
    }

    // Additional functionality can be added as needed, such as handling refunds or damage claims.
}
