-- Collection of functions for using the Yawman Arrow in multifunction mode
--[[
 Functions for Yawman Arrow Multifunction Mode By Ryan Mikulovsky, CC0 1.0.
 
 Inspired by Yawman's mapping for the MSFS PMDG 777.
 Thanks for Thomas Nield for suggesting looking into Lua for better controller support in XP12. Button numbers and variable names came from Thomas.
 
 See Thomas' video and access example Lua scripts at https://www.youtube.com/watch?v=x8SMg33RRQ4
 
 Repository at https://github.com/rpmik/Lua-Yawman-Control-LR-B738
]]

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