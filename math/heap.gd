extends RefCounted
class_name Heap

class Leaf:
	var element:Variant
	var weight:float
var _heap:Array[Leaf] = []
var _weight_func:Callable
var _compare_func:Callable

## comparison function needs to take in two Variables which
## are of this heap's type and returns true if the left element meets
## the thingy you want to do IE min would be `return a <= b`
static func create(compare_func:Callable,weight_func:Callable) -> Heap:
	var heap:Heap = Heap.new()
	heap._weight_func = weight_func
	heap._compare_func = compare_func
	return heap

static func create_from_array(array:Array[Variant], compare_func:Callable, weight_func:Callable) -> Heap:
	var heap = Heap.create(compare_func,weight_func)
	heap.build_heap(array)
	return heap

## Private funcs
#update(element, new_value) - Change leaf to new value then maintain heap
func _rise(index:int) -> void:
	if index == 0: return
	var parent_index:int = _get_parent_index(index)
	if _compare_func.call(_heap[index].weight, _heap[parent_index].weight):
		_swap(index, parent_index)
		if index != parent_index:
			_rise(parent_index)

func _sink(index:int) -> void:
	var left:int = _get_left_index(index)
	var right:int = _get_right_index(index)
	var best:int = index
	if left <= _last_index() and _compare_func.call(_heap[left].weight, _heap[best].weight):
		best = left
	if right <= _last_index() and _compare_func.call(_heap[right].weight, _heap[best].weight):
		best = right

	if best != index and not _compare_func.call(_heap[index].weight, _heap[best].weight):
		_swap(index, best)
		_sink(best)

func _swap(a:int,b:int):
	var temp:Leaf = _heap[a]
	_heap[a] = _heap[b]
	_heap[b] = temp

func _delete(index:int) -> Variant:
	if index > _last_index(): return
	_swap(index, _last_index())
	var deleted_thing:Variant = _heap[_last_index()].element
	_heap.remove_at(_last_index())
	_sink(index)
	return deleted_thing

func _heapify(index:int):
	var largest:int = index
	var left:int = 2*index + 1
	var right:int = 2*index + 2
	
	if left <= _last_index() && _heap[left].weight > _heap[largest].weight:
		largest = left
	if right <= _last_index() && _heap[right].weight > _heap[largest].weight:
		largest = right
		
	if largest != index:
		_swap(index, largest)
		_heapify(largest)

func _get_left_index(i:int) -> int:
	return 2*i + 1
func _get_right_index(i:int) -> int:
	return 2*i + 2
func _get_parent_index(i:int) -> int:
	return floor( (i-1) / 2.0)
func _last_index() -> int:
	return _heap.size() - 1
	
## Public funcs
func peek() -> Variant:
	return _heap[0]
	
func push(element:Variant) -> void:
	var leaf = Leaf.new()
	leaf.element = element
	leaf.weight = _weight_func.call(element)
	_heap.append(leaf)
	_rise(_last_index())

func pop() -> Variant:
	if _last_index() < 0: return null
	var element:Variant = _heap[0].element
	_swap(0,_last_index())
	_heap.pop_back()
	_sink(0)
	return element

func delete(element:Variant) -> Variant:
	var ind:int = _heap.find_custom(func(item:Leaf):return item.element == element)
	if ind == -1:
		printerr("Couldn't find element %s in heap" % element)
		return null
	return _delete(ind)

func build_heap(array:Array[Variant]):
	#shove all the elements into the heap
	for elem:Variant in array:
		push(elem)

func size():
	return _heap.size()

func is_empty():
	return _heap.size() == 0	

func print():
	_print_heap()
	
func _print_heap(index:int = 0, prefix:String = "", is_left:bool = true):
	if index >= _heap.size():
		return

	var right:int = 2 * index + 2
	var left:int = 2 * index + 1

	# Print right subtree first (appears above)
	if right < _heap.size():
		_print_heap(right, prefix + ( "│   " if is_left else "    "), false)

	# Print current node
	print(prefix + ( "└── " if is_left else "┌── ") + str(_heap[index].weight))

	# Print left subtree (appears below)
	if left < _heap.size():
		_print_heap(left, prefix + ("    " if is_left else "│   "), true)
