--[[
 LR B738 mapping for the Yawman Arrow By Ryan Mikulovsky, CC0 1.0.
 
 Inspired by Yawman's mapping for the MSFS PMDG 777.
 Thanks for Thomas Nield for suggesting looking into Lua for better controller support in XP12. Button numbers and variable names came from Thomas.
 
 See Thomas' video and access example Lua scripts at https://www.youtube.com/watch?v=x8SMg33RRQ4
 
 Repository at https://github.com/rpmik/Lua-Yawman-Control-LR-B738
]]
-- use local to prevent other unknown Lua scripts from overwriting variables (or vice versa)
local STICK_X = 0 
local STICK_Y = 1
local POLE_RIGHT = 2 
local POLE_LEFT = 3
local RUDDER = 4
local SLIDER_LEFT = 5
local SLIDER_RIGHT = 6 
local POV_UP = 0
local POV_RIGHT = 2
local POV_DOWN = 4
local POV_LEFT = 6
local THUMBSTICK_CLK = 8
local SIXPACK_1 = 9
local SIXPACK_2 = 10
local SIXPACK_3 = 11
local SIXPACK_4 = 12
local SIXPACK_5 = 13
local SIXPACK_6 = 14
local POV_CENTER = 15
local RIGHT_BUMPER = 16
local DPAD_CENTER = 17
local LEFT_BUMPER = 18
local WHEEL_DOWN = 19
local WHEEL_UP = 20
local DPAD_UP = 21
local DPAD_LEFT = 22
local DPAD_DOWN = 23
local DPAD_RIGHT = 24

-- Logic states to keep button assignments sane
local PAUSE_STATE = false
local STILL_PRESSED = false -- track presses for everything
local MULTI_SIXPACK_PRESSED = false -- track presses for only the six pack where there's multiple six pack buttons involved
local DPAD_PRESSED = false

local CHASE_VIEW = false

local FRAME_COUNT = 0.0
local GoFasterFrameRate = 0.0
local PauseIncrementFrameCount = 0.0

# Clean up the code with this
local NoCommand = "sim/none/none"

-- If aircraft's interactive Command increment is not continuous or continuous and too fast, use framerate to meter incrementing
function meterB738Interaction(strCommandName1, strCommandName2, floatSeconds, floatIntervalSpeed)
		-- floatIntervalSpeed -- generally, higher is slower. 
		
		-- Set metering based on current frame rate
		DataRef("FrameRatePeriod","sim/operation/misc/frame_rate_period","writable")
		CurFrame = FRAME_COUNT
		
		if not DPAD_PRESSED then
			FrameRate = 1/FrameRatePeriod
			-- Roughly calculate how many frames to wait before incrementing based on floatSeconds
			GoFasterFrameRate = (floatSeconds * FrameRate) + CurFrame -- start five seconds of slow increments
		end

		if CurFrame < GoFasterFrameRate then
			if not DPAD_PRESSED then
				command_once(strCommandName1)
				-- calculate frame to wait until continuing
				-- if floatSeconds is 2 then we'll wait around 1 second before continuing so as to allow a single standalone increment
				PauseIncrementFrameCount = ((floatSeconds/2) * FrameRate) + CurFrame
			else
				-- wait a beat with PauseIncrementFrameCount then continue
				if (CurFrame > PauseIncrementFrameCount) and (CurFrame % floatIntervalSpeed) == 0 then
					command_once(strCommandName1)
				end
			end
		elseif CurFrame >= GoFasterFrameRate and DPAD_PRESSED then
			-- If current frame is divisible by five then issue a command -- helps to delay the command in a regular interval
			if (CurFrame % floatIntervalSpeed) == 0 then
				command_once(strCommandName2)
			end
		end			
end


