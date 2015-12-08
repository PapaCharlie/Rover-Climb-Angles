package main

import (
	"errors"
	"fmt"
	"github.com/siravan/fits"
	"math"
	"os"
	"path/filepath"
	"strings"
)

type Position struct {
	x int
	y int
}

const (
	Minval = -100000.0
)

func main() {

	var dataset string
	if len(os.Args) == 2 {
		path, err := filepath.Abs(os.Args[1])
		if err != nil {
			panic(err)
		}
		if filepath.Ext(path) != ".fits" {
			panic(errors.New("Argument was not a fits file"))
		}
		dataset = path
	} else {
		panic(errors.New("Usage: ./dijkstra FITS"))
	}
	fmt.Println(dataset)

	reader, err := os.Open(dataset)
	if err != nil {
		panic(err)
	}
	units, err := fits.Open(reader)
	if err != nil {
		panic(err)
	}

	var shape [2]int
	shape[0] = units[0].Naxis[0]
	shape[1] = units[0].Naxis[1]
	startpos := Position{shape[0] / 2, shape[1] / 2}
	fmt.Println(shape, startpos)

	dtm := make([][]float64, shape[0])
	max_angles := make([][]float64, shape[0])
	good_pixels := 0

	for x := 0; x < shape[0]; x++ {
		dtm[x] = make([]float64, shape[1])
		max_angles[x] = make([]float64, shape[1])
		for y := 0; y < shape[1]; y++ {
			if val := units[0].FloatAt(x, y); val > Minval {
				good_pixels++
				dtm[x][y] = val - Minval
				max_angles[x][y] = math.Inf(1)
			} else {
				dtm[x][y] = math.NaN()
				max_angles[x][y] = math.NaN()
			}
		}
	}
	fmt.Println("Dataset size:", shape[0]*shape[1])
	fmt.Println("Good pixels:", good_pixels)

	dijkstra(shape, good_pixels, &dtm, &max_angles, startpos)
	WriteArray(&max_angles, strings.Replace(strings.Replace(dataset, ".fits", ".bin", 1), "/data/", "/outputs/", 1))

}
