extends CanvasLayer

@onready var lives_counter: Label = $LivesCounter

func update_score(lives: int):
	lives_counter.text = "Lives Remaining: " + str(lives)
