package main

import (
	// "bufio"
	// "fmt"
	// "io/ioutil"
	"os"
	"strconv"
)

func WriteArray(arrptr *[][]float64, filename string) {
	f, _ := os.Create(filename)
	defer f.Close()

	arr := *arrptr
	for x := 0; x < len(arr); x++ {
		f.WriteString(strconv.FormatFloat(arr[x][0], 'E', -1, 64) + ",")
		for y := 1; y < len(arr[x]); y++ {
			f.WriteString("," + strconv.FormatFloat(arr[x][y], 'E', -1, 64))
		}
		f.WriteString("\n")
	}
}

// func main() {

// }
