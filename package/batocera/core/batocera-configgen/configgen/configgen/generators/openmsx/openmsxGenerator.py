#!/usr/bin/env python

from generators.Generator import Generator
import Command
import os
from distutils.dir_util import copy_tree

class OpenmsxGenerator(Generator):

    def generate(self, system, rom, playersControllers, gameResolution):

        #copy files to allow openmsx to run properly
        copy_openmsx_files()
        
        commandArray = ["/usr/bin/openmsx", "-cart", rom ]
        return Command.Command(array=commandArray)

def copy_openmsx_files():
    sourceDir = "/usr/share/openmsx/"
    targetDir = "/userdata/system/.openMSX/share/"
    if not os.path.exists(targetDir):
        os.makedirs(targetDir)
        # copy source files & directories to target
        copy_tree(sourceDir, targetDir)
