extends Node

var bgnode # The background image node.
var layers = [] # Arrays for storing images and videos via dictionaries containing their z-layer.

# Make the given image 'bg' a background.
func background(bg, type):
	
	# If a background is already set then remove it.
	if layers.size() > 0:
		if layers[layers.size() - 1]['name'] == 'BG':
			pass
	
	
	var info = layersetup(bg, 0) # Get info from the layersetup() function.
	
	# If of type image make the background a sprite.
	if type == 'image':
		bgnode = Sprite.new() # Create a new sprite node.
		bgnode.set_name('BG') # Give the node the name BG.
		layers[info[1]]['node'] = bgnode
		nodelayers(info[1]) # Add BG below all layers.
		
		bgnode.texture = info[2] # Give bgnode the 'bg' image.
		bgnode.centered = false # Uncenter the background.
		bgnode.scale = Vector2(global.size.x/1920, global.size.y/1080) # Scale the backgrund to the global size.
		
	# If of type video make the background a videoplayer.
	elif type == 'video':
		bgnode = VideoPlayer.new() # Create a new videoplayer node.
		bgnode.set_name('BG') # Give it the name BG.
		layers[info[1]]['node'] = bgnode
		nodelayers(info[1]) # Add BG below all layers.
		
		bgnode.stream = info[2] # Make the background the video.
		bgnode.rect_size = global.size # Set the size to the global size.
		bgnode.connect("finished", self, "loopvideo", [bgnode]) # Use the finished signal to run the loopvideo() function when the video finishes playing.
		bgnode.play() # Begin playing the video.
		
	# Otherwise print an error that an incorrect type was given.
	else:
		print('ERROR: In display.background(). ' + type + ' is not a valid type.')



# Function to play a video again when it ends. Thus looping it.
func loopvideo(node):
	node.play()	



# Results in layers being sorted from top layer to bottom layer.
class SortDictsDescending:
	
	# Sort the layers array based on the 'layer' key in descending order.
	static func sort(d1, d2):
		if d1['layer'] > d2['layer']:
			# Switch their indexes in the array.
			var tmp = d1['index']
			d1['index'] = d2['index']
			d2['index'] = tmp
			# Returns true so that the elements are switched.
			return true
			
		return false # Returns false so that nothing happends.



# Function to get a unique node name for an image/video layer.
func layernames(path):
	
	var layname = '' # Appended to to create a unique name.
	
	# Use the fact that '/' cannot be in file names to find the last slash, and thus the image name after it.
	for i in range(path.find_last('/') + 1, path.length()):
		layname += path[i]
	
	# Check for duplicate file names.
	for i in range(0, layers.size()):
		# If a duplicate is found add a number [#] to imgname.
		if layname == layers[i]['name']:
			# Use layer[i]['name'] under the alias x to make the code shorter.
			var x = layers[i]['name']
			
			# If a numbered [#] image of the same name exists then add 1 to the number then append to imgname.
			# Else append [1] to imgname. The first image added has no number in it.
			if x.find(']') != -1 and x[x.length() - 2].is_valid_integer():
				layname = layname.left(layname.length() - 3)
				layname += '[' + str(int(x[x.length() - 2]) + 1) + ']' 
			else:
				layname += '[1]'
				
	return layname # Return the name.



# Handles node parentage so that videos are also on the correct layer.
func nodelayers(index):
	
	var lastel = layers[layers.size() - 1] # Variable containing the last dictionary in the layers array.
	
	# Print an error if the layers array is not populated then  exit.
	if layers.size() == 0:
		print('The layers array is empty. Incorrect use of function: The layers array must be of size >= 1.')
		return
	
	# If layers is size 1 then add the node under root.
	if layers.size() == 1:
		global.rootnode.add_child(layers[0]['node'])
		return
	
	# If layers is of size > 1 then decide who is the given nodes parent and child.
	# If index is 0 simply add node 0 under lastel node.
	if index == 0:
		layers[1]['node'].add_child(layers[0]['node'])
		return
	
	# If index is the last in the array then add lastel to the roo node, remove the 2nd to last node
	if index == lastel['index']:
		global.rootnode.add_child(lastel['node'])
		global.rootnode.remove_child(layers[lastel['index'] - 1]['node'])
		lastel['node'].add_child(layers[lastel['index'] - 1]['node'])
		return
		
	# If index is not at the ends of layer then add it as a child to the layer below it,
	# then remove the child that is the layer above it from the layer below it,
	# and then add the layer above it as a child.
	layers[index + 1]['node'].add_child(layers[index]['node'])
	layers[index + 1]['node'].remove_child(layers[index - 1]['node'])
	layers[index]['node'].add_child(layers[index - 1]['node'])



#
func layersetup(path, z):
	
	var content = load(path) # Load the content using it's path.
	var cname = '' # The name of the content
	
	if z == 0:
		cname = 'BG' # If z is zero set cname as BG.
	else:
		cname = layernames(path) # Get a unique name using the content name.
	
	var layer = {"name": cname, "path": path, "content": content, "layer": z} # Make a dictionary of content information.
	layers.append(layer) # Append the dictionary to the layers array.
	var index = layers.size() - 1 # Get the index of the insertion.
	layers[index]['index'] = index # Make the index a key. 
	layers.sort_custom(SortDictsDescending, 'sort') # Sort layers in decsending order based on 'layer'.
	
	# Get the new index of the node after the sort.
	for i in range(layers.size()):
		
		if layers[i]['name'] == cname:
			index = i
			break
	
	# Make an array of the info to send back and then return it.
	var retarray = [cname, index, content]
	return retarray



# Display the given image on the scene on the given layer.
func image(imgpath, z):
	
	var info = layersetup(imgpath, z) # Get info from the layersetup() function.
	
	var imgnode = Sprite.new() # Create a new sprite node.
	imgnode.set_name(info[0]) # Give the sprite node the image name for a node name.
	layers[info[1]]['node'] = imgnode # Add the node under the node key.
	imgnode.centered = false # Uncenter the node.
	nodelayers(info[1]) # Put the node into the appropriate spot based on z.
	imgnode.texture = info[2] # Set the node's texture to the image.



# Display the given video on the scene on the given layer.
func video(vidpath, z):
	
	var info = layersetup(vidpath, z) # Get info from the layersetup() function.
	
	var vidnode = VideoPlayer.new() # Create a new videoplayer node.
	vidnode.set_name(info[0]) # Give the node vidname as its node name.
	layers[info[1]]['node'] = vidnode # Add the node under the node key.
	nodelayers(info[1])
	vidnode.stream = info[2] # Set the node's video steam to video.
	vidnode.rect_size = global.size # Set the size to the global size.
	vidnode.connect("finished", self, "loopvideo", [vidnode]) # Use the finished signal to run the loopvideo() function when the video finishes playing.
	vidnode.play() # Play the video.