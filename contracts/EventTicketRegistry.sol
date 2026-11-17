// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EventTicketRegistry {
    address public organizer;
    uint256 public totalTickets;

    mapping(uint256 => address) private ticketOwners;

    event TicketsCreated(uint256 totalTickets);

    event TicketClaimed(
        uint256 indexed ticketId,
        address indexed owner
    );

    event TicketTransferred(
        uint256 indexed ticketId,
        address indexed from,
        address indexed to
    );

    modifier onlyOrganizer() {
        require(
            msg.sender == organizer,
            "Only organizer can perform this action"
        );
        _;
    }

    constructor() {
        organizer = msg.sender;
    }

    // Organizer creates the ticket supply
    function createTickets(uint256 _totalTickets)
        external
        onlyOrganizer
    {
        require(
            totalTickets == 0,
            "Tickets already created"
        );

        require(
            _totalTickets > 0,
            "Ticket supply must be greater than zero"
        );

        totalTickets = _totalTickets;

        emit TicketsCreated(_totalTickets);
    }

    // User claims an unassigned ticket
    function claimTicket(uint256 _ticketId)
        external
    {
        require(
            _ticketId >= 1 && _ticketId <= totalTickets,
            "Invalid ticket ID"
        );

        require(
            ticketOwners[_ticketId] == address(0),
            "Ticket already assigned"
        );

        ticketOwners[_ticketId] = msg.sender;

        emit TicketClaimed(
            _ticketId,
            msg.sender
        );
    }

    // Ticket owner transfers the ticket
    function transferTicket(
        uint256 _ticketId,
        address _to
    )
        external
    {
        require(
            _ticketId >= 1 && _ticketId <= totalTickets,
            "Invalid ticket ID"
        );

        require(
            ticketOwners[_ticketId] == msg.sender,
            "Only ticket owner can transfer"
        );

        require(
            _to != address(0),
            "Invalid recipient address"
        );

        require(
            _to != msg.sender,
            "Cannot transfer to yourself"
        );

        address oldOwner = ticketOwners[_ticketId];

        ticketOwners[_ticketId] = _to;

        emit TicketTransferred(
            _ticketId,
            oldOwner,
            _to
        );
    }

    // Get current owner of a ticket
    function getTicketOwner(uint256 _ticketId)
        external
        view
        returns (address)
    {
        require(
            _ticketId >= 1 && _ticketId <= totalTickets,
            "Invalid ticket ID"
        );

        return ticketOwners[_ticketId];
    }

    // Check whether a ticket has been claimed
    function isClaimed(uint256 _ticketId)
        external
        view
        returns (bool)
    {
        require(
            _ticketId >= 1 && _ticketId <= totalTickets,
            "Invalid ticket ID"
        );

        return ticketOwners[_ticketId] != address(0);
    }
}
