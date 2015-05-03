// this is just a test package
package frPackage

import (
  "fmt"
	"math"
  "runtime"
)


// Package Constants
const EPSILON float64 = 0.000001

// print a simple string as a test
func ToPrint() (ret string) {
  ret ="hello from my first package"
  return
}

func GetOSVersion() {
  fmt.Print("Go runs on ")
  switch os := runtime.GOOS; os {
    case "darwin":
      fmt.Println("OS X.")
      fallthrough // This is nifty. This is the default behavior in C/C++. Here,
                  //    I need this statement for tto actually happen.
    case "linux":
      fmt.Println("Linux.")
      fallthrough
    default:
      // freebsd, openbsd,
      // plan9, windows...
      fmt.Printf("%s.", os)
    }
}

func Sqrt(x float64) float64 {
  // With the Newton method, the lower the z value is,
  // the closer to the square root
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
