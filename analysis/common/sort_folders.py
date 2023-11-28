import re  # regex for string parsing
import glob

def sort_folders_by_day(unsorted_folders_pattern):
    """
    The function sorts a list of folder names based on the day number (d#) in the folder name.
    
    :param unsorted_folders_key: The parameter `unsorted_folders_pattern` is a string that represents a file
    path or a pattern to match multiple file paths. It is used as an argument for the `glob.glob()`
    function to retrieve a list of file paths that match the pattern
    :return: a list of folders sorted by the day number extracted from their names.
    """
    unsorted_folders = glob.glob(unsorted_folders_pattern)
    sorted_folders = sorted(unsorted_folders, key=lambda x: int(re.search(r'd(.*?)(?:_|$)',x).group()[1]))
    print(sorted_folders)
    return sorted_folders