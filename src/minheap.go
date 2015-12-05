package main

import (
	"container/heap"
)

type Element struct {
	Position
	HeightDiff float64
	index      int
}

type MinHeap []*Element

func NewMinHeap() *MinHeap {
	mh := &MinHeap{}
	heap.Init(mh)
	return mh
}

func (mh MinHeap) Len() int { return len(mh) }

func (mh MinHeap) Less(i, j int) bool {
	return mh[i].HeightDiff < mh[j].HeightDiff
}

func (mh MinHeap) Swap(i, j int) {
	mh[i], mh[j] = mh[j], mh[i]
	mh[i].index = i
	mh[j].index = j
}

func (mh *MinHeap) Push(x interface{}) {
	n := len(*mh)
	item := x.(*Element)
	item.index = n
	*mh = append(*mh, item)
}

func (mh *MinHeap) Pop() interface{} {
	old := *mh
	n := len(old)
	item := old[n-1]
	item.index = -1 // for safety
	*mh = old[0 : n-1]
	return item
}

func (mh *MinHeap) PushEl(el *Element) {
	heap.Push(mh, el)
}

func (mh *MinHeap) PopEl() *Element {
	el := heap.Pop(mh)
	return el.(*Element)
}

func (mh *MinHeap) PeekEl() *Element {
	items := *mh
	return items[0]
}

// update modifies the priority and value of an Item in the queue.
func (mh *MinHeap) UpdateEl(el *Element, heightdiff float64) {
	heap.Remove(mh, el.index)
	el.HeightDiff = heightdiff
	heap.Push(mh, el)
}

func (mh *MinHeap) RemoveEl(el *Element) {
	heap.Remove(mh, el.index)
}
