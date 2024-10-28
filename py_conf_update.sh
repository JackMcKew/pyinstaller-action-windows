# Define the file path
FILE_PATH="$PYTT/include/pyconfig.h"

# Check if the file exists
if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: File $FILE_PATH not found."
  exit 1
fi

# Define the text to add
TEXT_TO_ADD="#ifdef __MINGW32__\n#ifdef _WIN64\n#define MS_WIN64\n#endif\n#endif"

# Use sed to add the text below '/* Compiler specific defines */'
sed -i "/\/\* Compiler specific defines \*\//a $TEXT_TO_ADD" "$FILE_PATH"

# Confirm success
echo "Text added successfully to $FILE_PATH."
# print file content
cat $FILE_PATH
