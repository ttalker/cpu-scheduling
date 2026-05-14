extends HBoxContainer

@onready var avg_wait_value = $StatCard_AvgWait/ValueLabel
@onready var avg_ta_value   = $StatCard_AvgTA/ValueLabel
@onready var cpu_value      = $StatCard_CPU/ValueLabel
@onready var total_value    = $StatCard_Total/ValueLabel

func _ready():
	size_flags_horizontal = Control.SIZE_EXPAND_FILL

func populate(averages: Dictionary, total_time: int, cpu_util: float):
	avg_wait_value.text = "%.2f" % averages["avg_wt"]
	avg_ta_value.text   = "%.2f" % averages["avg_tat"]
	cpu_value.text      = "%.1f%%" % cpu_util
	total_value.text    = str(total_time)

func reset():
	avg_wait_value.text = "—"
	avg_ta_value.text   = "—"
	cpu_value.text      = "—"
	total_value.text    = "—"
