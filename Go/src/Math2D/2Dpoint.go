package Math2D

import "fmt"

type 2DPoint_int struct {
  X int
  Y int
}

type 2DPoint_float struct {
  X float64
  Y float64
}

func 2DPoint_Int_Print(in *2DPoint_int) {
  fmt.Println("P(",(*in).X,",",(*in).Y,")\n")
}

func 2DPoint_Int_Add(out *2DPoint_int,in1 2DPoint_int, in2 2DPoint_int) {
  (*out).X = in1.X + in2.X
  (*out).Y = in1.Y + in2.Y
}
