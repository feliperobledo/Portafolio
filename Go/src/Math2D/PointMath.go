package Math2D

import (
  "fmt"
  //"math"
)

type Point2D_int struct {
  X int
  Y int
}

type Point2D_float struct {
  X float64
  Y float64
}

func Point2D_Int_New(x int, y int) *Point2D_int {
  return &Point2D_int{x,y};
}

func Point2D_Int_Print(in *Point2D_int) {
  fmt.Println("P(",(*in).X,",",(*in).Y,")\n")
}

func Point2D_Int_Add(out *Point2D_int,in1 Point2D_int, in2 Point2D_int) {
  (*out).X = in1.X + in2.X
  (*out).Y = in1.Y + in2.Y
}
