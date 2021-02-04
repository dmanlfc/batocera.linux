#!/usr/bin/env python

import Command
from generators.Generator import Generator
import controllersConfig
#from shutil import copyfile
import os
from os import path

class Model2EmuGenerator(Generator):

    def generate(self, system, rom, playersControllers, gameResolution):

        srcnvdata = "/userdata/saves/model2/NVDATA"
        srcm2cfg = "/userdata/system/configs/model2emu/CFG"
        if not path.isdir(srcnvdata):
            os.mkdir(srcnvdata)
        if not path.isdir(srcm2cfg):
            os.mkdir(srcm2cfg)

        # created with make file
        dstnvdata = "/usr/model2emu/NVDATA"
        dstm2cfg = "/usr/model2emu/CFG"

        os.symlink(srcnvdata, dstnvdata)
        os.symlink(srcm2cfg, dstm2cfg)
        
        # todo - add some logic before calling if winetricks has already installed these libraries in the bottle
        env WINE=/usr/wine/lutris/bin/wine /usr/wine/winetricks d3dcompiler_42 d3dx9_42
        
        # what version of wine should we be using?
        commandArray = ["/usr/wine/lutris/bin/wine", "/usr/model2emu/EMULATOR.exe"]
        
        # resolution
        commandArray.append("-res={},{}".format(gameResolution["width"], gameResolution["height"]))
        
        # simplify the rom name (strip the directory & extension)
        romname = rom.replace("/userdata/roms/model2/", "")
        smplromname = romname.replace(".zip", "")

        commandArray.extend(["-fullscreen", smplromname])

        return Command.Command(
            array=commandArray,
            env={
                "WINEPREFIX": "/userdata/saves/model2",
                "vblank_mode": "0",
                'SDL_GAMECONTROLLERCONFIG': controllersConfig.generateSdlGameControllerConfig(playersControllers)
            })

    
