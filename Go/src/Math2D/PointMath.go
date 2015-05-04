package Math2D

import (
  "fmt"
  //"math"
)

// 2DPoint types================================================================
type Point2D_int struct {
  X int
  Y int
}

type P2int Point2D_int;
type Point2DArray []Point2D_int;

type Point2D_float struct {
  X float64
  Y float64
}

type P2float Point2D_float;
type f64Point2DArray []Point2D_float;

// Interface for different 2D point types to implement==========================
type IPoint2D interface {
  PrintPoint();
  Add(rhs *P2int) *P2int;
}


// 2DPoint type allocation methods==============================================
func Point2D_Int_New(x int, y int) *P2int {
  return &P2int{x,y};
}

func Point2D_Int_Array(count int) Point2DArray {
  return make([]Point2D_int,count);
}

// 2DPoint - int interface implementation=======================================
func (this *P2int) PrintPoint() {
  fmt.Println("P(",this.X,",",this.Y,")\n")
}

func (this *P2int) Add(rhs *P2int) *P2int {
  this.X += rhs.X;
  this.Y += rhs.Y;
  return this;
}

func (x Point2DArray) PrintPoint() {
  fmt.Printf("len=%d cap=%d %v\n", len(x), cap(x), x);
}



func Point2D_Int_Add(out *Point2D_int,in1 Point2D_int, in2 Point2D_int) {
  (*out).X = in1.X + in2.X
  (*out).Y = in1.Y + in2.Y
}
