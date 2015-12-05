package main

import (
	"fmt"
	"math"
)

var neighbors = []Position{
	Position{1, 0},
	Position{0, 1},
	Position{-1, 0},
	Position{0, -1},
}

func (pos1 Position) Add(pos2 Position) Position {
	return Position{pos1.x + pos2.x, pos1.y + pos2.y}
}

func dijkstra(shape [2]int, dtmptr, max_anglesptr *[][]float64, startpos Position) {
	dtm := *dtmptr
	max_angles := *max_anglesptr

	fits := func(pos Position) bool {
		return 0 <= pos.x && pos.x < shape[0] &&
			0 <= pos.y && pos.y < shape[1] &&
			!math.IsNaN(dtm[pos.x][pos.y]) // &&
		// !math.IsInf(max_angles[pos.x][pos.y], 1)
	}

	fr := NewMinHeap()
	fr.PushEl(&Element{
		Position:   startpos,
		HeightDiff: 0,
	})
	size := shape[0] * shape[1]
	fmt.Println(size)
	count := 0
	for count < size && fr.Len() > 0 {
		node := fr.PopEl()
		for _, n := range neighbors {
			neighbor := node.Add(n)
			if fits(neighbor) {
				diff := dtm[neighbor.x][neighbor.y] - dtm[node.x][node.y]
				alt := math.Max(math.Abs(node.HeightDiff), math.Abs(diff))
				if alt < max_angles[neighbor.x][neighbor.y] {
					if alt == math.Abs(diff) {
						max_angles[neighbor.x][neighbor.y] = diff
						fr.PushEl(&Element{Position: neighbor, HeightDiff: diff})
					} else {
						max_angles[neighbor.x][neighbor.y] = node.HeightDiff
						fr.PushEl(&Element{Position: neighbor, HeightDiff: node.HeightDiff})
					}
				}
			}
		}
		count++
	}
	fmt.Println(count)
}
