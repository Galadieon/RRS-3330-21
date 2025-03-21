import re
from datetime import datetime

def modify_date_in_file(file_path):
    """
    Reads a text file, finds the date "2/25/1982", converts it to "YYYY-MM-DD" format,
    and prints each line (modified or original) terminated by a newline.

    Args:
        file_path (str): The path to the text file.
    """
    try:
        with open(file_path, 'r') as file:
            for line in file:
                modified_line = line.rstrip('\n')  # Remove existing newline
                
                # Convert the date string to datetime object
                date_object = datetime.strptime(modified_line, '%m/%d/%Y')
                # Format the datetime object to the desired string format
                modified_date_str = date_object.strftime('%Y-%m-%d')
                # Replace the old date with the new format
                modified_line = modified_line.replace(modified_line, modified_date_str)

                print(modified_line)

    except FileNotFoundError:
        print(f"Error: File not found at path: {file_path}")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    file_path = input("Enter the path to your text file: ")
    modify_date_in_file(file_path)