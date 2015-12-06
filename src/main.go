package main

import (
	"fmt"
	"github.com/siravan/fits"
	// "github.com/skelterjohn/go.matrix"
	"math"
	"os"
	"strconv"
	"strings"
)

type Position struct {
	x int
	y int
}

var datasets = []string{
	"../data/DTEEC_011417_1755_011562_1755_U01.fits",
	"../data/DTEEC_011844_1855_002812_1855_A01.fits",
	"../data/DTEEC_015985_2040_016262_2040_U01.fits",
	"../data/DTEEC_018854_1755_018920_1755_U01.fits",
	"../data/DTEEC_019045_1530_019322_1530_U01.fits",
	"../data/DTEEC_019612_1535_019678_1535_U01.fits",
	"../data/DTEEC_019757_1560_020034_1560_U01.fits",
	"../data/DTEEC_019823_1530_019889_1530_U01.fits",
	"../data/DTEEC_020324_1555_020390_1555_U01.fits",
	"../data/DTEEC_023957_1755_024023_1755_U01.fits",
	"../data/DTEEC_024234_1755_024300_1755_U01.fits",
	"../data/DTEEC_028011_2055_028288_2055_A01.fits",
	"../data/DTEEC_041277_2115_040776_2115_A01.fits",
}

var minval = -10000.0

func main() {

	var dataset string
	if len(os.Args) == 2 {
		i, _ := strconv.Atoi(os.Args[1])
		dataset = datasets[i]
	} else {
		dataset = datasets[len(datasets)-1]
	}
	fmt.Println(dataset)

	reader, _ := os.Open(dataset)
	units, _ := fits.Open(reader)

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
			if val := units[0].FloatAt(x, y); val > minval {
				good_pixels++
				dtm[x][y] = val - minval
				max_angles[x][y] = math.Inf(1)
			} else {
				dtm[x][y] = math.NaN()
				max_angles[x][y] = math.NaN()
			}
		}
	}
	fmt.Println("Good pixels:", good_pixels)

	dijkstra(shape, &dtm, &max_angles, startpos)
	WriteArray(&max_angles, strings.Replace(dataset, ".fits", ".bin", 1))

}
