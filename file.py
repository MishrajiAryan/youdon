import os

# Define the folder path containing the Dart files
directory_path = "lib"  # Replace with your actual folder path
output_file_path = "merged_dart_files.txt"

# Open the output file in write mode
with open(output_file_path, "w", encoding="utf-8") as output_file:
    # Walk through all directories and subdirectories
    for root, _, files in os.walk(directory_path):
        for filename in files:
            if filename.endswith(".dart"):
                file_path = os.path.join(root, filename)
                
                with open(file_path, "r", encoding="utf-8") as dart_file:
                    content = dart_file.read()
                
                output_file.write(f"File Location: {file_path}\n")
                output_file.write(f"File Name: {filename}\n")
                output_file.write("File Code:\n")
                output_file.write(content)
                output_file.write("\n" + "-" * 40 + "\n")  # Separator for readability

print(f"Merged Dart files saved to {output_file_path}")
