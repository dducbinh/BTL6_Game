extends Sprite3D

@onready var progress_bar = $SubViewport/ProgressBar

func update_health(value, max_value):
	progress_bar.max_value = max_value
	progress_bar.value = value
