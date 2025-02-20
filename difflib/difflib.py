import difflib

def read_file(file_path):
    with open(file_path, 'r') as file:
        return file.readlines()

def compare_files(file1, file2):
    lines1 = read_file(file1)
    lines2 = read_file(file2)

    diff = difflib.unified_diff(
        [line.strip() for line in lines1],
        [line.strip() for line in lines2],
        fromfile=file1,
        tofile=file2,
        lineterm=''
    )

    for line in diff:
        print(line)

if __name__ == "__main__":
    file1 = 'file1.txt'
    file2 = 'file2.txt'
    compare_files(file1, file2)