function multipressLRB738_buttons() 
    -- if aircraft is an Embraer E-175 then procede
    if PLANE_ICAO == "B738" then 
        FRAME_COUNT = FRAME_COUNT + 1.0  
		

		-- Base Config buttons that should almost always get reassigned except during a press
        if not STILL_PRESSED then -- avoid overwriting assignments during other activity
			set_button_assignment(DPAD_UP,NoCommand)
			set_button_assignment(DPAD_DOWN,NoCommand)
			set_button_assignment(DPAD_LEFT,"sim/general/zoom_out_fast")
			set_button_assignment(DPAD_RIGHT,"sim/general/zoom_in_fast")
			set_button_assignment(WHEEL_UP, NoCommand)
			set_button_assignment(WHEEL_DOWN, NoCommand)
			set_button_assignment(LEFT_BUMPER, NoCommand) -- multifunction
			set_button_assignment(RIGHT_BUMPER, NoCommand) -- multifunction
			set_button_assignment(SIXPACK_1,NoCommand)
			set_button_assignment(SIXPACK_2,NoCommand)
			set_button_assignment(SIXPACK_3,NoCommand)		
			set_button_assignment(SIXPACK_4,NoCommand)
			set_button_assignment(SIXPACK_5,NoCommand)
			set_button_assignment(SIXPACK_6,NoCommand)			
			set_button_assignment(POV_UP,"sim/flight_controls/pitch_trim_up")
			set_button_assignment(POV_DOWN,"sim/flight_controls/pitch_trim_down")
			set_button_assignment(POV_LEFT,"sim/view/glance_left")
			set_button_assignment(POV_RIGHT,"sim/view/glance_right")
			set_button_assignment(POV_CENTER,"sim/view/default_view")
			--set_button_assignment(THUMBSTICK_CLK,"sim/flight_controls/brakes_toggle_regular")

        end 
        
        -- Get button status
    
        right_bumper_pressed = button(RIGHT_BUMPER)
        left_bumper_pressed = button(LEFT_BUMPER)
        
        sp1_pressed = button(SIXPACK_1)
        sp2_pressed = button(SIXPACK_2)
        sp3_pressed = button(SIXPACK_3)
		sp4_pressed = button(SIXPACK_4)
		sp5_pressed = button(SIXPACK_5)
		sp6_pressed = button(SIXPACK_6)
		
		pov_up_pressed = button(POV_UP)
		pov_down_pressed = button(POV_DOWN)
		
		dpad_up_pressed = button(DPAD_UP)
		dpad_center_pressed = button(DPAD_CENTER)
		dpad_down_pressed = button(DPAD_DOWN)
		dpad_left_pressed = button(DPAD_LEFT)
		dpad_right_pressed = button(DPAD_RIGHT)
		
-- Start expanded control logic

		if dpad_center_pressed and not CHASE_VIEW and not STILL_PRESSED then
			command_once("sim/view/chase")
			CHASE_VIEW = true
			STILL_PRESSED = true
		end
	
		if dpad_center_pressed and CHASE_VIEW and not STILL_PRESSED then
			command_once("sim/view/default_view")
			CHASE_VIEW = false
			STILL_PRESSED = true
		end

-- Auto pilot engage A 
		
		if right_bumper_pressed and not dpad_up_pressed and not STILL_PRESSED then
			command_once("laminar/B738/autopilot/cmd_a_press")
			STILL_PRESSED = true
		
		end
		
