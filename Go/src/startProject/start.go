package main

import (
	"fmt"
	"math"
  "runtime"
	"frPackage"
)

const EPSILON float64 = 0.000001

func Sqrt(x float64) float64 {
  //With the Newton method, the lower the z value is,
  //the closer to the square root
	var z float64 = 1.0

	prevZ := 0.0
  delta := z - prevZ

	for delta>EPSILON || -delta< -EPSILON {
		newZ := z - ( (math.Pow(z,2) - x) / (2 * z))

		prevZ = z;
		z = newZ;
    delta = z - prevZ;
	}
	return z
}

func main() {
  fmt.Println("Newton Form value: ",Sqrt(2))
  fmt.Println("Square root value: ",math.Sqrt(2))

  fmt.Print("Go runs on ")
  switch os := runtime.GOOS; os {
    case "darwin":
      fmt.Println("OS X.")
    case "linux":
      fmt.Println("Linux.")
    default:
      // freebsd, openbsd,
      // plan9, windows...
      fmt.Printf("%s.", os)
    }

		//sample test on test package
		fmt.Printf("%v \n",frPackage.ToPrint())
}
