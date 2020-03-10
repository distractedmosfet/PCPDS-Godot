extends Control

var listOfSaves = []
var listOfImages = []
var currentPage = 1
var numOfPages = 0
var PauseScreen


# Function to display saves and connect node signals.
func _ready():
	loadSaveGames()
	
	for page in $"Save Pages".get_children():
		numOfPages += 1
		for node in page.get_children():
			node.connect('pressed', self, '_on_LoadBox_pressed', [node.name])
	
	for button in $"Page Buttons".get_children():
		button.connect('pressed', self, '_on_PageButton_pressed', [button.name])
	connect("visibility_changed", self , "visible_changed")

func visible_changed():
	var mod
	if (global.pause_input and not global.dialogueBox.displayingChoices) or not game.safeToSave:
		mod = Color(0.1, 0.1, 0.1, 1.0)
	else:
		mod = Color(1.0, 1.0, 1.0, 1.0)
	for page in $"Save Pages".get_children():
		for node in page.get_children():
			node.modulate = mod
	
# Function to congregate loading functions.
func loadSaveGames():
	loadSaves()
	displaySaves()



# Displays the gathered saves on their corresponding SaveBox.
func displaySaves():
	
	var file = File.new()
	
	for save in listOfSaves:
		#file.open_encrypted_with_pass(game.SAVE_FOLDER + '/' + save, File.READ, 'G@Y&D3@D')
		var saveName = save.substr(0, save.length() - 5)
		var saveImage = null
		var box
		
		for image in listOfImages:
			if saveName.is_subsequence_of(image):
				saveImage = image
				break
		
		for page in $"Save Pages".get_children():
			for node in page.get_children():
				if saveName == "save" + node.name.substr(7):
					box = node
		
		if saveImage:
			var img = Image.new()
			var texture = ImageTexture.new()
			img.load(game.SAVE_FOLDER + '/' + saveImage)
			texture.create_from_image(img)
			box.texture_normal = texture
			box.texture_hover = null
		else:
			box.texture_normal = load('res://images/loadscreen/empty_tile_no_image.png')
			box.texture_hover = load('res://images/loadscreen/empty_tile_hovered_no_image.png')
		
		file.close()



# Gathers existing saves and their related images.
func loadSaves():
	
	listOfSaves = []
	listOfImages = []
	var directory = Directory.new()
	
	if !directory.dir_exists(game.SAVE_FOLDER):
		directory.make_dir(game.SAVE_FOLDER)
	
	directory.open(game.SAVE_FOLDER)
	directory.list_dir_begin(true)
		
	while true:
		var file = directory.get_next()
		
		if directory.file_exists(file):
			if file.match('save*.tres'):
				listOfSaves.append(file)
			elif file.match('save*.png'):
				listOfImages.append(file)
		elif file == '':
			break



# Function to make a new save and link it to the clicked box.
func _on_LoadBox_pressed(saveBoxName):
	if (not global.pause_input or global.dialogueBox.displayingChoices) and game.safeToSave:
		PauseScreen.visible = false
		
		global.pause_input = true
			
		# Stop any sliding characters.
		var display = global.rootnode.get_node('Systems/Display')
		#var sliders = []
		#var still_sliders = false
		#while global.sliding or still_sliders:
		#	#get_tree().paused = false
		#	still_sliders = false
		#	for child in display.get_children():
		#		if child.name.match("*(*P*o*s*i*t*i*o*n*)*"):
		#			sliders.append(child.finish())
		#			still_sliders = true
		#	global.sliding = false
		#	#get_tree().paused = true
		#	var ogTime = $Wait.wait_time
		#	$Wait.wait_time = 1
		#	$Wait.start()
		#	yield($Wait, 'timeout')
		#	$Wait.wait_time = ogTime
		# Stop camera movment if it is moving
		#if global.cameraMoving:
		#	var camera = global.rootnode.get_node('Systems/Camera')
		#	global.pause_input = true
		#	get_tree().paused = false
		#	camera.finishCameraMovment()
		#	yield(camera, 'camera_movment_finished')
		#	camera.zoom = camera.lastZoom
		#	camera.offset = camera.lastOffset
		#	get_tree().paused = true
		#	global.pause_input = false
		
		# Stop any fading if it is happening
		#while global.fading or display.faders.size() > 0:
		#	#get_tree().paused = false
		#	global.finish_fading()
		#	var ogTime = $Wait.wait_time
		#	$Wait.wait_time = 1
		#	$Wait.start()
		#	yield($Wait, 'timeout')
		#	$Wait.wait_time = ogTime
		#	#get_tree().paused = true
		
		$Wait.start()
		yield($Wait, 'timeout')
		var saveBoxNum : int = int(saveBoxName.substr(7, saveBoxName.length()))
		game.newSave(saveBoxNum)
		loadSaveGames()
		PauseScreen.reloadLoad = true
		global.pause_input = false
		PauseScreen.visible = true

# Goes to the page left of the current if it exists.
func _on_LeftPage_pressed():
	if currentPage > 1:
		get_node('Save Pages/Page' + str(currentPage)).visible = false
		currentPage -= 1
		get_node('Save Pages/Page' + str(currentPage)).visible = true

# Goes to the page right of the current if it exists.
func _on_RightPage_pressed():
	if currentPage < numOfPages:
		get_node('Save Pages/Page' + str(currentPage)).visible = false
		currentPage += 1
		get_node('Save Pages/Page' + str(currentPage)).visible = true

# Goes to the page specified by the selected button.
func _on_PageButton_pressed(buttonName):
	get_node('Save Pages/Page' + str(currentPage)).visible = false
	currentPage = int(buttonName.substr(5, buttonName.length()))
	get_node('Save Pages/Page' + str(currentPage)).visible = true
