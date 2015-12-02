from heapq import heappush, heappop, nsmallest, heapify

class Frontier:
    def __init__(self):
        self.heap = list()

    def add_entry(self, entry):
        heappush(self.heap, entry)

    def pop(self):
        return heappop(self.heap)

    def peek(self):
        return self.heap[0]

    def popall(self):
        ls = [heappop(self.heap)]
        while self.peek()[0] == ls[0][0]:
            ls.append(heappop(self.heap))
        return ls


def new_frontier():
    return Frontier()
