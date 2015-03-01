package main

import (
	"fmt"
	"math"
)

const EPSILON float64 = 0.000001

func Sqrt(x float64) float64 {
  //With the Newton method, the lower the z value is,
  //the closer to the square root
	var z float64 = 1.0

	prevZ := 0.0
  delta := z - prevZ

	for delta>EPSILON || -delta< -EPSILON {
    fmt.Println("previous z: %v \n",prevZ)

		newZ := z - ( (math.Pow(z,2) - x) / (2 * z))
    fmt.Println("new z: %v \n",newZ)

		prevZ = z;
		z = newZ;
    delta = z - prevZ;
	}
	return z
}

func main() {
  //var hello, world string = "hello", "world"
  //k := "Eily"

  i:= 42
  f:=float64(i)
  u:=uint(f)

  fmt.Printf("%T %T %T\n",i,f,u)

  var k = 1 << 1
  var k_1 = k << 1;
  fmt.Printf("%v %v\n",k,k_1)

  for i:=0; i < 10; i++{
    fmt.Printf("%v\n",i)
  }

  if false{
    fmt.Printf("Program End\n")
  } else{
    fmt.Printf("Trying something\n")
  }

  fmt.Println(Sqrt(2))
  fmt.Println("Square root value: ",math.Sqrt(2))
}
