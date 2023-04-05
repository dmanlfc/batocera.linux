#!/usr/bin/env python
from generators.Generator import Generator
import Command
import os
import controllersConfig
import re

class ZesaruxGenerator(Generator):

    def generate(self, system, rom, playersControllers, guns, gameResolution):
        
        commandArray = ["zesarux", "--noconfigfile", "--fullscreen", "--zxdesktop-disable-on-fullscreen",  
            "--nowelcomemessage", "--nosplash", "--disablefooter", "--disableborder", "--machine", "128k",
            "--def-f-function", "F10", "ExitEmulator", "--quickexit",
            "--joystickemulated", "Kempston",
            "--joystickevent", "0", "Fire", "--joystickevent", "-7", "Up", "--joystickevent", "+7", "Down",
            "--joystickevent", "-6", "Left", "--joystickevent", "+6", "Right",
            "--fastautoload", "--enable-esxdos-handler", "--esxdos-root-dir", os.path.dirname(rom), rom]
        
        return Command.Command(
            array=commandArray,
            env={ "SDL_GAMECONTROLLERCONFIG": controllersConfig.generateSdlGameControllerConfig(playersControllers)}
            )
