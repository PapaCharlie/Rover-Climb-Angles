// This example demonstrates a priority queue built using the heap interface.
package main

import (
  "container/heap"
  "fmt"
)

// An Item is something we manage in a priority queue.
type Item struct {
  x         int
  y         int
  angle     float32
  index     int
}

// A Frontier implements heap.Interface and holds Items.
type Frontier []*Item

func (pq Frontier) Len() int { return len(pq) }

func (pq Frontier) Less(i, j int) bool {
  // We want Pop to give us the highest, not lowest, angle so we use greater than here.
  return pq[i].angle < pq[j].angle
}

func (pq Frontier) Swap(i, j int) {
  pq[i], pq[j] = pq[j], pq[i]
  pq[i].index = i
  pq[j].index = j
}

func (pq *Frontier) Push(x interface{}) {
  n := len(*pq)
  item := x.(*Item)
  item.index = n
  *pq = append(*pq, item)
}

func (pq *Frontier) Pop() interface{} {
  old := *pq
  n := len(old)
  item := old[n-1]
  item.index = -1 // for safety
  *pq = old[0 : n-1]
  return item
}

// update modifies the angle and value of an Item in the queue.
func (pq *Frontier) update(item *Item, x int, y int, angle float32) {
  item.x = x
  item.y = y
  item.angle = angle
  heap.Fix(pq, item.index)
}

// This example creates a Frontier with some items, adds and manipulates an item,
// and then removes the items in angle order.
func main() {
  // Create a angle queue, put the items in it, and
  // establish the angle queue (heap) invariants.
  pq := make(Frontier, 4)
  pq[0] = &Item{1,0,0.1,0}
  pq[1] = &Item{0,1,0.2,1}
  pq[2] = &Item{-1,0,1,2}
  pq[3] = &Item{0,-1,3,3}
  heap.Init(&pq)

  // Take the items out; they arrive in decreasing angle order.
  for pq.Len() > 0 {
    item := heap.Pop(&pq).(*Item)
    fmt.Printf("%2.f:(%d,%d) ", item.angle, item.x, item.y)
  }
}
