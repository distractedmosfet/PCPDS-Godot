extends Node

# Variables to be used across all files.
var size = Vector2(1920,1080)
var rootnode

# Set dynamic variables + do startup functions.
func _ready():
	
	OS.set_low_processor_usage_mode(true) # Makes it so the cpu doesn't jump to 100% usage.
	
	# If the usersettings file does not exist then create it.
	var file = File.new()
	var filepath = OS.get_user_data_dir() + '/usersettings.tres'
	if file.file_exists(filepath) == false:
		file.open("user://usersettings.tres", File.WRITE)
		file.close()