package main

import (
	"fmt"
	"math"
	"frPackage"
)

func main() {
	defer fmt.Println("This statement was deferred.\n\n")

  fmt.Println("Newton Form value: ",frPackage.Sqrt(2))
  fmt.Println("Square root value: ",math.Sqrt(2))

  frPackage.GetOSVersion();

  //sample test on test package
  fmt.Printf("Reversed sample: %s \n",frPackage.Reverse(frPackage.ToPrint()))

	fmt.Println("\n\nBut this was not.")
}
