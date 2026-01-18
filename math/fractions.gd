extends RefCounted
# fraction.gd
class_name Fraction

var numerator:int
var denominator:int = 1
var value:float:
	get:
		return numerator/float(denominator)

func _init(n:int = 0, d:int = 1) -> void:
	numerator = n
	denominator = d
	if denominator == 0:
		push_error("Divide By Zero: You done blowed up the world")
		denominator = 1
	_normalize()

func _normalize() -> void:
	if denominator < 0:
		numerator = -numerator
		denominator = -denominator

	var g:int = _gcd(abs(numerator), abs(denominator))
	if g != 0:
		numerator /= g
		denominator /= g

func _gcd(a:int, b:int) -> int:
	var aa:int = a
	var bb:int = b
	while bb != 0:
		var temp:int = bb
		bb = aa % bb
		aa = temp
	return aa

func add(other:Fraction) -> Fraction:
	return Fraction.new(
		numerator * other.denominator + other.numerator * denominator,
		denominator * other.denominator
	)

func sub(other:Fraction) -> Fraction:
	return Fraction.new(
		numerator * other.denominator - other.numerator * denominator,
		denominator * other.denominator
	)

func mul(other:Fraction) -> Fraction:
	return Fraction.new(
		numerator * other.numerator,
		denominator * other.denominator
	)

func div(other:Fraction) -> Fraction:
	if other.numerator == 0:
		push_error("ZeroDivisionError: divide by zero Fraction")
		return null
	return Fraction.new(
		numerator * other.denominator,
		denominator * other.numerator
	)

func eq(other:Fraction) -> bool:
	return numerator == other.numerator and denominator == other.denominator

func lt(other:Fraction) -> bool:
	return numerator * other.denominator < other.numerator * denominator

func le(other:Fraction) -> bool:
	return numerator * other.denominator <= other.numerator * denominator

func to_float() -> float:
	return float(numerator) / float(denominator)

func as_string() -> String:
	return str(numerator) + "/" + str(denominator)
