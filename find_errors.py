import re

def main():
    try:
        with open('lib/main.dart', 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"Error reading: {e}")
        return

    output = []
    
    for i, line in enumerate(lines):
        if 'catch' in line:
            block = []
            block.append(f'---\nLine {i+1}: {line.strip()}')
            found_snack = False
            for j in range(i+1, min(i+25, len(lines))):
                if 'ScaffoldMessenger' in lines[j] or 'content:' in lines[j] or 'SnackBar' in lines[j]:
                    block.append(f'  L{j+1}: {lines[j].strip()}')
                    found_snack = True
            
            if found_snack:
                output.extend(block)
    
    with open('output.txt', 'w', encoding='utf-8') as f:
        f.write('\n'.join(output))

if __name__ == "__main__":
    main()
