package main

import (
	"fmt"
	"math"
)

const EPSILON float64 = 0.000001

func Sqrt(x float64) float64 {
	var z float64 = 1.0

	prevZ := z - ( (math.Pow(z,2) - x) / (2 * z))

	for (prevZ - z)>EPSILON && -(prevZ - z)<EPSILON {
		newZ := z - ( (math.Pow(z,2) - x) / (2 * z))
		prevZ = z;
		z = newZ;
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
}
