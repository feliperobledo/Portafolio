package main

import (
	"fmt"
	//"math"
	"Math2D"
)

func main() {
	fmt.Println("Testing structs and pointers");

	var p1 Math2D.P2int;
	(&p1).PrintPoint();

  // The return type of the new function is a pointer on the heap
	var p2 = Math2D.Point2D_Int_New(5,5);
	p2.PrintPoint();

	// The return type is a slice/array of vertices.
	// According to the documentation, a slice is a pointer to an array.
	// According to the doucmentation, a slice is pertty much a C++ vector
	var pArray Math2D.Point2DArray = Math2D.Point2D_Int_Array(5);
	pArray.PrintPoint();

	// According to the documentation, there is also such a thing as maps, which
	//   is your standard hash-map
}
