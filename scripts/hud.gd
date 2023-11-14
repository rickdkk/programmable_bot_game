extends CanvasLayer

@onready var fps_label := $FPSLabel as Label
@onready var coin_label := $Coins as Label

func _process(_delta: float) -> void:
	fps_label.set_text("FPS %d" % Engine.get_frames_per_second())


func _on_player_coin_collected(coins: int) -> void:
	coin_label.text = str(coins)