-- autopilot control
	
		if sp1_pressed then

				
			if not STILL_PRESSED then -- Do not constantly set the button assignment every frame
				set_button_assignment(RIGHT_BUMPER,"sim/autopilot/autothrottle_n1epr_toggle")
				set_button_assignment(DPAD_RIGHT,NoCommand)
			end
			
			if dpad_up_pressed then
				meterB738Interaction("sim/autopilot/airspeed_up", "sim/autopilot/airspeed_up", 1.0, 2.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterB738Interaction("sim/autopilot/airspeed_down", "sim/autopilot/airspeed_down",1.0,2.0)
				DPAD_PRESSED = true
			end
			

		-- Pause Simulation
			if sp2_pressed and sp3_pressed and not MULTI_SIXPACK_PRESSED then
				command_once("sim/operation/pause_toggle")
				MULTI_SIXPACK_PRESSED = true
			end
			
			STILL_PRESSED = true
		end
		
		if sp2_pressed then
			if not STILL_PRESSED then -- Do not constantly set the button assignment every frame
				set_button_assignment(RIGHT_BUMPER,"sim/autopilot/fdir_command_bars_toggle")
				set_button_assignment(DPAD_RIGHT,"laminar/B738/autopilot/lnav_press")
				set_button_assignment(DPAD_LEFT,"sim/autopilot/NAV") -- built-in XP12 command
				set_button_assignment(DPAD_DOWN,"laminar/B738/autopilot/app_press")
				set_button_assignment(DPAD_UP,"laminar/B738/autopilot/vnav_press")

			end
					
			-- Flash Light
			if sp5_pressed and not MULTI_SIXPACK_PRESSED then
				command_once("sim/view/flashlight_red")
				MULTI_SIXPACK_PRESSED = true
			end
			
			STILL_PRESSED = true
		end

		if sp3_pressed then

			if not STILL_PRESSED then
				set_button_assignment(RIGHT_BUMPER,"laminar/B738/autopilot/vnav_press")
				set_button_assignment(SIXPACK_6,"sim/lights/landing_lights_toggle")
				set_button_assignment(DPAD_LEFT,"sim/autopilot/level_change")
				set_button_assignment(DPAD_RIGHT,"laminar/B738/autopilot/alt_hld_press")
			end
			
			if dpad_up_pressed then
				meterB738Interaction("sim/autopilot/altitude_up", "sim/autopilot/altitude_up", 1.0, 2.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterB738Interaction("sim/autopilot/altitude_down", "sim/autopilot/altitude_down", 1.0, 2.0)
				DPAD_PRESSED = true
			end
			
			STILL_PRESSED = true
			
		end
		
		if sp5_pressed then
			if not STILL_PRESSED then
				set_button_assignment(RIGHT_BUMPER,"sim/autopilot/heading")
			end
			
			if dpad_up_pressed then
				meterB738Interaction("sim/autopilot/heading_up", "sim/autopilot/heading_up", 1.0, 3.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterB738Interaction("sim/autopilot/heading_down", "sim/autopilot/heading_down", 1.0, 3.0)
				DPAD_PRESSED = true
			end
			STILL_PRESSED = true
		end
		
		if sp6_pressed then
			set_button_assignment(DPAD_LEFT,"sim/instruments/barometer_down")
			set_button_assignment(DPAD_RIGHT,"sim/instruments/barometer_up")
			set_button_assignment(DPAD_CENTER,"sim/instruments/barometer_std")

			set_button_assignment(RIGHT_BUMPER,"sim/autopilot/vertical_speed_pre_sel")
			--set_button_assignment(DPAD_CENTER,"sim/autopilot/vertical_speed")

			
			if dpad_up_pressed then
				meterB738Interaction("sim/autopilot/vertical_speed_up", "sim/autopilot/vertical_speed_up", 1.0, 3.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterB738Interaction("sim/autopilot/vertical_speed_down", "sim/autopilot/vertical_speed_down", 1.0, 3.0)
				DPAD_PRESSED = true
			end
			
			STILL_PRESSED = true

		end

-- parking brake			
		if left_bumper_pressed then
			set_button_assignment(SIXPACK_2,NoCommand)
			set_button_assignment(SIXPACK_1,NoCommand)

			if not STILL_PRESSED then
				set_button_assignment(WHEEL_UP,"sim/flight_controls/brakes_toggle_max")
				set_button_assignment(WHEEL_DOWN,"sim/flight_controls/brakes_toggle_max")
			end
				-- Cockpit camera height not implemented as it deals with the rudder axes.....
			if sp1_pressed and not MULTI_SIXPACK_PRESSED then
				if dpad_up_pressed then
					-- EFB but this doesn't quite work. B738.
					--set_pilots_head(-0.60079902410507,1.5304770469666,-11.694169998169,306.1875,-17.333335876465)
				else
					-- Glareshield B738
					set_pilots_head(0.017466999590397,1.0765490531921,-15.438016891479,1.5000001192093,-6.9999995231628)
				end
				MULTI_SIXPACK_PRESSED = true
			elseif sp2_pressed and not MULTI_SIXPACK_PRESSED then
				-- Nav, CDU, Transponder, etc B738
				set_pilots_head(0.016530999913812,1.0585050582886,-15.380796432495,0.93750107288361,-72.499969482422)
				MULTI_SIXPACK_PRESSED = true
			elseif sp3_pressed and not MULTI_SIXPACK_PRESSED then
				-- FMS B738
				set_pilots_head(-0.30361500382423,0.91400700807571,-15.92599105835,25.488981246948,-42.296062469482)
				MULTI_SIXPACK_PRESSED = true
			elseif sp4_pressed and not MULTI_SIXPACK_PRESSED then
				-- Overhead panel B738
				set_pilots_head(0.012876999564469,1.0980770587921,-15.262744903564,0,56.000007629395)
				MULTI_SIXPACK_PRESSED = true
			elseif sp5_pressed and not MULTI_SIXPACK_PRESSED then
				-- B738 upper overhead panel
				set_pilots_head(0.0075665470212698,1.2068643569946,-14.943939208984,359.82931518555,70.994369506836)

				MULTI_SIXPACK_PRESSED = true
			elseif sp6_pressed and not MULTI_SIXPACK_PRESSED then
				-- B738 pilot's view of throttles etc
				set_pilots_head(-0.49987199902534,1.3289279937744,-15.514320373535,38.0625,-39.047817230225)
				MULTI_SIXPACK_PRESSED = true
			end
			
			STILL_PRESSED = true
		end
				

-- DPAD_up mode
		if dpad_up_pressed then
			if not STILL_PRESSED then
				set_button_assignment(RIGHT_BUMPER,"laminar/B738/autopilot/capt_toga_press") -- there's only a toggle (Will investigate later)
				set_button_assignment(WHEEL_UP,"sim/flight_controls/flaps_down")
				set_button_assignment(WHEEL_DOWN,"sim/flight_controls/flaps_up")
				set_button_assignment(POV_LEFT,"sim/view/glance_left")
				set_button_assignment(POV_RIGHT,"sim/view/glance_right")
				set_button_assignment(POV_UP,"sim/view/straight_up")
				set_button_assignment(POV_DOWN,"sim/view/straight_down")
		
				set_button_assignment(DPAD_LEFT,NoCommand)
				set_button_assignment(DPAD_RIGHT,NoCommand)
			end
			
			if dpad_left_pressed then
				-- Pilot's seat B738
				--headX, headY, headZ, heading, pitch = get_pilots_head()
				--print(headX .. "," .. headY .. "," .. headZ .. "," .. heading .. "," .. pitch)
				set_pilots_head(-0.49987199902534,1.3289279937744,-15.514320373535,1.3125,-7.9999957084656)

			elseif dpad_right_pressed then
				-- Copilot's seat B738
				set_pilots_head(0.51441711187363,1.3289279937744,-15.491086959839,1.3125,-7.9999957084656)

			end
			STILL_PRESSED = true

		end
		
-- DPAD_down mode
		if dpad_down_pressed then
			if not STILL_PRESSED then
				set_button_assignment(RIGHT_BUMPER,"laminar/B738/autopilot/disconnect_toggle")
			end
			
			STILL_PRESSED = true
		end

-- All buttons need to be released to end STILL_PRESSED phase
		if not sp1_pressed and not sp2_pressed and not sp3_pressed and not sp4_pressed and not sp5_pressed and not sp6_pressed and not right_bumper_pressed and not left_bumper_pressed and not dpad_center_pressed and not dpad_down_pressed and not dpad_left and not dpad_right then
			STILL_PRESSED = false
		end

		if not sp1_pressed and not sp2_pressed and not sp3_pressed and not sp4_pressed and not sp5_pressed and not sp6_pressed then
			MULTI_SIXPACK_PRESSED = false
		end 
		
		if not dpad_up_pressed and not dpad_left_pressed and not dpad_right_pressed and not dpad_down_pressed then
			DPAD_PRESSED = false
		end

    end 
end

-- Don't mess with other configurations
if PLANE_ICAO == "B738" then 
	clear_all_button_assignments()

--[[
set_axis_assignment(STICK_X, "roll", "normal" )
set_axis_assignment(STICK_Y, "pitch", "normal" )
set_axis_assignment(POLE_RIGHT, "reverse", "reverse")
set_axis_assignment(POLE_RIGHT, "speedbrakes", "reverse")
set_axis_assignment(RUDDER, "yaw", "normal" )
]]

	do_every_frame("multipressLRB738_buttons()")
end
