// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

contract Tris is ReentrancyGuardUpgradeable, ContextUpgradeable {
    enum GameStatus {
        NOT_STARTED,
        ACCEPTED,
        CLOSED
    }
    struct Game {
        address payable player1;
        address payable player2;
        GameStatus status;
        bool turn;
        uint8[9] board;
        uint256 amount;
    }
    mapping(uint256 => Game) public matches;

    constructor(uint _unlockTime) {}

    function createMatch(address player2, bool startFirst) public payable {
        uint256 matchId = uint256(
            keccak256(abi.encodePacked(_msgSender(), player2, block.timestamp))
        );
        matches[matchId] = Game({
            player1: payable(_msgSender()),
            player2: payable(player2),
            board: [0, 0, 0, 0, 0, 0, 0, 0, 0],
            amount: msg.value,
            turn: startFirst,
            status: GameStatus.NOT_STARTED
        });
    }

    function acceptMatch(uint256 matchId) public payable {
        require(_msgSender() == matches[matchId].player2, "Address differs");
        require(msg.value == matches[matchId].amount);
        matches[matchId].status = GameStatus.ACCEPTED;
    }

    function checkWin(uint8[9] memory board) internal pure returns (uint8) {
        // Convert the 1D array to a 3x3 matrix
        uint8 i = 0;
        // Check rows
        for (; i < 9; i += 3) {
            if (
                board[i] == board[i + 1] &&
                board[i] == board[i + 2] &&
                board[i] != 0
            ) {
                return board[i];
            }
        }

        // Check columns
        for (i = 0; i < 3; i++) {
            if (
                board[i] == board[i + 3] &&
                board[i] == board[i + 6] &&
                board[i] != 0
            ) {
                return board[i];
            }
        }

        // Check diagonals
        if (
            (board[0] == board[4] && board[0] == board[8] && board[0] != 0) ||
            (board[2] == board[4] && board[0] == board[6] && board[2] != 0)
        ) {
            return board[i];
        }

        return 0;
    }
}
