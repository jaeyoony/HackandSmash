# the parent class for a node in the state machine
# every node in the state machine should support these 5 functions: 
extends Node

# fcn that performs the frame -to-frame behavior of the state
func state_logic(delta): 
	return

# checks for state change 
func check_state():
	return

# recieves the analog/movement input as a vector of strengths & performs actions
func process_input(dir):
	return dir
	
# get the move velocity given the character's  current velocity & directional input
func calculate_velocity(dir, curr_velocity): 
#	print("Generic vel. calculation from : ", owner.curr_state.get_name())
#	print(curr_velocity, dir)
	return curr_velocity

func enter():
	return

func exit():
	return

func get_name(): 
	return
