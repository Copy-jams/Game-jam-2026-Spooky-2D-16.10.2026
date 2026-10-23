extends VBoxContainer

func _on_spin_box_value_changed(value: float) -> void:
	# 1. Переводим ползунок (0..100) в диапазон от 0.0 (тишина) до 1.0 (максимум)
	var linear_volume = value / 100.0
	
	# 2. Переводим линейное значение в правильные децибелы и применяем
	MainMusicPlayer.volume_db = linear_to_db(linear_volume)


func _on_spin_box_2_value_changed(value: float) -> void:
	# То же самое для системных настроек звуков
	var linear_volume = value / 100.0
	WorldSettings.SoundsVolume = linear_to_db(linear_volume)
