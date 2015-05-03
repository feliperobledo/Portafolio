package main

import (
	"fmt"
	//"math"
	"Math2D"
)

func main() {
	fmt.Println("Testing structs and pointers");

	var p1 Math2D.Point2D_int;
	Math2D.Point2D_Int_Print(&p1);

  // The return type of the new function is a pointer on the heap
	var p2 = Math2D.Point2D_Int_New(5,5);
	Math2D.Point2D_Int_Print(p2);
}
