package main

import (
	"fmt"
	"math"
	"frPackage"
)

func main() {
	// defer pushes the function onto a stack, and the stack is popped when
	//     leaving the current function's scope. It is as if they are actually
	//     pushing the function calls onto this function's stack, and poppping them
	//     at the end.
	{
		// This does not even pop it at the end of this scope, and yet this is valid
		//    Go code.
		defer fmt.Println("This statement was deferred.\n\n")
	}
	// Cannot take the address of a function :(
  fPtr := &(fmt.Println);

  fmt.Println("Newton Form value: ",frPackage.Sqrt(2))
  fmt.Println("Square root value: ",math.Sqrt(2))

  frPackage.GetOSVersion();

  //sample test on test package
  fmt.Printf("Reversed sample: %s \n",frPackage.Reverse(frPackage.ToPrint()))

	fmt.Println("\n\nBut this was not.")
}
