package main

import (
	"bufio"
	"encoding/binary"
	"math"
	"os"
	// "strconv"
)

func Float64frombytes(bytes []byte) float64 {
	bits := binary.LittleEndian.Uint64(bytes)
	float := math.Float64frombits(bits)
	return float
}

func Float64bytes(float float64) []byte {
	bits := math.Float64bits(float)
	bytes := make([]byte, 8)
	binary.LittleEndian.PutUint64(bytes, bits)
	return bytes
}

func WriteArray(arrptr *[][]float64, filename string) {
	f, _ := os.Create(filename)
	writer := bufio.NewWriter(f)
	defer f.Close()

	arr := *arrptr
	for x := 0; x < len(arr); x++ {
		for y := 0; y < len(arr[x]); y++ {
			writer.Write(Float64bytes(arr[x][y]))
		}
	}
}
