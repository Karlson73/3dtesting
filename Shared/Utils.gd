extends RefCounted
class_name Utils
## Utils: các hàm tiện ích dùng chung.

static func clamp_vec3(v: Vector3, min_v: float, max_v: float) -> Vector3:
	return Vector3(
		clampf(v.x, min_v, max_v),
		clampf(v.y, min_v, max_v),
		clampf(v.z, min_v, max_v)
	)

static func deg_to_rad_safe(deg: float) -> float:
	return deg * PI / 180.0

static func rad_to_deg_safe(rad: float) -> float:
	return rad * 180.0 / PI

static func lerp_angle(from: float, to: float, weight: float) -> float:
	var diff := fposmod(to - from + PI, TAU) - PI
	return from + diff * weight

static func is_null_or_empty(s: String) -> bool:
	return s == null or s.strip_edges() == ""

static func get_node_safely(parent: Node, path: NodePath) -> Node:
	if not parent:
		return null
	if not parent.has_node(path):
		return null
	return parent.get_node(path)

## Tạo Tween tổng quát với easing mặc định
static func make_tween(node: Node, duration: float = 0.25) -> Tween:
	if node == null:
		return null
	var tw := node.create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_CUBIC)
	tw.set_parallel(false)
	if duration > 0.0:
		# Godot không có set_default_duration trực tiếp; dev dùng tween_property(.., t).
		pass
	return tw
