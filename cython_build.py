# THIS FILE IS USED TO BUILD THE .C FILE FROM .PYX FILE AND MOVE IT TO THE PREC FOLDER
# NORMALLY THIS IS DONE BY THE GITHUB ACTIONS
# BUT IF YOU WANT TO BUILD IT LOCALLY, YOU CAN RUN THIS FILE WITH PYTHON
# FOR EXAMPLE IN CASE OF OLDER PYTHON VERSIONS

# Import necessary modules
from sys import argv
from setuptools import setup
from Cython.Build import cythonize

# Append "build_ext" and "--inplace" to sys.argv to ensure the extension is built in place
argv.append("build_ext")
argv.append("--inplace")
argv.append("--compiler=mingw32")

ext_modules=cythonize(".\\src\\*.pyx", build_dir=".\\build")
print("Cythonizing files... ", ext_modules)

setup(ext_modules=ext_modules)
print("Setup build successful")