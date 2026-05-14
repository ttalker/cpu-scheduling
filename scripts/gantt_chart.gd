extends Control

var timeline:  Array = []
var processes: Array = []

const BLOCK_H  = 54
const SCALE    = 44
const MARGIN_X = 24
const MARGIN_Y = 32
const TICK_GAP = 10
const MIN_W    = 600

var _scale: int = SCALE

var _pid_colors  : Dictionary = {}
var _color_index : int        = 0
var _palette = [
	Color("#4A90D9"),
	Color("#E8734A"),
	Color("#5BB55F"),
	Color("#9B59B6"),
	Color("#F39C12"),
	Color("#1ABC9C"),
	Color("#E74C3C"),
	Color("#3498DB"),
]

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size   = Vector2(MIN_W, BLOCK_H + MARGIN_Y + 40)

func display(new_timeline: Array, new_processes: Array) -> void:
	timeline     = new_timeline
	processes    = new_processes
	_pid_colors  = {}
	_color_index = 0
	_resize()
	queue_redraw()

func _draw() -> void:
	if timeline.is_empty():
		return

	var font      = ThemeDB.fallback_font
	var font_size = 14

	for block in timeline:
		var x    = MARGIN_X + block["start"] * _scale
		var w    = (block["end"] - block["start"]) * _scale
		var rect = Rect2(x, MARGIN_Y, w, BLOCK_H)

		var color = _get_color(block["pid"])
		draw_rect(rect, color)
		draw_rect(rect, Color(0, 0, 0, 0.35), false, 1.0)

		var label_x = x + w / 2.0 - 10
		var label_y = MARGIN_Y + BLOCK_H / 2.0 + 5
		draw_string(font, Vector2(label_x, label_y), block["pid"],
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

	var tick_y      = MARGIN_Y + BLOCK_H + TICK_GAP
	var drawn_ticks : Array = []
	for block in timeline:
		if not drawn_ticks.has(block["start"]):
			_draw_tick(block["start"], tick_y, font)
			drawn_ticks.append(block["start"])
	var last_end = timeline[timeline.size() - 1]["end"]
	if not drawn_ticks.has(last_end):
		_draw_tick(last_end, tick_y, font)

func _draw_tick(t: int, y: float, font: Font) -> void:
	var x = MARGIN_X + t * _scale
	draw_line(Vector2(x, y), Vector2(x, y + 6), Color.GRAY, 1.0)
	draw_string(font, Vector2(x - 4, y + 20), str(t),
		HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.GRAY)

func _resize() -> void:
	if timeline.is_empty():
		return
	var total_time = timeline[timeline.size() - 1]["end"]
	_scale         = max(10, min(SCALE, 800 / max(total_time, 1)))
	var w          = max(total_time * _scale + MARGIN_X * 2, MIN_W)
	custom_minimum_size = Vector2(w, BLOCK_H + MARGIN_Y + 40)

func _get_color(pid: String) -> Color:
	if not _pid_colors.has(pid):
		_pid_colors[pid] = _palette[_color_index % _palette.size()]
		_color_index += 1
	return _pid_colors[pid]
	
func reset():
	timeline  = []
	processes = []
	_pid_colors  = {}
	_color_index = 0
	custom_minimum_size = Vector2(MIN_W, BLOCK_H + MARGIN_Y + 40)
	queue_redraw()
