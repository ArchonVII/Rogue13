using Godot;
using System;

public class ChessBoard : Node
{
	// The chessboard is represented as a 64-bit integer (ulong)
	// Each bit represents one square (0 = empty, 1 = occupied)
	private ulong boardMask;

	// Initialize the board with a default state
	public override void _Ready()
	{
		// Example: Initialize the board with pieces in their starting positions
		// For simplicity, let's say this is a simplified mask where only pawns are placed
		boardMask = 0b1111111111111111UL; // 16 pawns (8 on A2-H2 and 8 on A7-H7)

		// Print the board's binary state to the console for debugging
		PrintBoard();
	}

	// Function to set a piece at a specific square (set bit to 1)
	public void SetPiece(int squareIndex)
	{
		// Set the bit at squareIndex to 1
		boardMask |= (1UL << squareIndex);
		PrintBoard();
	}

	// Function to clear a piece from a specific square (set bit to 0)
	public void ClearPiece(int squareIndex)
	{
		// Set the bit at squareIndex to 0
		boardMask &= ~(1UL << squareIndex);
		PrintBoard();
	}

	// Function to check if a square is occupied
	public bool IsOccupied(int squareIndex)
	{
		return (boardMask & (1UL << squareIndex)) != 0;
	}

	// Function to move a piece from one square to another
	public void MovePiece(int pickedupSquare, int droppedSquare)
	{
		ClearPiece(pickedupSquare); // Clear the picked-up square
		SetPiece(droppedSquare);    // Set the dropped square
	}

	// Function to print the board's binary mask for debugging
	private void PrintBoard()
	{
		GD.Print("Board Mask: ", Convert.ToString((long)boardMask, 2).PadLeft(64, '0'));
	}
}
